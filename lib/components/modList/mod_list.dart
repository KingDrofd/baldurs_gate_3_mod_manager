import 'package:flutter/material.dart';
import 'package:general_mod_manager/services/modsProcess/mod_model.dart';
import 'package:general_mod_manager/widgets/mod_tile.dart';

class ModList extends StatelessWidget {
  const ModList({
    super.key,
    required this.modsData,
    required this.extractedModsData,
  });

  final List modsData;
  final List<Mod> extractedModsData;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 850,
      padding: const EdgeInsets.all(8),
      alignment: Alignment.centerLeft,
      child: ListView.builder(
        itemCount: modsData.length,
        itemBuilder: (context, index) {
          return ModTile(
            modsData: modsData,
            index: index,
            extractedModsData: extractedModsData,
          );
        },
      ),
    );
  }
}
