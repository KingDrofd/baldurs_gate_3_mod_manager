import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import '../directory_handler.dart';
import 'mod_extractor.dart';
import '../log_provider.dart';

class ModInfoAppender {
  final Directories directories;
  final ModExtractor modExtractor;
  final LogProvider logProvider;

  ModInfoAppender(this.directories, this.logProvider)
      : modExtractor = ModExtractor(directories, logProvider);

  Future<void> appendModInfo(String modName) async {
    String modZip = '$modName.zip';
    String modZipPath = path.join(directories.getModFilesPath().path, modZip);
    Map<String, dynamic> modInfoDict = {};

    if (await File(modZipPath).exists()) {
      String? modFolder = await modExtractor.extractMod(modName);

      if (modFolder != null) {
        String infoFile = path.join(modFolder, "info.json");
        if (await File(infoFile).exists()) {
          logProvider.addLog("Info file exists for $modName");
          String content = await File(infoFile).readAsString();
          Map<String, dynamic> modInfo = json.decode(content);
          modInfoDict[modName] = modInfo;
        } else {
          logProvider.addLog(
              "info.json file not found in the extracted folder for $modName");
        }
      }
    } else {
      logProvider.addLog("Mod zip file not found for $modName");
      return;
    }

    try {
      String modsInfoFile =
          path.join(directories.getDataFilesPath().path, "mods_info.json");
      Map<String, dynamic> data = {};

      if (await File(modsInfoFile).exists()) {
        String content = await File(modsInfoFile).readAsString();
        if (content.isNotEmpty) {
          data = json.decode(content);
        }
      }

      data.addAll(modInfoDict);

      await File(modsInfoFile).writeAsString(json.encode(data),
          flush: true, mode: FileMode.writeOnly);
      logProvider.addLog("Mod info appended to $modsInfoFile");
    } catch (e) {
      logProvider.addLog("Error occurred while appending mod info: $e");
    }
  }
}
