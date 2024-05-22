import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';
import 'package:general_mod_manager/models/mod_model.dart';
import 'package:general_mod_manager/services/log_provider.dart';
import 'package:general_mod_manager/utils/variables.dart';
import 'package:general_mod_manager/widgets/mod_switch/mod_tile_controller.dart';
import 'package:general_mod_manager/widgets/mod_switch/mod_tile_widget.dart';

class ModList extends StatefulWidget {
  const ModList({
    super.key,
    required this.modsData,
    required this.extractedModsData,
    required this.orderMode,
    required this.logProvider,
  });

  final List<Map<String, dynamic>> modsData;
  final List<ModFile> extractedModsData;
  final bool orderMode;
  final LogProvider logProvider;

  @override
  State<ModList> createState() => _ModListState();
}

class _ModListState extends State<ModList> {
  late List<Map<String, dynamic>> inactiveMods;
  late List<Map<String, dynamic>> activeMods;
  late ModTileController controller;

  @override
  void initState() {
    super.initState();
    controller = ModTileController(widget.logProvider);
    _initializeMods();
  }

  void _initializeMods() {
    inactiveMods = [];
    activeMods = [];
    for (var mod in widget.modsData) {
      String archiveName = mod['ArchiveName'];
      bool isActive = widget.extractedModsData
          .any((extractedMod) => extractedMod.name == archiveName);
      mod['isActive'] = isActive;
      if (isActive) {
        activeMods.add(mod);
      } else {
        inactiveMods.add(mod);
      }
    }
  }

  void _toggleMod(Map<String, dynamic> modData, bool isActive) async {
    setState(() {
      modData['isActive'] = !modData['isActive'];
    });
    await Future.delayed(Duration(milliseconds: 100));
    setState(() {
      if (isActive) {
        activeMods.remove(modData);
        inactiveMods.add(modData);
        inactiveMods
            .sort((a, b) => a['ArchiveName'].compareTo(b['ArchiveName']));
      } else {
        inactiveMods.remove(modData);
        activeMods.add(modData);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  "Inactive Mods:",
                  style: style3.copyWith(fontSize: 20),
                ),
                Gap(20),
                Expanded(
                  child: Row(
                    children: [
                      Gap(20),
                      Expanded(
                        child: ListView.builder(
                          itemCount: inactiveMods.length,
                          itemBuilder: (context, index) {
                            return ModTile(
                              key: Key(widget.modsData[index]['ArchiveName']),
                              modData: inactiveMods[index],
                              controller: controller,
                              orderMode: widget.orderMode,
                              onToggle: (bool value) {
                                _toggleMod(inactiveMods[index], false);
                              },
                            );
                          },
                        ),
                      ),
                      Gap(20),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 2,
            height: 400,
            decoration: BoxDecoration(
                color: Color(0xFF726e77),
                borderRadius: BorderRadius.circular(20)),
          ),
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Gap(20),
                    Text(
                      "Order",
                      style: style3.copyWith(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    Gap(35),
                    Text(
                      "of",
                      style: style3.copyWith(),
                      textAlign: TextAlign.center,
                    ),
                    Gap(35),
                    Text(
                      "Active Mods:",
                      style: style3.copyWith(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                Gap(20),
                Expanded(
                  child: ListView.builder(
                    itemCount: activeMods.length,
                    itemBuilder: (context, index) {
                      return Row(
                        children: [
                          Gap(40),
                          Text(
                            index.toString(),
                            style: style3.copyWith(),
                          ),
                          Gap(30),
                          Expanded(
                            child: ModTile(
                              key: Key(widget.modsData[index]['ArchiveName']),
                              modData: activeMods[index],
                              controller: controller,
                              orderMode: widget.orderMode,
                              onToggle: (bool value) {
                                _toggleMod(activeMods[index], true);
                              },
                            ),
                          ),
                          Gap(20),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
