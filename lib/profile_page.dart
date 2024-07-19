import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
const String baseUrl = 'http://localhost:3000'; 

class ProfilePage extends StatefulWidget {
  final String username;

  const ProfilePage({Key? key, required this.username, required String fullname}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String fullname = '';

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
  try {
    final response = await http.get(Uri.parse('http://localhost:3000/profile/${widget.username}'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        fullname = data['fullname'];
      });
    } else {
      print('Failed to load profile data: ${response.statusCode}');
    }
  } catch (error) {
    print('Error fetching profile data: $error');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Container(
        decoration: const BoxDecoration(color: Colors.blueAccent),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.username,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              fullname,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            // เพิ่ม Widgets อื่น ๆ ตามต้องการ
          ],
        ),
      ),
    );
  }
}