import 'dart:convert';
import 'dart:io';
import 'package:general_mod_manager/services/directory_handler.dart';
import 'package:path/path.dart' as path;
import 'archive_processor.dart';
import 'info_creator.dart';
import 'ignored_mods_reader.dart';
import '../log_provider.dart';

class ModInfoManager {
  final Directories directories;
  final ArchiveProcessor archiveProcessor;
  final InfoCreator infoCreator;
  final IgnoredModsReader ignoredModsReader;
  final LogProvider logProvider;

  ModInfoManager(this.directories, this.logProvider)
      : archiveProcessor = ArchiveProcessor(directories, logProvider),
        infoCreator = InfoCreator(directories, logProvider),
        ignoredModsReader = IgnoredModsReader(directories, logProvider);

  Future<void> getModInfo() async {
    final dir = Directory(directories.getModFilesPath().path);
    final List<FileSystemEntity> entities = await dir.list().toList();
    List<Map<String, dynamic>> infoDataList = [];

    final ignoredMods = await ignoredModsReader.readIgnoredMods();
    // logProvider.addLog('Ignored Mods: $ignoredMods');

    for (var entity in entities) {
      if (entity is File) {
        try {
          final archiveData =
              await archiveProcessor.processFile(entity, ignoredMods);
          if (archiveData != null) {
            infoDataList.add(archiveData);
          }
        } catch (e) {
          logProvider.addLog("Error processing ${entity.path}: $e");
        }
      }
    }

    final aggregatedData = jsonEncode(infoDataList);
    final outputFile = File(
        path.join(directories.getDataFilesPath().path, 'aggregated_info.json'));
    await outputFile.writeAsString(aggregatedData);

    logProvider.addLog('Aggregated data written to ${outputFile.path}');
  }
}
