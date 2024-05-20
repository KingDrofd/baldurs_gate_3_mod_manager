import 'package:flutter/material.dart';
import 'package:general_mod_manager/services/directory_handler.dart';
import 'package:general_mod_manager/widgets/FadeInOutLogText_widget.dart';
import 'package:provider/provider.dart';
import 'services/log_provider.dart';
import 'components/mod_list/mod_list.dart';
import 'components/options/options.dart';
import 'services/mod_paths.dart';
import 'services/mod_info_manager/mod_info_manager.dart';
import 'services/game_mod_manager/game_mod_manager.dart';
import 'utils/variables.dart';
import 'models/mod_model.dart';
import 'package:path/path.dart' as path;
import 'dart:convert';
import 'dart:io';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => LogProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ModPaths modInfo = ModPaths();
  List<Map<String, dynamic>> modsData = [];
  List<ModFile> extractedModsData = [];
  late ModInfoManager infoManager;
  late GameModManager manager;
  late LogProvider logProvider;

  void _refreshList() async {
    infoManager.getModInfo();
    extractedModsData = await modInfo.loadExtractedModList();
    modsData = await modInfo.loadComplexModList();
  }

  void init() async {
    Directories directories = Directories();
    extractedModsData = await modInfo.loadExtractedModList();
    modsData = await modInfo.loadComplexModList();

    infoManager = ModInfoManager(directories, logProvider);
    manager = GameModManager(directories, logProvider);
    manager.loadConfig().then((_) {
      setState(() {});
    }).catchError((e) {
      setState(() {});
    });
  }

  @override
  void initState() {
    init();
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    logProvider = Provider.of<LogProvider>(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        toolbarHeight: 80,
        title: Center(
          child: Text(
            "Baldur' Gate 3 Mod Manager",
            style: style3.copyWith(fontSize: 30),
          ),
        ),
      ),
      body: Stack(
        children: [
          _tempUi(logProvider),
          Align(
            alignment: Alignment.bottomLeft,
            child: FadeInFadeOutText(),
          ),
        ],
      ),
    );
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
        SizedBox(
          width: 100,
        ),
        OptionList(
          refresh: () async {
            showDialog(
              context: context,
              builder: (BuildContext context) {
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
            await _loadModList();
            if (!mounted) return;
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
