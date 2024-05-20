import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;
import '../directory_handler.dart';
import '../log_provider.dart';

class InfoCreator {
  final Directories directories;
  final LogProvider logProvider;

  InfoCreator(this.directories, this.logProvider);

  Future<Map<String, dynamic>?> extractOrCreateInfo(
      File archiveFile, List<Map<String, dynamic>> ignoredMods) async {
    final archive = await _readArchive(archiveFile);
    for (final file in archive) {
      if (file.isFile && file.name == 'info.json') {
        final content = file.content as List<int>;
        final jsonString = utf8.decode(content);
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
    }

    return _createDefaultInfo(archiveFile);
  }

  Future<Map<String, dynamic>> _createDefaultInfo(File archiveFile) async {
    final archiveNameWithExtension = path.basename(archiveFile.path);
    final modName = path.basenameWithoutExtension(archiveNameWithExtension);
    final folderName = path.basenameWithoutExtension(modName);
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

    logProvider
        .addLog('Generated default info.json for $archiveNameWithExtension');

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

  bool isModEntryIgnored(
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
