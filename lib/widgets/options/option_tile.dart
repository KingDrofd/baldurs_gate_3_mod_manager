import 'package:flutter/material.dart';
import 'package:general_mod_manager/utils/variables.dart';

class OptionTile extends StatefulWidget {
  final String title;
  final Function() onTap;

  const OptionTile({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  State<OptionTile> createState() => _OptionTileState();
}

class _OptionTileState extends State<OptionTile> {
  bool isHovered = false;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        widget.title,
        style:
            isHovered ? style2.copyWith(color: hoverColor) : style2.copyWith(),
        textAlign: TextAlign.center,
      ),
      shape: borderShape,
      hoverColor: textColor,
      onTap: () {
        widget.onTap();
      },
    );
  }
}
