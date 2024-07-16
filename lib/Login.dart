import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'api_service.dart';

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
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  String _response = '';

  String? result = '';

  Future<void> login(String? name) async {
    String? username = name;
    String password = _passwordController.text;

    bool isValid = await _apiService.validateLogin(username!, password);

    setState(() {
      _response = isValid ? 'Login successful' : 'Invalid credentials';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: 'Username'),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    var res = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const SimpleBarcodeScannerPage(),
                        ));
                    setState(() {
                      if (res is String) {
                        result = res;
                        _usernameController.text = result!;
                      }
                    });
                  },
                  icon: const Icon(Icons.camera_alt),
                ),
              ],
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                log('result');
                login(_usernameController.text);
              },
              child: const Text('Login'),
            ),
            const SizedBox(height: 20),
            Text(_response),
          ],
        ),
      ),
    );
  }
}
