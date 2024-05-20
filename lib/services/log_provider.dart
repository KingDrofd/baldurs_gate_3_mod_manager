import 'package:flutter/material.dart';

class LogProvider with ChangeNotifier {
  List<String> _logs = [];

  List<String> get logs => _logs;

  void addLog(String message) {
    _logs.add(message);
    notifyListeners();
  }

  void clearLogs() {
    _logs.clear();
    notifyListeners();
  }
}
