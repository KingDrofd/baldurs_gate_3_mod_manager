import 'package:flutter/material.dart';
import 'package:general_mod_manager/models/mod_model.dart';
import 'package:general_mod_manager/services/log_provider.dart';

import '../../widgets/mod_switch/mod_tile_widget.dart';

class ModList extends StatelessWidget {
  const ModList(
      {super.key,
      required this.modsData,
      required this.extractedModsData,
      required this.orderMode,
      required this.logProvider});

  final List<Map<String, dynamic>> modsData;
  final List<ModFile> extractedModsData;
  final bool orderMode;
  final LogProvider logProvider;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 850,
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: modsData.length,
        itemBuilder: (context, index) {
          return ModTile(
            logProvider: logProvider,
            orderMode: orderMode,
            modsData: modsData,
            index: index,
            extractedModsData: extractedModsData,
          );
        },
      ),
    );
  }
}
