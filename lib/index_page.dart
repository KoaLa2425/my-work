import 'package:flutter/material.dart';
import 'package:test_project/productlist_page.dart';
import 'package:test_project/home_page.dart';
import 'package:test_project/profile_page.dart';

class IndexPage extends StatefulWidget {
  final String username;
  final String fullname;

   const IndexPage({Key? key, required this.username, required this.fullname}) : super(key: key);


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
    print('Username: $_username');
    print('Fullname: $_fullname');
  }

  void _logout() {
    // ใส่โค้ดสำหรับ logout ที่นี่ (เช่น ลบ token, ล้าง cache)
    Navigator.of(context).pushReplacementNamed('/'); // กลับไปหน้า login
  }

  @override
  Widget build(BuildContext context) {
     print('IndexPage - Username: $_username, Fullname: $_fullname'); 
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('ยินดีต้อนรับ  $_fullname'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'หน้าแรก', icon: Icon(Icons.home)),
              Tab(text: 'สินค้า', icon: Icon(Icons.add_business)),
              Tab(text: 'ผู้ใช้', icon: Icon(Icons.person)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            HomePage(),
            ProductListPage(key: const Key('productList'), username: _username),
            ProfilePage(
              key: const Key('profile'),
              username: _username,
              fullname: _fullname,
            ),
          ],
        ),
      ),
    );
  }
}