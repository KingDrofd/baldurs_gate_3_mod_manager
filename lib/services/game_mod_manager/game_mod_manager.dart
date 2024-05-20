import 'config_loader.dart';
import 'mod_extractor.dart';
import 'path_saver.dart';
import 'mod_info_appender.dart';
import 'mod_deleter.dart';
import '../directory_handler.dart';
import '../log_provider.dart';

class GameModManager {
  final ConfigLoader configLoader;
  final ModExtractor modExtractor;
  final PathSaver pathSaver;
  final ModInfoAppender modInfoAppender;
  final ModDeleter fileDeleter;
  final LogProvider logProvider;

  GameModManager(Directories directories, this.logProvider)
      : configLoader = ConfigLoader(directories, logProvider),
        modExtractor = ModExtractor(directories, logProvider),
        pathSaver = PathSaver(directories),
        modInfoAppender = ModInfoAppender(directories, logProvider),
        fileDeleter = ModDeleter(directories, logProvider);

  Future<void> loadConfig() => configLoader.loadConfig();

  Future<String?> extractMod(String modName) =>
      modExtractor.extractMod(modName);

  Future<void> saveExtractedPaths(
          String modName, List<String> extractedPaths) =>
      pathSaver.saveExtractedPaths(modName, extractedPaths);

  Future<void> appendModInfo(String modName) =>
      modInfoAppender.appendModInfo(modName);

  Future<void> deleteFilesFromJson(String modName) =>
      fileDeleter.deleteFilesFromJson(modName);
}
