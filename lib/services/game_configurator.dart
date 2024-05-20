import 'dart:convert';
import 'dart:io';
import 'package:general_mod_manager/services/directory_handler.dart';
import 'package:path/path.dart' as p;
import 'package:general_mod_manager/utils/useful_functions.dart';

import 'log_provider.dart';

class GameConfigurator {
  String gameLocalAppPath;
  String gameModSettingsPath;
  String gameDataPath;
  String gameBinPath;
  String gameExePath;
  String scriptExtenderPath;
  Directories directories;
  final LogProvider logProvider;

  GameConfigurator(
      {required this.gameLocalAppPath,
      required this.gameModSettingsPath,
      required this.gameDataPath,
      required this.gameBinPath,
      required this.gameExePath,
      required this.scriptExtenderPath,
      required this.directories,
      required this.logProvider});

  Future<void> configureGame() async {
    String dataDirectory = directories.getDataFilesPath().path;
    String modsDirectory = directories.getModFilesPath().path;

    String gameConfigPath = '$dataDirectory\\game_config.json';

    Map<String, String> config = {
      'game localappdata path':
          p.join(directories.getModInstallPath().path, gameLocalAppPath),
      'game mod settings path':
          p.join(directories.getModInstallPath().path, gameModSettingsPath),
      'game data path': gameDataPath,
      'game bin path': gameBinPath,
      'game exe path': gameExePath,
      'script extender path': scriptExtenderPath
    };

    if (!checkDir(dataDirectory) || !checkDir(modsDirectory)) {
      if (!checkDir(dataDirectory) && !checkDir(modsDirectory)) {
        logProvider.addLog("No mods or data folder detected. Creating...");
        Directory(dataDirectory).createSync(recursive: true);
        Directory(modsDirectory).createSync(recursive: true);
        logProvider.addLog("Writing configuration to files...");
        _writeConfigToFile(gameConfigPath, config);
        logProvider.addLog("Successful.");
      } else if (!checkDir(modsDirectory)) {
        logProvider.addLog("No mods folder detected. Creating...");
        Directory(modsDirectory).createSync(recursive: true);
        logProvider.addLog("Writing configuration to files...");
        _writeConfigToFile(gameConfigPath, config);
        logProvider.addLog("Successful.");
      } else if (!checkDir(dataDirectory)) {
        logProvider.addLog("No data folder detected. Creating...");

        Directory(dataDirectory).createSync(recursive: true);
        logProvider.addLog("Writing configuration to files...");

        _writeConfigToFile(gameConfigPath, config);
        logProvider.addLog("Successful.");
      }
    } else {
      logProvider.addLog("Writing configuration to files...");
      _writeConfigToFile(gameConfigPath, config);
      logProvider.addLog("Successful.");
    }
  }

  void _writeConfigToFile(String filePath, Map<String, String> config) {
    File file = File(filePath);
    file.writeAsStringSync(json.encode(config));
  }
}
