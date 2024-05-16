import 'package:flutter/material.dart';
import 'package:general_mod_manager/services/modsProcess/mod_model.dart';
import 'package:general_mod_manager/services/script_handler.dart';
import 'package:general_mod_manager/utils/variables.dart';

class ModTile extends StatefulWidget {
  const ModTile({
    super.key,
    required this.modsData,
    required this.index,
    required this.extractedModsData,
  });
  final List extractedModsData;
  final List modsData;
  final int index;

  @override
  State<ModTile> createState() => _ModTileState();
}

class _ModTileState extends State<ModTile> {
  List<bool> isSelected = [];

  Scripts scripts = Scripts();
  // Future<void> _sendData(String name, bool isCopied) async {
  //   try {
  //     var url = Uri.parse("api");
  //     var headers = {"Content-Type": "application/json"};
  //     var body = jsonEncode({"name": name, "copied": isCopied});
  //     var response = await http.post(url, headers: headers, body: body);
  //     if (response.statusCode == 200) {
  //       // Data sent successfully
  //       print("Data sent successfully");
  //     } else {
  //       // Failed to send data
  //       print("Failed to send data");
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  // }
  @override
  void initState() {
    isSelected = List.generate(widget.modsData.length, (index) {
      for (Mod mod in widget.extractedModsData) {
        if (mod.name == widget.modsData[widget.index]['name']) {
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
      child: SwitchListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        hoverColor: const Color.fromARGB(54, 0, 0, 0),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return hoverColor;
          } else {
            return backgroundColor;
          }
        }),
        title: Text(
          widget.modsData[widget.index]['name'],
          style: isSelected[widget.index]
              ? style2.copyWith(color: hoverColor)
              : style2.copyWith(),
          textAlign: TextAlign.center,
        ),
        value: isSelected[widget.index],
        onChanged: (bool value) {
          setState(() {
            isSelected[widget.index] = value;
          });

          if (value == true) {
            scripts.installMod(widget.modsData[widget.index]['name']);
          } else {
            scripts.uninstallMod(widget.modsData[widget.index]['name']);
          }
        },
      ),
    );
  }
}
