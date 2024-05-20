// import 'dart:convert';
// import 'dart:io';
// import 'package:general_mod_manager/services/directory_handler.dart';
// import 'package:path/path.dart' as path;
// import 'package:archive/archive.dart';
// import 'package:archive/archive_io.dart';
// import '../utils/useful_functions.dart';

// class GameModManager {
//   Directories directories;
//   Map<String, String> gamePaths = {};

//   GameModManager(this.directories);

//   Future<void> loadConfig() async {
//     String configPath =
//         path.join(directories.getDataFilesPath().path, 'game_config.json');
//     print("Loading config from $configPath");
//     if (await File(configPath).exists()) {
//       String content = await File(configPath).readAsString();
//       Map<String, dynamic> tempGamePaths = jsonDecode(content);
//       gamePaths =
//           tempGamePaths.map((key, value) => MapEntry(key, value.toString()));
//       print("Configuration loaded: $gamePaths");
//     } else {
//       print("Configuration file not found at $configPath.");
//       throw Exception("Configuration file not found.");
//     }
//   }

//   Future<String?> extractMod(String modName) async {
//     await loadConfig();
//     String modZip = '$modName.zip';
//     String? modFolder = gamePaths['game localappdata path'];

//     if (modFolder == null) {
//       print("Game localappdata path is not defined in the configuration.");
//       return null;
//     }

//     String modPath = path.join(directories.getModFilesPath().path, modZip);

//     if (!await File(modPath).exists()) {
//       print("Mod zip file not found: $modPath");
//       return null;
//     }

//     List<int> bytes = await File(modPath).readAsBytes();
//     Archive archive = ZipDecoder().decodeBytes(bytes);

//     // Check if the archive has a single top-level folder
//     String? topLevelFolder;
//     Set<String> topLevelFolders = {};

//     for (var file in archive.files) {
//       String topLevel = file.name.split('/').first;
//       topLevelFolders.add(topLevel);
//     }

//     if (topLevelFolders.length == 1) {
//       topLevelFolder = topLevelFolders.first;
//     }

//     for (ArchiveFile file in archive) {
//       String filePath;
//       if (topLevelFolder != null) {
//         filePath = path.join(
//             modFolder, file.name.replaceFirst('$topLevelFolder/', ''));
//       } else {
//         filePath = path.join(modFolder, file.name);
//       }

//       if (file.isFile) {
//         File(filePath)
//           ..createSync(recursive: true)
//           ..writeAsBytesSync(file.content as List<int>);
//       } else {
//         Directory(filePath).createSync(recursive: true);
//       }
//     }

//     print("Mod extracted: $modFolder");
//     return modFolder;
//   }

//   Future<void> saveExtractedPaths(
//       String modName, List<String> extractedPaths) async {
//     String saveFile =
//         path.join(directories.getDataFilesPath().path, "extracted_info.json");
//     Map<String, dynamic> data = {};

//     if (await File(saveFile).exists()) {
//       String content = await File(saveFile).readAsString();
//       if (content.isNotEmpty) {
//         data = json.decode(content);
//       }
//     }

//     for (String existingMod in data.keys) {
//       List<String> existingPaths = List<String>.from(data[existingMod]);
//       extractedPaths.removeWhere((path) => existingPaths.contains(path));
//     }

//     data[modName] = (data[modName] ?? [])..addAll(extractedPaths);

//     await File(saveFile).writeAsString(json.encode(data),
//         flush: true, mode: FileMode.writeOnly);
//   }

//   Future<void> appendModInfo(String modName) async {
//     String modZip = '$modName.zip';
//     String modZipPath = path.join(directories.getModFilesPath().path, modZip);
//     Map<String, dynamic> modInfoDict = {};

//     if (await File(modZipPath).exists()) {
//       String? modFolder = await extractMod(modName);

//       if (modFolder != null) {
//         String infoFile = path.join(modFolder, "info.json");
//         if (await File(infoFile).exists()) {
//           print("Info file exists for $modName");
//           String content = await File(infoFile).readAsString();
//           Map<String, dynamic> modInfo = json.decode(content);
//           modInfoDict[modName] = modInfo;
//         } else {
//           print(
//               "info.json file not found in the extracted folder for $modName");
//         }
//       }
//     } else {
//       print("Mod zip file not found for $modName");
//       return;
//     }

//     try {
//       String modsInfoFile =
//           path.join(directories.getDataFilesPath().path, "mods_info.json");
//       Map<String, dynamic> data = {};

//       if (await File(modsInfoFile).exists()) {
//         String content = await File(modsInfoFile).readAsString();
//         if (content.isNotEmpty) {
//           data = json.decode(content);
//         }
//       }

//       data.addAll(modInfoDict);

//       await File(modsInfoFile).writeAsString(json.encode(data),
//           flush: true, mode: FileMode.writeOnly);
//       print("Mod info appended to $modsInfoFile");
//     } catch (e) {
//       print("Error occurred while appending mod info: $e");
//     }
//   }

//   Future<void> deleteFilesFromJson(String modName) async {
//     String extractedInfoFile =
//         path.join(directories.getDataFilesPath().path, "extracted_info.json");
//     String modsInfoFile =
//         path.join(directories.getDataFilesPath().path, "mods_info.json");

//     if (!await File(extractedInfoFile).exists()) {
//       print("JSON file '$extractedInfoFile' not found.");
//       return;
//     }

//     String content = await File(extractedInfoFile).readAsString();
//     Map<String, dynamic> data = json.decode(content);

//     if (!data.containsKey(modName)) {
//       print("Mod '$modName' not found in the JSON file.");
//       return;
//     }

//     List<dynamic> paths = data[modName];
//     for (String path in paths) {
//       if (await Directory(path).exists()) {
//         await deleteDirectoryContents(path);
//         await Directory(path).delete();
//         print("Deleted directory: $path");
//       } else if (await File(path).exists()) {
//         await File(path).delete();
//         print("Deleted file: $path");
//       } else {
//         print("Path does not exist: $path");
//       }
//     }

//     data.remove(modName);

//     await File(extractedInfoFile).writeAsString(json.encode(data),
//         flush: true, mode: FileMode.writeOnly);

//     if (await File(modsInfoFile).exists()) {
//       String modsInfoContent = await File(modsInfoFile).readAsString();
//       if (modsInfoContent.isNotEmpty) {
//         Map<String, dynamic> modsInfoData = json.decode(modsInfoContent);
//         modsInfoData.remove(modName);
//         await File(modsInfoFile).writeAsString(json.encode(modsInfoData),
//             flush: true, mode: FileMode.writeOnly);
//         print("Mod info removed from $modsInfoFile");
//       }
//     }
//   }

//   Future<void> deleteDirectoryContents(String directory) async {
//     Directory dir = Directory(directory);
//     if (await dir.exists()) {
//       await for (FileSystemEntity entity in dir.list(recursive: false)) {
//         if (entity is Directory) {
//           await deleteDirectoryContents(entity.path);
//           await entity.delete();
//           print("Deleted directory: ${entity.path}");
//         } else if (entity is File) {
//           await entity.delete();
//           print("Deleted file: ${entity.path}");
//         }
//       }
//     }
//   }
// }
