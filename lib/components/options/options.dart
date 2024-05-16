import 'dart:async';

import 'package:flutter/material.dart';
import 'package:general_mod_manager/services/directory_handler.dart';
import 'package:general_mod_manager/services/modsProcess/mod_info_process.dart';
import 'package:general_mod_manager/services/url_launch.dart';
import 'package:general_mod_manager/utils/useful_functions.dart';
import 'package:general_mod_manager/utils/variables.dart';
import 'package:general_mod_manager/widgets/options/option_dialog.dart';
import 'package:general_mod_manager/widgets/options/option_tile.dart';

class OptionList extends StatefulWidget {
  const OptionList({super.key});

  @override
  State<OptionList> createState() => _OptionListState();
}

class _OptionListState extends State<OptionList> {
  OptionDialog optionDialog = OptionDialog();
  UrlLaunch urlLaunch = UrlLaunch();
  Directories directories = Directories();
  ModInfo modsInfo = ModInfo();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: ListView(
        children: [
          SizedBox(
            height: 8,
          ),
          OptionTile(
              title: "Get Native Loader", onTap: urlLaunch.openNativeMod),
          SizedBox(
            height: 8,
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
              modsInfo.loadModList();
            },
          ),
          OptionTile(
            title: "Check Directory",
            onTap: () {
              print(checkFile(
                  "${directories.getScriptFilesPath().path}\\installMod.exe"));
              print(checkFile(
                  "${directories.getScriptFilesPath().path}\\removeMod.exe"));
            },
          ),
        ],
      ),
    );
  }
}