class ModFile {
  String name;
  List<String> paths;

  ModFile({required this.name, required this.paths});

  factory ModFile.fromJson(Map<String, dynamic> json) {
    return ModFile(
        name: json.keys.first, paths: List<String>.from(json.values.first));
  }
}
