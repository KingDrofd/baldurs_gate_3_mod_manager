class ModInfo {
  final String packId;
  final List<ModDetails> mods;
  final String md5;

  ModInfo({required this.packId, required this.mods, required this.md5});

  factory ModInfo.fromJson(Map<String, dynamic> json, String packId) {
    return ModInfo(
      packId: packId,
      mods: (json['Mods'] as List)
          .map((modJson) => ModDetails.fromJson(modJson))
          .toList(),
      md5: json['MD5'],
    );
  }
}

class ModDetails {
  final String author;
  final String name;
  final String folder;
  final String? version;
  final String description;
  final String uuid;
  final DateTime created;
  final List<dynamic> dependencies;
  final String group;

  ModDetails({
    required this.author,
    required this.name,
    required this.folder,
    required this.version,
    required this.description,
    required this.uuid,
    required this.created,
    required this.dependencies,
    required this.group,
  });

  factory ModDetails.fromJson(Map<String, dynamic> json) {
    return ModDetails(
      author: json['Author'],
      name: json['Name'],
      folder: json['Folder'],
      version: json['Version'],
      description: json['Description'],
      uuid: json['UUID'],
      created: DateTime.parse(json['Created']),
      dependencies: json['Dependencies'],
      group: json['Group'],
    );
  }
}
