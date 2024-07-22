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

    try {
      final response = await http.post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 10));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
  final jsonResponse = jsonDecode(response.body);
  final token = jsonResponse['token'];
  final username = jsonResponse['username'];
  final fullname = jsonResponse['fullname'];

  // Save token and user info
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('auth_token', token);
  await prefs.setString('username', username);
  await prefs.setString('fullname', fullname);

  _showSnackBar('Login successful');
  Navigator.pushReplacementNamed(
    context,
    '/index',
    arguments: {'username': username, 'fullname': fullname},
  );
  return;
} else {
        final jsonResponse = jsonDecode(response.body);
        _showSnackBar(jsonResponse['message'] ?? 'Login failed');
      }
    } on SocketException {
      _showSnackBar('Could not connect to server');
    } on TimeoutException {
      _showSnackBar('Connection timed out, please try again');
    } catch (e) {
      print('Error during login: $e');
      _showSnackBar('An error occurred, please try again');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
    ));
  }
  Future<Map<String, String>> _getUserInfoFromToken(String token) async {
  final url = Uri.parse('$baseUrl/auth/login'); // สมมติว่ามี endpoint นี้
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
      'username': jsonResponse['username'] ?? '',
      'fullname': jsonResponse['fullname'] ?? '',
    };
  } else {
    throw Exception('Failed to get user info');
  }
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
                  Navigator.pushReplacementNamed(
                    context,
                    '/index',
                    arguments: userSnapshot.data,
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

  Future<Map<String, String>> _getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) {
      throw Exception('Token not found');
    }

    final url = Uri.parse('$baseUrl/auth/login');
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

  Widget _buildLoginForm() {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
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
                  decoration: const InputDecoration(labelText: "รหัสผู้ใช้"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter username';
                    }
                    if (value.length < 3) {
                      return 'Username must be at least 3 characters long';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "รหัสผ่าน"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
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
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text('เข้าสู่ระบบ'),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text("ยังไม่มีบัญชี? ลงทะเบียน"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}