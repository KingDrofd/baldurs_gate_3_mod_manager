import 'dart:convert';
import 'dart:io';

import 'package:general_mod_manager/services/directory_handler.dart';
import 'package:general_mod_manager/models/mod_model.dart';
import 'package:general_mod_manager/utils/dir_paths.dart';

class ModPaths {
  Directories directories = Directories();

  Future<List> loadModList() async {
    try {
      var dataFile = await File(modsInfo).readAsString();
      var data = jsonDecode(dataFile);

      return data;
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> loadComplexModList() async {
    try {
      var dataFile = await File(
              '${directories.getDataFilesPath().path}\\aggregated_info.json')
          .readAsString();
      var data = jsonDecode(dataFile);
      var modList = data.cast<Map<String, dynamic>>();

      return modList;
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<List<ModFile>> loadExtractedModList() async {
    try {
      var dataFile = await File(
              '${directories.getDataFilesPath().path}\\extracted_info.json')
          .readAsString();
      var data = jsonDecode(dataFile) as Map<String, dynamic>;
      List<ModFile> mods = [];
      data.forEach((key, value) {
        mods.add(ModFile.fromJson({key: value}));
      });
      return mods;
    } catch (e) {
      print(e);
      return [];
    }
  }
}
