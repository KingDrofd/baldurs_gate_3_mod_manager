import 'dart:io';

import 'package:flutter/material.dart';
import 'package:general_mod_manager/utils/dir_paths.dart';
import 'package:path/path.dart' as p;
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

  Directory getDataFilesPath() {
    Directory scriptsDirectory =
        Directory("${getInstallationDirectory()}\\data\\data");
    return scriptsDirectory;
  }

  Directory getModFilesPath() {
    Directory scriptsDirectory =
        Directory("${getInstallationDirectory()}\\mods");
    return scriptsDirectory;
  }

  Directory getModInstallPath() {
    String? localAppPath = Platform.environment['LOCALAPPDATA'];
    Directory modInstallPath = Directory(localAppPath!);

    return modInstallPath;
  }

  Directory getTempDir() {
    // Return the system temporary directory or a specific temporary directory for your app
    return Directory.systemTemp.createTempSync('bg3 manager temp');
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
