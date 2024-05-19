import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:general_mod_manager/services/directory_handler.dart';
import 'package:path/path.dart' as path;
import 'package:archive/archive.dart';

class Scripts {
  Directories directories = Directories();

  Future<void> getModInfo() async {
    final dir = Directory(directories.getModFilesPath().path);
    final List<FileSystemEntity> entities = await dir.list().toList();
    List<Map<String, dynamic>> infoDataList = [];

    final ignoredMods = await _readIgnoredMods();
    print('Ignored Mods: $ignoredMods');

    for (var entity in entities) {
      if (entity is File) {
        try {
          if (entity.path.endsWith('.zip')) {
            final archiveData = await _processZipFile(entity, ignoredMods);
            if (archiveData != null) {
              infoDataList.add(archiveData);
            }
          } else if (entity.path.endsWith('.pak')) {
            final archiveData = await _extractOrCreateInfo(entity, ignoredMods);
            if (archiveData != null) {
              infoDataList.add(archiveData);
            }
          }
        } catch (e) {
          print("Error processing ${entity.path}: $e");
        }
      }
    }

    final aggregatedData = jsonEncode(infoDataList);
    final outputFile = File(
        path.join(directories.getDataFilesPath().path, 'aggregated_info.json'));
    await outputFile.writeAsString(aggregatedData);

    print('Aggregated data written to ${outputFile.path}');
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

          archiveData = await _extractOrCreateInfo(extractedFile, ignoredMods);
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
        final filteredMods =
            mods.where((mod) => !_isModEntryIgnored(mod, ignoredMods)).toList();
        if (filteredMods.isNotEmpty) {
          archiveData['Mods'] = filteredMods;
          return archiveData;
        } else {
          print('All mods in archive "${zipFile.path}" are ignored. Skipping.');
          return null;
        }
      } else {
        return archiveData;
      }
    }

    print('No .pak file found in "${zipFile.path}". Skipping.');
    return null;
  }

  Future<Map<String, dynamic>?> _extractOrCreateInfo(
      File archiveFile, List<Map<String, dynamic>> ignoredMods) async {
    final archive = await _readArchive(archiveFile);
    for (final file in archive) {
      if (file.isFile && file.name == 'info.json') {
        final content = file.content as List<int>;
        final jsonString = utf8.decode(content);
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
    }

    // If no info.json is found, create a default one
    return _createDefaultInfo(archiveFile);
  }

  Future<Map<String, dynamic>> _createDefaultInfo(File archiveFile) async {
    final archiveNameWithExtension = path.basename(archiveFile.path);
    final modName = path.basenameWithoutExtension(archiveNameWithExtension);
    final folderName = path
        .basenameWithoutExtension(modName); // Using the same name for folder
    final modUUID = _generateUUID();

    final defaultInfo = {
      "Mods": [
        {
          "Author": "Unknown",
          "Name": modName,
          "Folder": folderName,
          "Version": null,
          "Description": "ModuleShortDesc",
          "UUID": modUUID,
          "Created": DateTime.now().toIso8601String(),
          "Dependencies": [],
          "Group": _generateUUID(),
        }
      ],
      "MD5": "",
      "ArchiveName": modName
    };

    print('Generated default info.json for $archiveNameWithExtension');

    return defaultInfo;
  }

  String _generateUUID() {
    final Random random = Random();
    final List<String> chars = '0123456789abcdef'.split('');

    String generateSection(int length) {
      return List.generate(length, (index) => chars[random.nextInt(16)]).join();
    }

    return '${generateSection(8)}-${generateSection(4)}-${generateSection(4)}-${generateSection(4)}-${generateSection(12)}';
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

  Future<List<Map<String, dynamic>>> _readIgnoredMods() async {
    try {
      final file =
          File('${directories.getDataFilesPath().path}/ignore_mods.json');
      final jsonString = await file.readAsString();
      final ignoredMods = jsonDecode(jsonString)['Mods'] as List<dynamic>?;
      return ignoredMods?.cast<Map<String, dynamic>>() ?? [];
    } catch (e) {
      print('Error reading ignored mods: $e');
      return [];
    }
  }

  bool _isModEntryIgnored(
      Map<String, dynamic> mod, List<Map<String, dynamic>> ignoredMods) {
    final modUUID = mod['UUID'] as String?;
    final modName = mod['Name'] as String?;
    final modGroup = mod['Group'] as String?;

    return ignoredMods.any((ignoredMod) =>
        ignoredMod['UUID'] == modUUID ||
        ignoredMod['Name'] == modName ||
        ignoredMod['Group'] == modGroup);
  }
}
