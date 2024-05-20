import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import '../directory_handler.dart';
import '../log_provider.dart';

class ConfigLoader {
  final Directories directories;
  final LogProvider logProvider;
  Map<String, String> gamePaths = {};

  ConfigLoader(this.directories, this.logProvider);

  Future<void> loadConfig() async {
    String configPath =
        path.join(directories.getDataFilesPath().path, 'game_config.json');
    logProvider.addLog("Loading config from $configPath");
    if (await File(configPath).exists()) {
      String content = await File(configPath).readAsString();
      Map<String, dynamic> tempGamePaths = jsonDecode(content);
      gamePaths =
          tempGamePaths.map((key, value) => MapEntry(key, value.toString()));
      logProvider.addLog("Configuration loaded: $gamePaths");
    } else {
      logProvider.addLog("Configuration file not found at $configPath.");
      throw Exception("Configuration file not found.");
    }
  }
}
