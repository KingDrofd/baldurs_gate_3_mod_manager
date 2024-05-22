import 'package:flutter/material.dart';

import 'package:general_mod_manager/utils/variables.dart';
import 'mod_tile_controller.dart';

class ModTile extends StatefulWidget {
  const ModTile({
    super.key,
    required this.modData,
    required this.controller,
    required this.orderMode,
    required this.onToggle,
  });

  final Map<String, dynamic> modData;
  final ModTileController controller;
  final bool orderMode;
  final void Function(bool value) onToggle;

  @override
  State<ModTile> createState() => _ModTileState();
}

class _ModTileState extends State<ModTile> {
  @override
  Widget build(BuildContext context) {
    final isSelected = widget.modData['isActive'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: 500,
        child: SwitchListTile(
          key: ObjectKey(widget.modData),
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
            widget.modData['Mods'][0]['Name'],
            style: isSelected
                ? style2.copyWith(color: hoverColor)
                : style2.copyWith(),
            textAlign: TextAlign.center,
          ),
          value: isSelected,
          onChanged: (bool value) async {
            setState(() {
              widget.onToggle(value);
            });

            await widget.controller.handleModToggle(
                value, widget.modData, widget.orderMode, context);
          },
        ),
      ),
    );
  }
}
