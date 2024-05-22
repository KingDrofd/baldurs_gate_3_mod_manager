import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:general_mod_manager/app.dart';
import 'package:provider/provider.dart';
import 'services/log_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => LogProvider(),
      child: const BG3APP(),
    ),
  );
  doWhenWindowReady(() {
    const initialSize = Size(900, 700);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.title = "Uncooked Mods";

    appWindow.show();
  });
}
