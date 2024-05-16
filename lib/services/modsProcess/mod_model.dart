class Mod {
  String name;
  List<String> paths;

  Mod({required this.name, required this.paths});

  factory Mod.fromJson(Map<String, dynamic> json) {
    return Mod(
        name: json.keys.first, paths: List<String>.from(json.values.first));
  }
}
