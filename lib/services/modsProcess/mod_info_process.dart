import 'dart:convert';
import 'dart:io';

import 'package:general_mod_manager/services/modsProcess/mod_model.dart';
import 'package:general_mod_manager/utils/dir_paths.dart';

class ModInfo {
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

  Future<List<Mod>> loadExtractedModList() async {
    try {
      var dataFile = await File(extractedModsInfo).readAsString();
      var data = jsonDecode(dataFile) as Map<String, dynamic>;
      List<Mod> mods = [];
      data.forEach((key, value) {
        mods.add(Mod.fromJson({key: value}));
      });
      return mods;
    } catch (e) {
      print(e);
      return [];
    }
  }
}
