import 'package:flutter/material.dart';
import 'package:test_project/login.dart';
import 'package:test_project/index_page.dart';
import 'package:test_project/regitser_page.dart';
// แก้ชื่อ import เป็น register_page.dart

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
      initialRoute: '/', // ตั้งค่าให้เส้นทางเริ่มต้นเป็นหน้า Login
      routes: {
        '/': (context) => const LoginPage(),
        '/register': (context) =>
            RegisterPage(), // เพิ่มเส้นทางไปยังหน้าลงทะเบียน
        '/index': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return IndexPage(
            username: args['username'] as String,
            fullname: args['fullname'] as String,
          );
        },
      },
    );
  }
}
