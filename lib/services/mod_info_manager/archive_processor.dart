import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:archive/archive.dart';
import '../directory_handler.dart';
import 'info_creator.dart';
import '../log_provider.dart';

class ArchiveProcessor {
  final Directories directories;
  final InfoCreator infoCreator;
  final LogProvider logProvider;

  ArchiveProcessor(this.directories, this.logProvider)
      : infoCreator = InfoCreator(directories, logProvider);

  Future<Map<String, dynamic>?> processFile(
      File file, List<Map<String, dynamic>> ignoredMods) async {
    if (file.path.endsWith('.zip')) {
      return await _processZipFile(file, ignoredMods);
    } else if (file.path.endsWith('.pak')) {
      return await _processPakFile(file, ignoredMods);
    }
    return null;
  }

  Future<Map<String, dynamic>?> _processZipFile(
      File zipFile, List<Map<String, dynamic>> ignoredMods) async {
    final archive = await _readArchive(zipFile);
    Map<String, dynamic>? archiveData;

    for (final file in archive) {
      if (file.isFile && file.name == 'info.json') {
        final content = file.content as List<int>;
        final jsonString = utf8.decode(content);
        archiveData = jsonDecode(jsonString) as Map<String, dynamic>;
        break;
      }
    }

    if (archiveData == null) {
      for (final file in archive) {
        if (file.isFile && file.name.endsWith('.pak')) {
          final extractedFile = File(path.join(
              directories.getTempDir().path, path.basename(file.name)));
          await extractedFile.writeAsBytes(file.content as List<int>);

          archiveData =
              await infoCreator.extractOrCreateInfo(extractedFile, ignoredMods);
          break;
        }
      }
    }

    if (archiveData != null) {
      final archiveNameWithExtension = path.basename(zipFile.path);
      final archiveName =
          path.basenameWithoutExtension(archiveNameWithExtension);
      archiveData['ArchiveName'] = archiveName;

      if (archiveData.containsKey('Mods')) {
        final mods = archiveData['Mods'] as List<dynamic>? ?? [];
        final filteredMods = mods
            .where((mod) => !infoCreator.isModEntryIgnored(mod, ignoredMods))
            .toList();
        if (filteredMods.isNotEmpty) {
          archiveData['Mods'] = filteredMods;
          return archiveData;
        } else {
          logProvider.addLog(
              'All mods in archive "${zipFile.path}" are ignored. Skipping.');
          return null;
        }
      } else {
        return archiveData;
      }
    }

    logProvider.addLog('No .pak file found in "${zipFile.path}". Skipping.');
    return null;
  }

  Future<Map<String, dynamic>?> _processPakFile(
      File pakFile, List<Map<String, dynamic>> ignoredMods) async {
    return await infoCreator.extractOrCreateInfo(pakFile, ignoredMods);
  }

  Future<Archive> _readArchive(File file) async {
    final bytes = await file.readAsBytes();
    Archive archive;
    if (file.path.endsWith('.zip')) {
      archive = ZipDecoder().decodeBytes(bytes);
    } else if (file.path.endsWith('.tar.gz')) {
      archive = TarDecoder().decodeBytes(GZipDecoder().decodeBytes(bytes));
    } else if (file.path.endsWith('.tar')) {
      archive = TarDecoder().decodeBytes(bytes);
    } else if (file.path.endsWith('.pak')) {
      final fileData = ArchiveFile.noCompress(
        path.basenameWithoutExtension(file.path),
        bytes.length,
        bytes,
      );
      archive = Archive()..addFile(fileData);
    } else {
      throw UnsupportedError('Unsupported archive format: ${file.path}');
    }
    return archive;
  }
}
