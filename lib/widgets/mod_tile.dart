// import 'dart:convert';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:general_mod_manager/services/mod_info_manager/mod_info_manager.dart';
// import 'package:path/path.dart' as path;
// import 'package:general_mod_manager/services/mod_paths.dart';
// import 'package:general_mod_manager/services/directory_handler.dart';
// import 'package:general_mod_manager/services/game_mod_manager.dart';
// import 'package:general_mod_manager/models/mod_model.dart';
// import 'package:general_mod_manager/services/modsettings_modifier.dart';
// import 'package:general_mod_manager/services/script_handler.dart';
// import 'package:general_mod_manager/utils/variables.dart';
// import 'package:xml/xml.dart';

// import '../services/game_mod_manager/game_mod_manager.dart';

// class ModTile extends StatefulWidget {
//   const ModTile(
//       {super.key,
//       required this.modsData,
//       required this.index,
//       required this.extractedModsData,
//       required this.orderMode});
//   final List extractedModsData;
//   final List<Map<String, dynamic>> modsData;
//   final int index;
//   final bool orderMode;

//   @override
//   State<ModTile> createState() => _ModTileState();
// }

// class _ModTileState extends State<ModTile> {
//   List<bool> isSelected = [];
//   Directories directories = Directories();
//   ModPaths modPaths = ModPaths();
//   Map<String, String> modSettingsPath = {};
//   late GameModManager manager;

//   @override
//   void initState() {
//     manager = GameModManager(directories);

//     isSelected = List.generate(widget.modsData.length, (index) {
//       for (ModFile mod in widget.extractedModsData) {
//         if (mod.name == widget.modsData[widget.index]['ArchiveName']) {
//           return true;
//         }
//       }
//       return false;
//     });
//     super.initState();
//   }

//   Future<void> loadConfig() async {
//     String configPath =
//         path.join(directories.getDataFilesPath().path, 'game_config.json');
//     print("Loading config from $configPath");
//     if (await File(configPath).exists()) {
//       String content = await File(configPath).readAsString();
//       Map<String, dynamic> tempGamePaths = jsonDecode(content);
//       modSettingsPath =
//           tempGamePaths.map((key, value) => MapEntry(key, value.toString()));
//       print("Configuration loaded: $modSettingsPath");
//     } else {
//       print("Configuration file not found at $configPath.");
//       throw Exception("Configuration file not found.");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: SwitchListTile(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
//         hoverColor: const Color.fromARGB(54, 0, 0, 0),
//         trackColor: MaterialStateProperty.resolveWith((states) {
//           if (states.contains(MaterialState.selected)) {
//             return hoverColor;
//           } else {
//             return backgroundColor;
//           }
//         }),
//         title: Text(
//           widget.modsData[widget.index]['Mods'][0]['Name'],
//           style: isSelected[widget.index]
//               ? style2.copyWith(color: hoverColor)
//               : style2.copyWith(),
//           textAlign: TextAlign.center,
//         ),
//         value: isSelected[widget.index],
//         onChanged: (bool value) async {
//           setState(() {
//             isSelected[widget.index] = value;
//           });
//           await loadConfig();
//           ModifyModsetting modifyModsetting = ModifyModsetting();
//           final modSettingsFile = File(path.join(
//               modSettingsPath['game mod settings path']!, 'modsettings.lsx'));
//           final document =
//               XmlDocument.parse(modSettingsFile.readAsStringSync());
//           if (value == true) {
//             String? modFolder = await manager
//                 .extractMod(widget.modsData[widget.index]['ArchiveName']);
//             if (modFolder != null) {
//               // Get the paths of extracted files
//               List<String> extractedPaths = [];
//               await for (var entity
//                   in Directory(modFolder).list(recursive: true)) {
//                 if (entity is File) {
//                   extractedPaths.add(entity.path);
//                 }
//               }
//               // Save the extracted information
//               await manager.saveExtractedPaths(
//                   widget.modsData[widget.index]['ArchiveName'], extractedPaths);
//               print(
//                   "Extracted paths saved for ${widget.modsData[widget.index]['ArchiveName']}");

//               // Append mod info to a new file
//               await manager
//                   .appendModInfo(widget.modsData[widget.index]['ArchiveName']);
//               print(
//                   "Mod info appended for ${widget.modsData[widget.index]['ArchiveName']}");

//               modifyModsetting.addMod(
//                   document,
//                   widget.modsData[widget.index]['Mods'][0]['Description'] ?? '',
//                   widget.modsData[widget.index]['Mods'][0]['Folder'] ?? '',
//                   widget.modsData[widget.index]['MD5'] ?? '',
//                   widget.modsData[widget.index]['Mods'][0]['Name'] ?? '',
//                   widget.modsData[widget.index]['Mods'][0]['UUID'] ?? '',
//                   widget.modsData[widget.index]['Mods'][0]['Version'] ?? '',
//                   widget.orderMode);
//             }
//           } else {
//             await manager
//                 .deleteMods(widget.modsData[widget.index]['ArchiveName']);

//             modifyModsetting.removeMod(
//                 document,
//                 widget.modsData[widget.index]['Mods'][0]['UUID'],
//                 widget.orderMode);
//           }
//           modifyModsetting.saveDocument(
//               document,
//               path.join(modSettingsPath['game mod settings path']!,
//                   'modsettings.lsx'));
//         },
//       ),
//     );
//   }
// }
