import 'package:url_launcher/url_launcher.dart';

class UrlLaunch {
  void openLink(String url) {
    try {
      final uri = Uri.parse(url);
      launchUrl(uri);
    } catch (e) {
      print(e);
    }
  }

  void openNexus() {
    openLink("https://www.nexusmods.com/baldursgate3/");
  }

  void openNativeMod() {
    openLink("https://www.nexusmods.com/baldursgate3/mods/944");
  }
}
