import 'package:flutter/material.dart';
import 'package:test_project/login.dart';
import 'package:test_project/regitser_page.dart'; // เพิ่มการ import หน้าลงทะเบียน

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login Page',
      theme: ThemeData(),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/register': (context) => RegisterPage(), // เพิ่มเส้นทางไปยังหน้าลงทะเบียน
      },
    );
  }
}