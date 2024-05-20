import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:general_mod_manager/models/mod_info_model.dart';
import 'package:general_mod_manager/services/log_provider.dart';
import 'package:general_mod_manager/services/mod_info_manager/mod_info_manager.dart';
import 'package:general_mod_manager/services/mod_paths.dart';
import 'package:general_mod_manager/services/directory_handler.dart';
import 'package:general_mod_manager/services/game_configurator.dart';
import 'package:general_mod_manager/services/script_handler.dart';

import 'package:general_mod_manager/services/url_launch.dart';
import 'package:general_mod_manager/utils/useful_functions.dart';
import 'package:general_mod_manager/utils/variables.dart';
import 'package:general_mod_manager/widgets/options/option_dialog.dart';
import 'package:general_mod_manager/widgets/options/option_tile.dart';
import 'package:provider/provider.dart';

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
  List order = [];
  int increment = 1;
  @override
  void initState() {
    final logProvider = Provider.of<LogProvider>(context, listen: false);
    infoManager = ModInfoManager(directories, logProvider);
    super.initState();
  }

  void increaseOrder() {
    order.add(increment++);
  }

  void showConfigurationDialog() async {
    showDialog(
        context: context,
        builder: (BuildContext builder) {
          return Dialog(
            backgroundColor: backgroundColor,
            child: const SizedBox(
              width: double.minPositive,
              height: 200,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        });
  }

  void _runConfiguration() async {
    final logProvider = Provider.of<LogProvider>(context, listen: false);
    try {
      GameConfigurator configurator = GameConfigurator(
        logProvider: logProvider,
        directories: directories,
        gameLocalAppPath: r"Larian Studios\Baldur's Gate 3\Mods",
        gameModSettingsPath:
            r"Larian Studios\Baldur's Gate 3\PlayerProfiles\Public",
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

      showConfigurationDialog();
      await Future.delayed(Duration(seconds: 2));
      if (!mounted) return;
      Navigator.of(context).pop();

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
                  _runConfiguration();
                }, widget.refresh);
              }),
          Gap(8),
          OptionTile(
            title: "Run Configuration",
            onTap: () {
              _runConfiguration();
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
            title: "Open Nexu Mods",
            onTap: urlLaunch.openNexus,
          ),
          SizedBox(
            height: 8,
          ),
          OptionTile(
            title: "Update Manager",
            onTap: () {
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

          OptionTile(
            title: "Increase order",
            onTap: () {
              setState(() {
                increaseOrder();
              });
              final logProvider =
                  Provider.of<LogProvider>(context, listen: false);
              logProvider.addLog(order.last.toString());
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
