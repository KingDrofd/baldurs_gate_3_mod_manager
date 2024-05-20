import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import '../directory_handler.dart';

class PathSaver {
  final Directories directories;

  PathSaver(this.directories);

  Future<void> saveExtractedPaths(
      String modName, List<String> extractedPaths) async {
    String saveFile =
        path.join(directories.getDataFilesPath().path, "extracted_info.json");
    Map<String, dynamic> data = {};

    if (await File(saveFile).exists()) {
      String content = await File(saveFile).readAsString();
      if (content.isNotEmpty) {
        data = json.decode(content);
      }
    }

    for (String existingMod in data.keys) {
      List<String> existingPaths = List<String>.from(data[existingMod]);
      extractedPaths.removeWhere((path) => existingPaths.contains(path));
    }

    data[modName] = (data[modName] ?? [])..addAll(extractedPaths);

    await File(saveFile).writeAsString(json.encode(data),
        flush: true, mode: FileMode.writeOnly);
  }
}
