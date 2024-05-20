import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:archive/archive.dart';
import '../directory_handler.dart';
import '../log_provider.dart';

class ModExtractor {
  final Directories directories;
  final LogProvider logProvider;

  ModExtractor(this.directories, this.logProvider);

  Future<String?> extractMod(String modName) async {
    String modZip = '$modName.zip';
    String? modFolder = await getModFolder();

    if (modFolder == null) {
      logProvider.addLog(
          "Game localappdata path is not defined in the configuration.");
      return null;
    }

    String modPath = path.join(directories.getModFilesPath().path, modZip);

    if (!await File(modPath).exists()) {
      logProvider.addLog("Mod zip file not found: $modPath");
      return null;
    }

    List<int> bytes = await File(modPath).readAsBytes();
    Archive archive = ZipDecoder().decodeBytes(bytes);

    String? topLevelFolder = getTopLevelFolder(archive);

    for (ArchiveFile file in archive) {
      String filePath = topLevelFolder != null
          ? path.join(modFolder, file.name.replaceFirst('$topLevelFolder/', ''))
          : path.join(modFolder, file.name);

      if (file.isFile) {
        File(filePath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(file.content as List<int>);
      } else {
        Directory(filePath).createSync(recursive: true);
      }
    }

    logProvider.addLog("Mod extracted: $modFolder");
    return modFolder;
  }

  Future<String?> getModFolder() async {
    String configPath =
        path.join(directories.getDataFilesPath().path, 'game_config.json');
    if (await File(configPath).exists()) {
      String content = await File(configPath).readAsString();
      Map<String, dynamic> tempGamePaths = jsonDecode(content);
      return tempGamePaths['game localappdata path']?.toString();
    }
    return null;
  }

  String? getTopLevelFolder(Archive archive) {
    Set<String> topLevelFolders = {};
    for (var file in archive.files) {
      String topLevel = file.name.split('/').first;
      topLevelFolders.add(topLevel);
    }
    return topLevelFolders.length == 1 ? topLevelFolders.first : null;
  }
}
