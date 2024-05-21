import 'package:flutter/material.dart';

import '../utils/variables.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required TextEditingController controller,
    required this.title,
  }) : _controller = controller;

  final TextEditingController _controller;
  final String title;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget._controller,
      style: style3.copyWith(),
      cursorColor: hoverColor,
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        labelText: widget.title,
        labelStyle: style3.copyWith(),
        hintStyle: style3.copyWith(),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: BorderSide(color: textColor, width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: BorderSide(color: hoverColor, width: 2.0),
        ),
      ),
    );
  }
}
