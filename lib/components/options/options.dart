import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;
import 'package:general_mod_manager/services/log_provider.dart';
import 'package:general_mod_manager/services/mod_info_manager/mod_info_manager.dart';
import 'package:general_mod_manager/services/mod_paths.dart';
import 'package:general_mod_manager/services/directory_handler.dart';
import 'package:general_mod_manager/services/game_configurator.dart';
import 'package:general_mod_manager/services/url_launch.dart';
import 'package:general_mod_manager/utils/variables.dart';
import 'package:general_mod_manager/widgets/options/option_dialog.dart';
import 'package:general_mod_manager/widgets/options/option_tile.dart';

import '../../widgets/text_field_widget.dart';

class OptionList extends StatefulWidget {
  const OptionList({
    super.key,
    required this.refresh,
  });
  final Function() refresh;
  @override
  State<OptionList> createState() => _OptionListState();
}

class _OptionListState extends State<OptionList> {
  OptionDialog optionDialog = OptionDialog();
  UrlLaunch urlLaunch = UrlLaunch();
  Directories directories = Directories();
  ModPaths modsInfo = ModPaths();
  late ModInfoManager infoManager;
  Map<String, String> gamePaths = {};
  final TextEditingController _gameExeController = TextEditingController();
  final TextEditingController _gameDataController = TextEditingController();
  final TextEditingController _gameAppDataController = TextEditingController();

  @override
  void initState() {
    init();
    final logProvider = Provider.of<LogProvider>(context, listen: false);
    infoManager = ModInfoManager(directories, logProvider);
    super.initState();
  }

  Future<Map<String, String>> loadConfig() async {
    String configPath =
        path.join(directories.getDataFilesPath().path, 'game_config.json');
    try {
      String content = await File(configPath).readAsString();
      Map<String, dynamic> tempGamePaths = jsonDecode(content);

      return tempGamePaths.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      final logProvider = Provider.of<LogProvider>(context, listen: false);
      if (!mounted) return {};
      if (optionDialog.isDialogShowing) {
        Navigator.of(context).pop();
      }
      logProvider.addLog("Configuration file not found at $configPath");
      return {};
    }
  }

  Future<void> init() async {
    try {
      gamePaths = await loadConfig();
      if (gamePaths.isEmpty) {}
      setState(() {
        _gameExeController.text = gamePaths['game bin path']!;
        _gameDataController.text = gamePaths['game data path']!;
        _gameAppDataController.text = gamePaths['game localappdata path']!;
      });
    } catch (e) {
      if (!mounted) return;
      final logProvider = Provider.of<LogProvider>(context, listen: false);
      if (optionDialog.isDialogShowing) {
        Navigator.of(context).pop();
      }
      logProvider.addLog("$e");
    }
  }

  void _updateConfiguration() async {
    final logProvider = Provider.of<LogProvider>(context, listen: false);
    try {
      GameConfigurator configurator = GameConfigurator(
        logProvider: logProvider,
        directories: directories,
        gameLocalAppPath: path.join(_gameAppDataController.text, 'Mods'),
        gameModSettingsPath:
            path.join(_gameAppDataController.text, 'PlayerProfiles\\Public'),
        gameDataPath: _gameDataController.text,
        gameBinPath: _gameExeController.text,
        gameExePath: path.join(_gameExeController.text, "bg3.exe"),
        scriptExtenderPath:
            _gameExeController.text, // Assuming this is the same as gameBinPath
      );
      if (_gameAppDataController.text.isEmpty ||
          _gameDataController.text.isEmpty ||
          _gameExeController.text.isEmpty) {
        return showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: backgroundColor,
                title: Text(
                  "Some Fields Are Empty",
                  textAlign: TextAlign.center,
                  style: style3.copyWith(fontSize: 20),
                ),
              );
            });
      }
      // Configure the game
      await configurator.configureGame();

      if (!mounted) return;
      optionDialog.showUpdateManager(context, "Configuration In Progress");
      await Future.delayed(Duration(seconds: 2));
      if (!mounted) return;
      if (optionDialog.isDialogShowing) {
        Navigator.of(context).pop();
      }

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              backgroundColor: backgroundColor,
              child: SizedBox(
                width: 400,
                height: 200,
                child: Center(
                  child: Text(
                    "Game Configuration Successful!",
                    style: style3.copyWith(fontSize: 20),
                  ),
                ),
              ),
            );
          });
    } catch (e) {
      print("Error: $e");
    }
  }

  void _runConfiguration() async {
    final logProvider = Provider.of<LogProvider>(context, listen: false);
    try {
      GameConfigurator configurator = GameConfigurator(
        logProvider: logProvider,
        directories: directories,
        gameLocalAppPath: path.join(directories.getModInstallPath().path,
            r"Larian Studios\Baldur's Gate 3\Mods"),
        gameModSettingsPath: path.join(directories.getModInstallPath().path,
            r"Larian Studios\Baldur's Gate 3\PlayerProfiles\Public"),
        gameDataPath:
            r"C:\Program Files (x86)\Steam\steamapps\common\Baldurs Gate 3\Data",
        gameBinPath:
            r"C:\Program Files (x86)\Steam\steamapps\common\Baldurs Gate 3\bin",
        gameExePath:
            r"C:\Program Files (x86)\Steam\steamapps\common\Baldurs Gate 3\bin\bg3.exe",
        scriptExtenderPath:
            r"C:\Program Files (x86)\Steam\steamapps\common\Baldurs Gate 3\bin", // Assuming this is the same as gameBinPath
      );

      // Configure the game
      await configurator.configureGame();

      await init();

      optionDialog.showUpdateManager(context, "Configuration In Progress");
      await Future.delayed(Duration(seconds: 2));
      if (!mounted) return;
      if (optionDialog.isDialogShowing) {
        Navigator.of(context).pop();
      }

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              backgroundColor: backgroundColor,
              child: SizedBox(
                width: 400,
                height: 200,
                child: Center(
                  child: Text(
                    "Game Configuration Successful!",
                    style: style3.copyWith(fontSize: 20),
                  ),
                ),
              ),
            );
          });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OptionTile(
              title: "How To Use",
              onTap: () {
                optionDialog.instructionDialog(context, () {
                  try {
                    _runConfiguration();
                  } catch (e) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Configure The Game Paths"),
                          content: Container(
                            width: 200,
                            height: 200,
                          ),
                        );
                      },
                    );
                  }
                }, widget.refresh);
              }),
          Gap(8),
          OptionTile(
            title: "Run Configuration",
            onTap: () {
              _runConfiguration();
            },
          ),
          Gap(8),
          OptionTile(
            title: "Custom Configuration",
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: backgroundColor,
                    title: Text(
                      "Configure The Game Paths",
                      style: style3.copyWith(fontSize: 20),
                    ),
                    content: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      width: 500,
                      height: 400,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              CustomTextField(
                                controller: _gameExeController,
                                title: 'Game Exe Path',
                              ),
                              Gap(30),
                              CustomTextField(
                                controller: _gameDataController,
                                title: 'Game Data Path',
                              ),
                              Gap(30),
                              CustomTextField(
                                controller: _gameAppDataController,
                                title: 'Game LocalData Path',
                              ),
                              Gap(10),
                            ],
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: OptionTile(
                              title: "Configure",
                              onTap: () {
                                _updateConfiguration();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          SizedBox(
            height: 8,
          ),
          OptionTile(
              title: "Get Native Loader", onTap: urlLaunch.openNativeMod),
          SizedBox(
            height: 8,
          ),
          OptionTile(
            title: "Get Mod Fixer",
            onTap: urlLaunch.openModFixer,
          ),
          OptionTile(
            title: "Get Script Extender",
            onTap: () async {
              optionDialog.showUpdateManager(
                  context, "Installing Script Extender");
              await Future.delayed(Duration(seconds: 2));
              Process process = await Process.start(
                  path.join(directories.getInstallationDirectory(),
                      'data\\scripts\\installScriptExtender.exe'),
                  []);
              int exitCode = await process.exitCode;
              if (exitCode == 0) {
                if (!context.mounted) return;
                if (optionDialog.isDialogShowing) {
                  Navigator.of(context).pop();
                }
                showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      backgroundColor: backgroundColor,
                      child: Container(
                        width: 400,
                        height: 200,
                        child: Center(
                          child: Text(
                            "Script Extender Installed Successfully",
                            style: style3,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
          OptionTile(
            title: "Open Nexu Mods",
            onTap: urlLaunch.openNexus,
          ),
          SizedBox(
            height: 8,
          ),
          OptionTile(
            title: "Update Manager",
            onTap: () async {
              optionDialog.showUpdateManager(context, "Looking For Updates");
              await Future.delayed(Duration(seconds: 2));
              if (!context.mounted) return;
              if (optionDialog.isDialogShowing) {
                Navigator.of(context).pop();
              }
              optionDialog.updateDialog(context);
            },
          ),
          SizedBox(
            height: 8,
          ),

          OptionTile(
            title: "Refresh Mod List",
            onTap: () {
              widget.refresh();
            },
          ),
          Gap(8),
          OptionTile(
            title: "Launch Game",
            onTap: () async {
              optionDialog.isDialogShowing;
              optionDialog.showUpdateManager(context, "Launching Game");
              await Process.start(gamePaths['game exe path']!, []);
              await Future.delayed(Duration(seconds: 5));
              if (!context.mounted) return;
              if (optionDialog.isDialogShowing) {
                Navigator.of(context).pop();
              }
            },
          ),

          // OptionTile(
          //   title: "Export Order",
          //   onTap: () {
          //     infoManager.getModInfo();
          //   },
          // ),
        ],
      ),
    );
  }
}
