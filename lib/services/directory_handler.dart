import 'dart:io';

import 'package:general_mod_manager/utils/dir_paths.dart';

import '../utils/useful_functions.dart';

class Directories {
  String getInstallationDirectory() {
    String directory = Platform.resolvedExecutable;
    directory = directory.substring(0, directory.lastIndexOf("\\"));
    return directory;
  }

  Directory getScriptFilesPath() {
    Directory scriptsDirectory = Directory(
        "${getInstallationDirectory()}\\data\\flutter_assets\\scripts");
    return scriptsDirectory;
  }

  void openModsDir() async {
    if (!Platform.isWindows) return;
    print(checkDir(modsDirectory));
    if (!checkDir(modsDirectory)) return;
    Directory(modsDirectory).createSync();
    File('$modsDirectory\\Copy Zipped Mods In This Folder').createSync();

    await Process.run('explorer', [modsDirectory]);
  }

  void openGameDir() async {
    if (Platform.isWindows) {
      await Process.run('explorer', [gameDirectory]);
    }
  }
}
