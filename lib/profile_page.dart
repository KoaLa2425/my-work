import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatelessWidget {
  final String? username;
  final String? fullname;

  const ProfilePage({Key? key, this.username, this.fullname}) : super(key: key);

  Future<Map<String, String>> _getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'username': prefs.getString('username') ?? 'Unknown',
      'fullname': prefs.getString('fullname') ?? 'Unknown',
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: _getUserInfo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        final userInfo =
            snapshot.data ?? {'username': 'Unknown', 'fullname': 'Unknown'};
        return Scaffold(
          appBar: AppBar(title: const Text('Profile')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Username: ${userInfo['username']}'),
                Text('Fullname: ${userInfo['fullname']}'),
                ElevatedButton(
                  onPressed: () => _logout(context),
                  child: const Text('Logout'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
    // แสดงไดอะล็อกยืนยันการล็อกเอาท์
    bool confirmLogout = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text("Logout"),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');
        await prefs.remove('username');
        await prefs.remove('fullname');
        // ล็อกเอาท์สำเร็จ นำทางกลับไปยังหน้าล็อกอิน
        Navigator.pushReplacementNamed(context, '/');
      } catch (e) {
        // จัดการข้อผิดพลาดที่อาจเกิดขึ้น
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to logout. Please try again.')),
        );
      }
    }
  }
}
