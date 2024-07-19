import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_project/index_page.dart';

const String baseUrl = 'http://localhost:3000'; 

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<Map<String, String>> _getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) {
      throw Exception('No token found');
    }

    final url = Uri.parse('$baseUrl/user');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return {
        'username': jsonResponse['username'],
        'fullname': jsonResponse['fullname'],
      };
    } else {
      throw Exception('Failed to get user info');
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    print('Starting login process');

    final url = Uri.parse('$baseUrl/auth/login');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'username': _usernameController.text,
      'password': _passwordController.text
    });

    int retries = 3;
    while (retries > 0) {
      try {
        final response = await http.post(url, headers: headers, body: body)
            .timeout(const Duration(seconds: 10));
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          final token = jsonResponse['token'];
          final username = jsonResponse['username'] ?? '';
          final fullname = jsonResponse['fullname'] ?? '';

          // บันทึก token และข้อมูลผู้ใช้
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          await prefs.setString('username', username);
          await prefs.setString('fullname', fullname);

          _showSnackBar('เข้าสู่ระบบสำเร็จ');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => IndexPage(
              username: username,
              fullname: fullname,
            )),
          );
          return;
        } else {
          final jsonResponse = jsonDecode(response.body);
          _showSnackBar(jsonResponse['message'] ?? 'เข้าสู่ระบบล้มเหลว');
        }
      } on SocketException {
        _showSnackBar('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้');
      } on TimeoutException {
        _showSnackBar('การเชื่อมต่อหมดเวลา กรุณาลองใหม่อีกครั้ง');
      } catch (e) {
        print('Error during login: $e');
        _showSnackBar('เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง');
      } finally {
        retries--;
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
    ));
  }

  Future<bool> _checkToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.data == true) {
          return FutureBuilder<Map<String, String>>(
            future: _getUserInfo(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              } else if (userSnapshot.hasData) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => IndexPage(
                        username: userSnapshot.data!['username']!,
                        fullname: userSnapshot.data!['fullname']!,
                      ),
                    ),
                  );
                });
                return Container();
              } else {
                return _buildLoginForm();
              }
            },
          );
        } else {
          return _buildLoginForm();
        }
      },
    );
  }

  Widget _buildLoginForm() {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  'https://cdn-icons-png.flaticon.com/512/5087/5087579.png',
                  width: 150,
                  height: 150,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: "Username"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอก Username';
                    }
                    if (value.length < 3) {
                      return 'Username ต้องมีความยาวอย่างน้อย 3 ตัวอักษร';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Password"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอก Password';
                    }
                    if (value.length < 6) {
                      return 'Password ต้องมีความยาวอย่างน้อย 6 ตัวอักษร';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Login'),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text('Don\'t have an account? Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}