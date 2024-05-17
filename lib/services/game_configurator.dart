import 'dart:convert';
import 'dart:io';

import 'package:general_mod_manager/utils/useful_functions.dart';

class GameConfigurator {
  String gameLocalAppPath;
  String gameDataPath;
  String gameBinPath;
  String gameExePath;
  String scriptExtenderPath;

  GameConfigurator({
    required this.gameLocalAppPath,
    required this.gameDataPath,
    required this.gameBinPath,
    required this.gameExePath,
    required this.scriptExtenderPath,
  });

  void configureGame() {
    String? localAppData = Platform.environment['LOCALAPPDATA'];

    if (localAppData == null) {
      print("Error: Unable to retrieve LOCALAPPDATA environment variable.");
      return;
    }

    String currentDirectory = Directory.current.path;
    String installDirectory = Directory(currentDirectory).parent.path;
    String dataDirectory = '$installDirectory\\Debug\\data';
    String modsDirectory = '$installDirectory\\Debug\\mods';

    String gameConfigPath = '$dataDirectory\\game_config.json';

    Map<String, String> config = {
      'game localappdata path': localAppData + gameLocalAppPath,
      'game data path': gameDataPath,
      'game bin path': gameBinPath,
      'game exe path': gameExePath,
      'script extender path': scriptExtenderPath
    };

    if (!checkDir(dataDirectory) || !checkDir(modsDirectory)) {
      if (!checkDir(dataDirectory) && !checkDir(modsDirectory)) {
        Directory(dataDirectory).createSync(recursive: true);
        Directory(modsDirectory).createSync(recursive: true);
        _writeConfigToFile(gameConfigPath, config);
      } else if (!checkDir(modsDirectory)) {
        Directory(modsDirectory).createSync(recursive: true);
        _writeConfigToFile(gameConfigPath, config);
      } else if (!checkDir(dataDirectory)) {
        Directory(dataDirectory).createSync(recursive: true);
        _writeConfigToFile(gameConfigPath, config);
      }
    } else {
      _writeConfigToFile(gameConfigPath, config);
    }
  }

  void _writeConfigToFile(String filePath, Map<String, String> config) {
    File file = File(filePath);
    file.writeAsStringSync(json.encode(config));
  }
}
