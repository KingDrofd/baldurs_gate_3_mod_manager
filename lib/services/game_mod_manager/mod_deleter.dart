import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import '../directory_handler.dart';
import '../log_provider.dart';

class ModDeleter {
  final Directories directories;
  final LogProvider logProvider;

  ModDeleter(this.directories, this.logProvider);

  Future<void> deleteFilesFromJson(String modName) async {
    String extractedInfoFile =
        path.join(directories.getDataFilesPath().path, "extracted_info.json");
    String modsInfoFile =
        path.join(directories.getDataFilesPath().path, "mods_info.json");

    if (!await File(extractedInfoFile).exists()) {
      logProvider.addLog("JSON file '$extractedInfoFile' not found.");
      return;
    }

    String content = await File(extractedInfoFile).readAsString();
    Map<String, dynamic> data = json.decode(content);

    if (!data.containsKey(modName)) {
      logProvider.addLog("Mod '$modName' not found in the JSON file.");
      return;
    }

    List<dynamic> paths = data[modName];
    for (String path in paths) {
      if (await Directory(path).exists()) {
        await deleteDirectoryContents(path);
        Directory(path).deleteSync(recursive: true);
        logProvider.addLog("Deleted directory: $path");
      } else if (await File(path).exists()) {
        File(path).deleteSync();
        logProvider.addLog("Deleted file: $path");
      } else {
        logProvider.addLog("Path does not exist: $path");
      }
    }

    // Remove the mod entry from the JSON data
    data.remove(modName);

    // Write the updated JSON data back to the file
    await File(extractedInfoFile).writeAsString(json.encode(data),
        flush: true, mode: FileMode.writeOnly);

    // Remove mod info from mods_info.json
    if (await File(modsInfoFile).exists()) {
      String modsInfoContent = await File(modsInfoFile).readAsString();
      if (modsInfoContent.isNotEmpty) {
        Map<String, dynamic> modsInfoData = json.decode(modsInfoContent);
        modsInfoData.remove(modName);
        await File(modsInfoFile).writeAsString(json.encode(modsInfoData),
            flush: true, mode: FileMode.writeOnly);
        logProvider.addLog("Mod info removed from $modsInfoFile");
      }
    }
  }

  Future<void> deleteDirectoryContents(String directory) async {
    Directory dir = Directory(directory);
    if (await dir.exists()) {
      await for (FileSystemEntity entity in dir.list(recursive: false)) {
        if (entity is Directory) {
          await deleteDirectoryContents(entity.path);
          Directory(entity.path).deleteSync(recursive: true);
          logProvider.addLog("Deleted directory: ${entity.path}");
        } else if (entity is File) {
          entity.deleteSync();
          logProvider.addLog("Deleted file: ${entity.path}");
        }
      }
    }
  }
}
