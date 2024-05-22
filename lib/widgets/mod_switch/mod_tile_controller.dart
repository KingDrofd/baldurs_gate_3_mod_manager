import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:general_mod_manager/services/game_mod_manager/game_mod_manager.dart';
import 'package:general_mod_manager/services/log_provider.dart';
import 'package:general_mod_manager/widgets/options/option_dialog.dart';
import 'package:path/path.dart' as path;
import 'package:xml/xml.dart';
import 'package:general_mod_manager/services/directory_handler.dart';
import 'package:general_mod_manager/services/modsettings_modifier.dart';

class ModTileController {
  final Directories directories = Directories();
  final GameModManager manager;
  final LogProvider logProvider;

  ModTileController(this.logProvider)
      : manager = GameModManager(Directories(), logProvider);

  Future<Map<String, String>> loadConfig() async {
    String configPath =
        path.join(directories.getDataFilesPath().path, 'game_config.json');
    if (await File(configPath).exists()) {
      String content = await File(configPath).readAsString();
      Map<String, dynamic> tempGamePaths = jsonDecode(content);

      return tempGamePaths.map((key, value) => MapEntry(key, value.toString()));
    } else {
      throw Exception("Configuration file not found.");
    }
  }

  Future<void> handleModToggle(
      bool value, Map<String, dynamic> modData, bool orderMode, context) async {
    Map<String, String> modSettingsPath = await loadConfig();
    ModifyModsetting modifyModsetting = ModifyModsetting();
    final modSettingsFile = File(path.join(
        modSettingsPath['game mod settings path']!, 'modsettings.lsx'));
    final document = XmlDocument.parse(modSettingsFile.readAsStringSync());

    if (value == true) {
      OptionDialog optionDialog = OptionDialog();
      optionDialog.showUpdateManager(context, "Installing Mod");
      String? modFolder = await manager.extractMod(modData['ArchiveName']);
      if (modFolder != null) {
        List<String> extractedPaths = [];
        await for (var entity in Directory(modFolder).list(recursive: true)) {
          if (entity is File) {
            extractedPaths.add(entity.path);
          }
        }
        await manager.saveExtractedPaths(
            modData['ArchiveName'], extractedPaths);

        await manager.appendModInfo(modData['ArchiveName']);

        if (modData['Mods'][0]['Name'] != "ModFixer") {
          modifyModsetting.addMod(
            document,
            'ModuleShortDesc',
            modData['Mods'][0]['Folder'] ?? '',
            modData['MD5'] ?? '',
            modData['Mods'][0]['Name'] ?? '',
            modData['Mods'][0]['UUID'] ?? '',
            modData['Mods'][0]['Version'] ?? '',
            orderMode,
          );
        }
      }

      if (!context.mounted) return;
      if (optionDialog.isDialogShowing) {
        Navigator.of(context).pop();
      }
    } else {
      OptionDialog optionDialog = OptionDialog();
      optionDialog.showUpdateManager(context, "Uninstalling Mod");
      await manager.deleteFilesFromJson(modData['ArchiveName']);
      modifyModsetting.removeMod(
          document, modData['Mods'][0]['UUID'], orderMode);

      if (!context.mounted) return;
      if (optionDialog.isDialogShowing) {
        Navigator.of(context).pop();
      }
    }

    modifyModsetting.saveDocument(
        document,
        path.join(
            modSettingsPath['game mod settings path']!, 'modsettings.lsx'));
  }
}
