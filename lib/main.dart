import 'package:flutter/material.dart';
import 'package:general_mod_manager/components/modList/mod_list.dart';
import 'package:general_mod_manager/components/options/options.dart';
import 'package:general_mod_manager/services/directory_handler.dart';
import 'package:general_mod_manager/services/modsProcess/mod_info_process.dart';
import 'package:general_mod_manager/services/modsProcess/mod_model.dart';

import 'package:general_mod_manager/utils/variables.dart';

void main() {
  runApp(const MyApp());
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
          highlightColor: Colors.transparent),
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
  Directories directories = Directories();
  ModInfo modInfo = ModInfo();
  List modsData = [];
  List<Mod> extractedModsData = [];
  // Future fetchEntry() async {
  //   final url = Uri.parse('API HERE');
  //   final response = await http.get(url);
  //   if (response.statusCode == 200) {
  //     var content = jsonDecode(response.body);
  //     setState(() {
  //       messageData = content['message'];
  //     });

  //     print(messageData);
  //     return messageData;
  //   } else {
  //     print('Failed to fetch data');
  //   }
  // }

  void _init() async {
    modsData = await modInfo.loadModList();
    extractedModsData = await modInfo.loadExtractedModList();
    print(directories.getScriptFilesPath().path);
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  bool isHovered = false;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: backgroundColor,
        title: Center(
          child: Text(
            "Baldur's Gate 3 Mod Manager",
            style: style3.copyWith(fontSize: 40),
          ),
        ),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          modsData.isNotEmpty
              ? Center(
                  child: ModList(
                      modsData: modsData, extractedModsData: extractedModsData),
                )
              : Center(
                  child: Text("No Data", style: style3),
                ),
          SizedBox(
            width: 100,
          ),
          OptionList(),
        ],
      ),
    );
  }
}
