import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ProductListPage(),
    );
  }
}

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

class ProductService {
  static const String baseUrl = 'http://localhost:3000/product';
  static const String productsEndpoint = '/products';
  static const String addProductEndpoint = '/add-product';
  static const String editProductEndpoint = '/edit-product';
  static const String deleteProductEndpoint = '/delete-product';

  Future<List<Product>> getProducts() async {
    final response = await http.get(Uri.parse('$baseUrl$productsEndpoint'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load products: ${response.body}');
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
  const ProductListPage({Key? key}) : super(key: key);

  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final ProductService _productService = ProductService();
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _productService.getProducts();
      setState(() {
        _products = products;
      });
    } catch (e) {
      _showErrorDialog('Failed to load products');
    }
  }

  Future<void> _addProduct(Product product) async {
    try {
      final newProduct = await _productService.addProduct(product);
      setState(() {
        _products.add(newProduct);
      });
    } catch (e) {
      _showErrorDialog('Failed to add product');
    }
  }

  Future<void> _editProduct(String id, Product product) async {
    try {
      final updatedProduct = await _productService.editProduct(id, product);
      setState(() {
        final index = _products.indexWhere((p) => p.id == id);
        if (index != -1) {
          _products[index] = updatedProduct;
        }
      });
    } catch (e) {
      _showErrorDialog('Failed to edit product');
    }
  }

  Future<void> _removeProduct(String id) async {
    try {
      await _productService.deleteProduct(id);
      setState(() {
        _products.removeWhere((product) => product.id == id);
      });
    } catch (e) {
      _showErrorDialog('Failed to delete product');
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product List'),
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
                  onPressed: () => _removeProduct(product.id!),
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
    final result = await showDialog<Product>(
      context: context,
      builder: (context) => ProductDialog(product: product),
    );
    if (result != null) {
      if (product == null) {
        await _addProduct(result);
      } else {
        await _editProduct(product.id!, result);
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
    _category = widget.product?.category ?? 'Electronics'; // Default value from items
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
              Navigator.pop(
                context,
                Product(
                  id: widget.product?.id,
                  name: _name,
                  description: _description,
                  category: _category,
                  price: _price,
                ),
              );
            }
          },
          child: Text(widget.product == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}