import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:test_project/Login.dart';
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
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ApiService _apiService = ApiService();
  List<dynamic> _data = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    final data = await _apiService.getData();
    setState(() {
      _data = data;
    });
  }

  void _addItem() {
    final newItem = {"Name": "New User", "code": "new_code"};
    _apiService.postData(newItem).then((_) {
      _fetchData();
    });
  }

  void _updateItem(String id) {
    final updatedItem = {"Name": "Updated User", "code": "updated_code"};
    _apiService.putData(id, updatedItem).then((_) {
      _fetchData();
    });
  }

  void _deleteItem(String id) {
    _apiService.deleteData(id).then((_) {
      _fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Demo'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _data.length,
              itemBuilder: (context, index) {
                final item = _data[index];
                return ListTile(
                  title: Text("Username: " + item['Name']),
                  subtitle: Text("Password: " + item['code']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _updateItem(item['id']);
                        },
                      ),
                      IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _deleteItem(item['id']);
                          }
                          ),
                    ],
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
            child: const Text('Login'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        child: const Icon(Icons.add),
      ),
    );
  }
}
