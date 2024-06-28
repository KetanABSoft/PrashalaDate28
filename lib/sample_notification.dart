import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SampleNotification extends StatefulWidget {
  const SampleNotification({super.key});

  @override
  State<SampleNotification> createState() => _SampleNotificationState();
}

class _SampleNotificationState extends State<SampleNotification> {
  var data;

  @override
  void initState() {
    super.initState();
    getApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              showDataDialog(); // Show dialog with data when icon is tapped
            },
            child: Center(
              child: Icon(Icons.notifications_none_outlined, size: 50),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getApi() async {
    final response = await http.get(
        Uri.parse("https://shivpeeth.com/Android_app/homeworknotification.php"));
    if (response.statusCode == 200) {
      setState(() {
        data = jsonDecode(response.body.toString());
      });
      print("############$data");
    } else {
      // Handle errors, you can add error handling here
    }
  }

  void showDataDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(data["message"].toString()),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
