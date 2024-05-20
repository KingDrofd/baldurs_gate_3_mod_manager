import 'package:flutter/material.dart';
import 'package:general_mod_manager/services/directory_handler.dart';
import 'package:general_mod_manager/services/url_launch.dart';
import 'package:general_mod_manager/utils/variables.dart';
import 'package:general_mod_manager/widgets/options/option_tile.dart';

class OptionDialog {
  Directories directories = Directories();
  UrlLaunch urlLaunch = UrlLaunch();
  updateDialog(BuildContext context) async {
    _showUpdateManager(context);
    await Future.delayed(Duration(seconds: 2));
    Navigator.of(context).pop();
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: backgroundColor,
          child: Container(
            width: 400,
            height: 200,
            child: Center(
              child: Text(
                "You are all up to date! ^__^",
                style: style2,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showUpdateManager(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext builder) {
        return Dialog(
          backgroundColor: backgroundColor,
          child: SizedBox(
            width: double.minPositive,
            height: 200,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }

  void instructionDialog(
      BuildContext context, Function onTap, Function refresh) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "How to use the mod manager",
            style: style3.copyWith(fontSize: 20),
          ),
          backgroundColor: backgroundColor,
          content: Container(
            width: 600,
            height: 600,
            child: ListView(
              children: [
                ListTile(
                  title: Text(
                    "First run the configuration button Or ",
                    style: style3,
                  ),
                ),
                ListTile(
                  title: OptionTile(
                    title: "Run It Now!",
                    onTap: () {
                      onTap();
                    },
                  ),
                ),
                ListTile(
                  title: Text(
                    "This will create a folder for mods "
                    "and other data neccessary for the app"
                    " to work.",
                    style: style3,
                  ),
                ),
                ListTile(
                  title: Text(
                    "You will now be able to see the mods folder that was created.",
                    style: style3,
                  ),
                ),
                ListTile(
                  title: OptionTile(
                    title: "Open Mod Folder",
                    onTap: () async {
                      _showUpdateManager(context);
                      await directories.openModsDir();
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                ListTile(
                  title: Text(
                    "That is the folder where you will copy your zipped mod files.",
                    style: style3,
                  ),
                ),
                ListTile(
                  title: Text(
                    "Next you can refresh the mod list by pressing the 'Refresh Mod List' button.",
                    style: style3,
                  ),
                ),
                ListTile(
                  title: OptionTile(
                    title: "Refresh",
                    onTap: () {
                      refresh();
                    },
                  ),
                ),
                ListTile(
                  title: Text(
                    "You can now see your mods on the right.",
                    style: style3,
                  ),
                ),
                ListTile(
                  title: Text(
                    "In case you were wondering how the loading of mod orders work,"
                    "it is based on the order you enable the mods.",
                    style: style3,
                  ),
                ),
                ListTile(
                  title: Text(
                    "Since this is an early build, you should expect"
                    " some issues to happen, please be sure to report it at ",
                    style: style3,
                  ),
                ),
                ListTile(
                  title: OptionTile(
                    title: "Bug Report",
                    onTap: () {
                      urlLaunch.openLink(
                          "https://github.com/KingDrofd/baldurs_gate_3_mod_manager/issues");
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
