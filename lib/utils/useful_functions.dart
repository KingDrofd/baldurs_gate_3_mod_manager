import 'dart:io';

//UsefulFunctions

bool checkDir(String path) {
  return Directory(path).existsSync();
}

bool checkFile(String path) {
  return File(path).existsSync();
}
