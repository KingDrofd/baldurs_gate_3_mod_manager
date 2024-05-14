import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _textEditingController = TextEditingController();
  TextEditingController _textEditingControllerName = TextEditingController();
  String messageData = "";
  Future fetchEntry() async {
    final url = Uri.parse('API HERE');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      var content = jsonDecode(response.body);
      setState(() {
        messageData = content['message'];
      });

      print(messageData);
      return messageData;
    } else {
      print('Failed to fetch data');
    }
  }

  Future<void> _sendData() async {
    try {
      if (_textEditingController.text.isNotEmpty) {
        var url = Uri.parse("API HERE");
        var headers = {"Content-Type": "application/json"};
        var body = jsonEncode({
          "name": _textEditingControllerName.text,
          "path": _textEditingController.text
        });
        var response = await http.post(url, headers: headers, body: body);
        if (response.statusCode == 200) {
          // Data sent successfully
          print("Data sent successfully");
        } else {
          // Failed to send data
          print("Failed to send data");
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: 500,
        width: 600,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Center(
              child: ElevatedButton.icon(
                  onPressed: () {
                    fetchEntry();
                  },
                  icon: Icon(Icons.arrow_downward_rounded),
                  label: Text("Get Data")),
            ),
            Text(messageData),
            SizedBox(
              width: 400,
              height: 100,
              child: Row(
                children: [
                  SizedBox(
                    width: 100,
                    height: 50,
                    child: TextField(
                      controller: _textEditingControllerName,
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    height: 50,
                    child: TextField(
                      controller: _textEditingController,
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        _sendData();
                      },
                      icon: Icon(Icons.arrow_upward_rounded))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
