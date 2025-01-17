import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ING FCM Notification Tester',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        primaryColor: const Color(0xFFFF6200),
        useMaterial3: true,
      ),
      home: const NotificationTester(),
    );
  }
}

class NotificationTester extends StatefulWidget {
  const NotificationTester({super.key});

  @override
  State<NotificationTester> createState() => _NotificationTesterState();
}

class _NotificationTesterState extends State<NotificationTester> {
  final _formKey = GlobalKey<FormState>();
  final _deviceTokenController = TextEditingController();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  bool _isSending = false;
  String _status = '';

  Future<void> _sendNotification() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSending = true;
      _status = 'Sending notification...';
    });

    try {
      const url = 'http://localhost:3000/send-notification';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'token': _deviceTokenController.text,
          'title': _titleController.text,
          'body': _bodyController.text,
          'data': {} // Empty data object
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _status = 'Notification sent successfully!';
        });
      } else {
        setState(() {
          _status = 'Error: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6200),
        title: Row(
          children: [
            const Text(
              'Android Notification Tester',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.orange.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _deviceTokenController,
                          decoration: const InputDecoration(
                            labelText: 'Device Token',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter device token';
                            }
                            return null;
                          },
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Notification Title',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter notification title';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _bodyController,
                          decoration: const InputDecoration(
                            labelText: 'Notification Body',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter notification body';
                            }
                            return null;
                          },
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSending ? null : _sendNotification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6200),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    _isSending ? 'Sending...' : 'Send Notification',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),
                if (_status.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _status.contains('Error')
                          ? Colors.red.shade100
                          : Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_status),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _deviceTokenController.dispose();
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }
}
