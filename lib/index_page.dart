import 'package:flutter/material.dart';
import 'package:test_project/productlist_page.dart';
import 'package:test_project/home_page.dart';
import 'package:test_project/profile_page.dart'; // แก้ชื่อ import เป็น profile_page.dart

class IndexPage extends StatefulWidget {
  final String username;
  final String fullname;

  const IndexPage({
    Key? key,
    required this.username,
    required this.fullname,
  }) : super(key: key);

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  late String _username;
  late String _fullname;

  @override
  void initState() {
    super.initState();
    _username = widget.username;
    _fullname = widget.fullname;
    print('Username: $_username'); // ตรวจสอบค่า username ว่าถูกต้องหรือไม่
    print('Fullname: $_fullname'); // ตรวจสอบค่า fullname ว่าถูกต้องหรือไม่
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My app'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Home', icon: Icon(Icons.home)),
              Tab(text: 'Edit', icon: Icon(Icons.add_business)),
              Tab(text: 'Profile', icon: Icon(Icons.person)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            HomePage(),
            ProductListPage(),
            ProfilePage(
              username: _username,
              fullname: _fullname,
            ),
          ],
        ),
      ),
    );
  }
}