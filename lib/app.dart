import 'dart:convert';
import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:general_mod_manager/components/mod_list/mod_list.dart';
import 'package:general_mod_manager/components/options/options.dart';
import 'package:general_mod_manager/models/mod_model.dart';
import 'package:general_mod_manager/services/directory_handler.dart';
import 'package:general_mod_manager/services/game_mod_manager/game_mod_manager.dart';
import 'package:general_mod_manager/services/log_provider.dart';
import 'package:general_mod_manager/services/mod_info_manager/mod_info_manager.dart';
import 'package:general_mod_manager/services/mod_paths.dart';
import 'package:general_mod_manager/utils/variables.dart';
import 'package:general_mod_manager/widgets/FadeInOutLogText_widget.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;
import 'package:restart_app/restart_app.dart';

class BG3APP extends StatelessWidget {
  const BG3APP({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Uncooked Mods',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        splashColor: Colors.transparent,
        iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(
            splashFactory: NoSplash.splashFactory,
          ),
        ),
        highlightColor: Colors.transparent,
      ),
      home: const BaldursGateModManager(),
    );
  }
}

class BaldursGateModManager extends StatefulWidget {
  const BaldursGateModManager({super.key});

  @override
  State<BaldursGateModManager> createState() => _BaldursGateModManagerState();
}

class _BaldursGateModManagerState extends State<BaldursGateModManager> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 30),
            child: MainApp(),
          ),
          WindowTitleBarBox(
            child: Row(
              children: [
                Expanded(
                  child: MoveWindow(),
                ),
                Row(
                  children: [
                    MinimizeWindowButton(
                      colors: WindowButtonColors(
                        mouseOver: textColor,
                        iconNormal: hoverColor,
                      ),
                    ),
                    CloseWindowButton(
                      colors: WindowButtonColors(
                        iconNormal: hoverColor,
                        mouseOver: textColor,
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({
    super.key,
  });

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  ModPaths modInfo = ModPaths();
  List<Map<String, dynamic>> modsData = [];
  List<ModFile> extractedModsData = [];
  late ModInfoManager infoManager;
  late GameModManager manager;
  late LogProvider logProvider;

  Future<void> init() async {
    Directories directories = Directories();
    extractedModsData = await modInfo.loadExtractedModList();
    modsData = await modInfo.loadComplexModList();
    infoManager = ModInfoManager(directories, logProvider);
    manager = GameModManager(directories, logProvider);
    await manager.loadConfig();
    await _loadModList();

    if (mounted) {
      setState(() {
        print(
            "State initialized with modsData: $modsData and extractedModsData: $extractedModsData");
      });
    }
  }

  Future<void> _initializeData() async {
    await init();
  }

  @override
  void initState() {
    _initializeData();
    super.initState();
  }

  Future<void> _loadModList() async {
    await infoManager.getModInfo();
    final aggregatedDataPath = path.join(
      infoManager.directories.getDataFilesPath().path,
      'aggregated_info.json',
    );
    if (await File(aggregatedDataPath).exists()) {
      final content = await File(aggregatedDataPath).readAsString();
      final List<dynamic> data = jsonDecode(content);
      if (mounted) {
        setState(() {
          modsData = data.cast<Map<String, dynamic>>();
        });
        print("modsData updated: $modsData");
      }
    }
  }

  Widget _tempUi(LogProvider logProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (modsData.isNotEmpty)
          Expanded(
            child: ModList(
              logProvider: logProvider,
              orderMode: true,
              modsData: modsData,
              extractedModsData: extractedModsData,
            ),
          )
        else
          Center(
            child: Text("No Data", style: style3),
          ),
        Container(
          width: 2,
          height: 400,
          decoration: BoxDecoration(
            color: Color.fromRGBO(73, 69, 78, 1),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    logProvider = Provider.of<LogProvider>(context);
    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: Drawer(
        width: 400,
        backgroundColor: backgroundColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: OptionList(
            refresh: () async {
              showDialog(
                context: context,
                builder: (context) {
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

              try {
                setState(() {
                  _initializeData();
                });
                await _loadModList();
              } catch (e) {
                print("Error during refresh: $e");
              } finally {
                if (mounted) {
                  setState(() {
                    Navigator.of(context).pop();
                  });
                  // Restart.restartApp();
                }
              }
            },
          ),
        ),
      ),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: backgroundColor,
        toolbarHeight: 80,
        title: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/UncookedMods.svg',
                width: 60,
                height: 60,
              ),
              Gap(40),
              Text(
                "Baldur' Gate 3 Mod Manager",
                style: style3.copyWith(fontSize: 30),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (modsData.isNotEmpty)
                Expanded(
                  child: ModList(
                    key: ObjectKey(modsData),
                    logProvider: logProvider,
                    orderMode: true,
                    modsData: modsData,
                    extractedModsData: extractedModsData,
                  ),
                )
              else
                Center(
                  child: Text("No Data", style: style3),
                ),
              Container(
                width: 2,
                height: 400,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(73, 69, 78, 1),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: FadeInFadeOutText(),
          ),
        ],
      ),
    );
  }
}
