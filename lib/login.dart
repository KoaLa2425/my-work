import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formkey = GlobalKey<FormState>();
  final _navigatorController = GlobalKey<NavigatorState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    final url = Uri.parse('http://localhost:3000/auth/login');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'username': _usernameController.text,
      'password': _passwordController.text
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        _showSnackBar('Login successful');
        // เพิ่มโค้ดสำหรับจัดการ token ที่ได้รับจากเซิร์ฟเวอร์
      } else {
        final jsonResponse = jsonDecode(response.body);
        _showSnackBar(jsonResponse['message'] ?? 'Login failed');
      }
    } catch (e) {
      print('Error: $e');
      _showSnackBar('An error occurred. Please try again.');
    } finally {
      setState(() => _isLoading = false); // เพิ่มบรรทัดนี้
    }
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget build(BuildContext context) {
    return Navigator(
      key: _navigatorController,
      onGenerateRoute: (setting) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                    key: _formkey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          'https://cdn-icons-png.flaticon.com/512/5087/5087579.png',
                          width: 150,
                          height: 150,
                        ),
                        TextFormField(
                          controller: _usernameController,
                          decoration:
                              const InputDecoration(labelText: "Username"),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your Username';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration:
                              const InputDecoration(labelText: "Password"),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your Password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  if (_formkey.currentState!.validate()) {
                                    _login();
                                  }
                                },
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text('Login'),
                        ),
                        TextButton(
                          onPressed: () {
                            // นำทางไปยังหน้าลงทะเบียน
                            // ตัวอย่าง: Navigator.pushNamed(context, '/register');
                          },
                          child: const Text('Don\'t have an account? Register'),
                        ),
                      ],
                    )),
              ),
            ),
          ),
        );
      },
    );
  }
}
