import 'dart:io';

import 'package:general_mod_manager/services/directory_handler.dart';

class Scripts {
  Directories directories = Directories();
  void getModInfo() {
    Process.run('', []);
  }

  void installMod(String name) {
    final installScript =
        "${directories.getScriptFilesPath().path}\\installMod.exe";
    Process.run(installScript, [name]);
  }

  void uninstallMod(String name) {
    final uninstallScript =
        "${directories.getScriptFilesPath().path}\\uninstallMod.exe";
    Process.run(uninstallScript, [name]);
  }
}
