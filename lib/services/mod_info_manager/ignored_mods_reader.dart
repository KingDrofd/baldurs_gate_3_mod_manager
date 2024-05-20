import 'dart:convert';
import 'dart:io';
import '../directory_handler.dart';
import '../log_provider.dart';

class IgnoredModsReader {
  final Directories directories;
  final LogProvider logProvider;

  IgnoredModsReader(this.directories, this.logProvider);

  Future<List<Map<String, dynamic>>> readIgnoredMods() async {
    final file =
        File('${directories.getDataFilesPath().path}/Ignore_mods.json');
    if (await file.exists()) {
      final contents = await file.readAsString();
      final List<dynamic> ignoredMods =
          jsonDecode(contents)['Mods'] as List<dynamic>;

      return ignoredMods.cast<Map<String, dynamic>>();
    } else {
      logProvider.addLog('Ignored mods file not found at ${file.path}');
      return [];
    }
  }
}
