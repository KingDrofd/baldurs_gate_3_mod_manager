import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:general_mod_manager/services/log_provider.dart';
import '../../utils/variables.dart';
import 'mod_tile_controller.dart';

class ModTile extends StatefulWidget {
  const ModTile({
    super.key,
    required this.modsData,
    required this.index,
    required this.extractedModsData,
    required this.orderMode,
    required this.logProvider,
  });

  final List extractedModsData;
  final List<Map<String, dynamic>> modsData;
  final int index;
  final bool orderMode;
  final LogProvider logProvider;

  @override
  State<ModTile> createState() => _ModTileState();
}

class _ModTileState extends State<ModTile> {
  List<bool> isSelected = [];
  late ModTileController controller;
  int increment = 0;
  @override
  void initState() {
    controller = ModTileController(widget.logProvider);
    isSelected = List.generate(widget.modsData.length, (index) {
      for (var mod in widget.extractedModsData) {
        if (mod.name == widget.modsData[widget.index]['ArchiveName']) {
          return true;
        }
      }
      return false;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: 500,
        child: SwitchListTile(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          hoverColor: const Color.fromARGB(54, 0, 0, 0),
          trackColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return hoverColor;
            } else {
              return backgroundColor;
            }
          }),
          title: Text(
            widget.modsData[widget.index]['Mods'][0]['Name'],
            style: isSelected[widget.index]
                ? style2.copyWith(color: hoverColor)
                : style2.copyWith(),
            textAlign: TextAlign.center,
          ),
          value: isSelected[widget.index],
          onChanged: (bool value) async {
            setState(() {
              isSelected[widget.index] = value;
            });
            await controller.handleModToggle(
                value, widget.modsData[widget.index], widget.orderMode);
          },
        ),
      ),
    );
  }
}
