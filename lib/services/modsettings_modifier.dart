import 'dart:io';
import 'package:xml/xml.dart';

class ModifyModsetting {
  // Function to create a new node for Mods
  XmlElement createModNode(String modDescription, String modFolder,
      String modMD5, String modName, String modUuid, String modVersion) {
    return XmlElement(XmlName('node'), [
      XmlAttribute(XmlName('id'), modDescription)
    ], [
      XmlElement(XmlName('attribute'), [
        XmlAttribute(XmlName('id'), 'Folder'),
        XmlAttribute(XmlName('value'), modFolder),
        XmlAttribute(XmlName('type'), 'LSString')
      ]),
      XmlElement(XmlName('attribute'), [
        XmlAttribute(XmlName('id'), 'MD5'),
        XmlAttribute(XmlName('value'), modMD5),
        XmlAttribute(XmlName('type'), 'LSString')
      ]),
      XmlElement(XmlName('attribute'), [
        XmlAttribute(XmlName('id'), 'Name'),
        XmlAttribute(XmlName('value'), modName),
        XmlAttribute(XmlName('type'), 'LSString')
      ]),
      XmlElement(XmlName('attribute'), [
        XmlAttribute(XmlName('id'), 'UUID'),
        XmlAttribute(XmlName('value'), modUuid),
        XmlAttribute(XmlName('type'), 'FixedString')
      ]),
      XmlElement(XmlName('attribute'), [
        XmlAttribute(XmlName('id'), 'Version64'),
        XmlAttribute(XmlName('value'), modVersion),
        XmlAttribute(XmlName('type'), 'int64')
      ])
    ]);
  }

  // Function to create a new node for ModOrder
  XmlElement createModOrderNode(String modUuid) {
    return XmlElement(XmlName('node'), [
      XmlAttribute(XmlName('id'), 'Module')
    ], [
      XmlElement(XmlName('attribute'), [
        XmlAttribute(XmlName('id'), 'UUID'),
        XmlAttribute(XmlName('value'), modUuid),
        XmlAttribute(XmlName('type'), 'FixedString')
      ])
    ]);
  }

  void removeNode(XmlElement node, String value) {
    for (var child in node.findElements('node').toList()) {
      for (var attribute in child
          .findElements('attribute')
          .where((e) => e.getAttribute('id') == 'UUID')) {
        if (attribute.getAttribute('value') == value) {
          node.children.remove(child);
        }
      }
      removeNode(child, value);
    }
  }

  void addMod(
      XmlDocument document,
      String modDescription,
      String modFolder,
      String modMD5,
      String modName,
      String modUuid,
      String modVersion,
      bool orderMode) {
    final root = document.rootElement;
    final modsNode = root
        .findAllElements('node')
        .firstWhere((node) => node.getAttribute('id') == 'Mods')
        .findElements('children')
        .first;

    final newNode = createModNode(
        modDescription, modFolder, modMD5, modName, modUuid, modVersion);

    modsNode.children.add(newNode);
    if (!orderMode) return;
    addModOrder(document, modUuid);
    print("Mod added successfully.");
  }

  void removeMod(XmlDocument document, String modUuid, bool orderMode) {
    final root = document.rootElement;
    final modsNode = root
        .findAllElements('node')
        .firstWhere((node) => node.getAttribute('id') == 'Mods')
        .findElements('children')
        .first;

    removeNode(modsNode, modUuid);
    if (!orderMode) return;
    removeModOrder(document, modUuid);
    print("Mod removed successfully.");
  }

  void addModOrder(XmlDocument document, String modUuid) {
    final root = document.rootElement;
    final modOrderNode = root
        .findAllElements('node')
        .firstWhere((node) => node.getAttribute('id') == 'ModOrder')
        .findElements('children')
        .first;

    final newModOrderNode = createModOrderNode(modUuid);

    modOrderNode.children.add(newModOrderNode);
    print("ModOrder node added successfully.");
  }

  void removeModOrder(XmlDocument document, String modUuid) {
    final root = document.rootElement;
    final modOrderNode = root
        .findAllElements('node')
        .firstWhere((node) => node.getAttribute('id') == 'ModOrder')
        .findElements('children')
        .first;

    modOrderNode.children.removeWhere((child) {
      return child is XmlElement &&
          child.getAttribute('id') == 'Module' &&
          child.findElements('attribute').any((attr) =>
              attr.getAttribute('id') == 'UUID' &&
              attr.getAttribute('value') == modUuid);
    });

    print("ModOrder node removed successfully.");
  }

  void saveDocument(XmlDocument document, String filePath) {
    final file = File(filePath);
    file.writeAsStringSync(document.toXmlString(pretty: true, indent: '  '));
    print("File saved successfully.");
  }
}

// // Example usage
// void main() {
//   final filePath = 'path/to/your/modsetting.xml';
//   final file = File(filePath);
//   final document = XmlDocument.parse(file.readAsStringSync());

//   final modDescription = 'Example Mod';
//   final modFolder = 'example_folder';
//   final modMD5 = '1234567890abcdef';
//   final modName = 'Example Mod Name';
//   final modUuid = 'abcdef1234567890';
//   final modVersion = '1.0.0';

//   final modifier = ModifyModsetting();

//   
//   // modifier.addMod(document, modDescription, modFolder, modMD5, modName, modUuid, modVersion);

//   
//   // modifier.removeMod(document, modMD5);

//   
//   // modifier.addModOrder(document, modUuid);

//   
//   modifier.saveDocument(document, filePath);
// }
