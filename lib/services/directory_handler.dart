import 'dart:io';

import 'package:flutter/material.dart';
import 'package:general_mod_manager/services/log_provider.dart';
import 'package:general_mod_manager/utils/dir_paths.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
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
    if (!scriptsDirectory.existsSync()) {
      File('${scriptsDirectory.path}\\Copy Zipped Mods In This Folder')
          .createSync();
    }
    return scriptsDirectory;
  }

  Directory getDataFilesPath() {
    Directory scriptsDirectory =
        Directory("${getInstallationDirectory()}\\data\\data");
    if (!scriptsDirectory.existsSync()) {
      Directory(scriptsDirectory.path).createSync();
    }
    return scriptsDirectory;
  }

  Directory getModFilesPath() {
    Directory scriptsDirectory =
        Directory("${getInstallationDirectory()}\\mods");
    if (!scriptsDirectory.existsSync()) {
      Directory(scriptsDirectory.path).createSync();
    }
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

  Future<void> openModsDir() async {
    if (!Platform.isWindows) return;
    print(checkDir(getModFilesPath().path));
    if (!checkDir(getModFilesPath().path)) return;
    Directory(getModFilesPath().path).createSync();
    File('${getModFilesPath().path}\\Copy Zipped Mods In This Folder')
        .createSync();

    await Process.run('explorer', [getModFilesPath().path]);
  }

  void openDir(dir) async {
    if (Platform.isWindows) {
      await Process.run('explorer', [dir]);
    }
  }
}
