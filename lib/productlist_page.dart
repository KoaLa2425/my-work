import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Product {
  final String? id;
  final String name;
  final String description;
  final String category;
  final double price;

  Product({
    this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      price: json['price'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'price': price,
    };
  }
}

class AuthService {
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('User logged out, all preferences cleared');
  }
}

class ProductService {
  static const String baseUrl = 'http://localhost:3001/product';
  static const String productsEndpoint = '/products';
  static const String addProductEndpoint = '/add-product';
  static const String editProductEndpoint = '/edit-product';
  static const String deleteProductEndpoint = '/delete-product';

  Future<List<Product>> getProducts() async {
    try {
      print('Attempting to fetch products from: $baseUrl$productsEndpoint');

      final response = await http.get(Uri.parse('$baseUrl$productsEndpoint'));

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse.containsKey('products') &&
            jsonResponse['products'] is List) {
          List<dynamic> productsJson = jsonResponse['products'];
          List<Product> products =
              productsJson.map((item) => Product.fromJson(item)).toList();
          print('Successfully parsed ${products.length} products');
          return products;
        } else {
          throw Exception(
              'Unexpected response format: products key not found or not a List');
        }
      } else {
        throw Exception(
            'Failed to load products. Status code: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('Error in getProducts: $e');
      throw Exception('Failed to load products: $e');
    }
  }

  Future<Product> addProduct(Product product) async {
    final response = await http.post(
      Uri.parse('$baseUrl$addProductEndpoint'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(product.toJson()),
    );
    if (response.statusCode == 201) {
      return Product.fromJson(jsonDecode(response.body)['product']);
    } else {
      throw Exception('Failed to add product: ${response.body}');
    }
  }

  Future<Product> editProduct(String id, Product product) async {
    final response = await http.put(
      Uri.parse('$baseUrl$editProductEndpoint/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(product.toJson()),
    );
    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body)['product']);
    } else {
      throw Exception('Failed to edit product: ${response.body}');
    }
  }

  Future<void> deleteProduct(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$deleteProductEndpoint/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete product: ${response.body}');
    }
  }
}

class ProductListPage extends StatefulWidget {
  final String username;

  const ProductListPage({Key? key, required this.username}) : super(key: key);
  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  String _username = '';
  String _fullname = '';
  final ProductService _productService = ProductService();
  final AuthService _authService = AuthService();
  List<Product> _products = [];

  @override
  @override
  void initState() {
    super.initState();
    _username = widget.username; // เพิ่มบรรทัดนี้
    _loadUserInfo();
    _checkLoginStatusAndLoadProducts();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = widget.username; // เพิ่มบรรทัดนี้ถ้ายังไม่มี
      _fullname = prefs.getString('fullname') ?? '';
    });
    print('Loaded user info: $_username, $_fullname');
  }

  Future<void> _checkLoginStatusAndLoadProducts() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (!isLoggedIn) {
      _redirectToLoginPage();
    } else {
      _loadProducts();
    }
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _productService.getProducts();
      setState(() {
        _products = products;
      });
    } catch (e) {
      print('Error loading products: $e');
      _showErrorDialog('Failed to load products: $e');
    }
  }

  void _redirectToLoginPage() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  Future<Product> _addProduct(Product product) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      print('Sending product data: ${product.toJson()}');

      final response = await http.post(
        Uri.parse(
            '${ProductService.baseUrl}${ProductService.addProductEndpoint}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(product.toJson()),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        return Product.fromJson(jsonDecode(response.body)['product']);
      } else {
        // แสดงข้อความผิดพลาดที่เฉพาะเจาะจงมากขึ้น
        final errorMessage =
            jsonDecode(response.body)['message'] ?? 'Unknown error occurred';
        throw Exception('Failed to add product: $errorMessage');
      }
    } catch (e) {
      print('Error in addProduct: $e');
      // ส่งต่อข้อผิดพลาดที่เฉพาะเจาะจงมากขึ้น
      throw Exception('Failed to add product: ${e.toString()}');
    }
  }

  Future<void> _editProduct(String id, Product product) async {
    try {
      print('Attempting to edit product with id: $id');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.put(
        Uri.parse(
            '${ProductService.baseUrl}${ProductService.editProductEndpoint}/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(product.toJson()),
      );

      print('Edit response status: ${response.statusCode}');
      print('Edit response body: ${response.body}');

      if (response.statusCode == 200) {
        final updatedProduct =
            Product.fromJson(jsonDecode(response.body)['product']);
        setState(() {
          final index = _products.indexWhere((p) => p.id == id);
          if (index != -1) {
            _products[index] = updatedProduct;
          }
        });
        print(
            'Product updated in list. Product details: ${updatedProduct.toJson()}');
      } else {
        throw Exception('Failed to edit product: ${response.body}');
      }
    } catch (e) {
      print('Error in _editProduct: $e');
      _showErrorDialog('Failed to edit product: $e');
    }
  }

  Future<void> _removeProduct(String id) async {
    try {
      print('Attempting to delete product with id: $id');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.delete(
        Uri.parse(
            '${ProductService.baseUrl}${ProductService.deleteProductEndpoint}/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      print('Delete response status: ${response.statusCode}');
      print('Delete response body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          _products.removeWhere((product) => product.id == id);
        });
        print('Product removed from list. New length: ${_products.length}');
      } else {
        throw Exception('Failed to delete product: ${response.body}');
      }
    } catch (e) {
      print('Error in _removeProduct: $e');
      _showErrorDialog('Failed to delete product: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    print('Error occurred: $message'); // เพิ่ม logging
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product List - $_username'),
      ),
      body: ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return ListTile(
            title: Text(product.name),
            subtitle: Text('${product.category} - \$${product.price}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showProductDialog(product: product),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    print('Delete button pressed for product: ${product.id}');
                    _removeProduct(product.id!);
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showProductDialog({Product? product}) async {
    print('Opening product dialog for ${product?.name ?? 'new product'}');
    final result = await showDialog<Product>(
      context: context,
      builder: (context) => ProductDialog(product: product),
    );
    print('Dialog result: $result');
    if (result != null) {
      try {
        if (product == null) {
          print('Attempting to add new product');
          final newProduct = await _addProduct(result);
          print('New product added: ${newProduct.toJson()}');
          setState(() {
            _products.add(newProduct);
          });
          print('Product list updated, new length: ${_products.length}');
        } else {
          print('Attempting to edit product ${product.id}');
          await _editProduct(product.id!, result);
        }
      } catch (e) {
        print('Error in _showProductDialog: $e');
        _showErrorDialog(
            'Failed to ${product == null ? 'add' : 'edit'} product: ${e.toString()}');
      }
    }
  }
}

class ProductDialog extends StatefulWidget {
  final Product? product;

  const ProductDialog({Key? key, this.product}) : super(key: key);

  @override
  _ProductDialogState createState() => _ProductDialogState();
}

class _ProductDialogState extends State<ProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _description;
  late String _category;
  late double _price;

  @override
  void initState() {
    super.initState();
    _name = widget.product?.name ?? '';
    _description = widget.product?.description ?? '';
    _category =
        widget.product?.category ?? 'Electronics'; // Default value from items
    _price = widget.product?.price ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                onSaved: (value) => _description = value!,
              ),
              DropdownButtonFormField<String>(
                value: _category.isEmpty ? null : _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: ['Electronics', 'Clothing', 'Home']
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _category = value);
                  }
                },
              ),
              TextFormField(
                initialValue: _price.toString(),
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onSaved: (value) => _price = double.parse(value!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              final product = Product(
                id: widget.product?.id,
                name: _name,
                description: _description,
                category: _category,
                price: _price,
              );
              print('Returning product from dialog: ${product.toJson()}');
              Navigator.pop(context, product);
            }
          },
          child: Text(widget.product == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}
