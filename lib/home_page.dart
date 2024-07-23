import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const BarcodeScannerPage();
  }
}

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({Key? key}) : super(key: key);

  @override
  _BarcodeScannerPageState createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  String _scanBarcode = 'ยังไม่ได้สแกน';
  String _productInfo = '';
  bool _isLoading = false;

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'ยกเลิก', true, ScanMode.BARCODE);
      if (barcodeScanRes == '-1') {  // ผู้ใช้ยกเลิกการสแกน
        return;
      }
    } catch (e) {
      setState(() {
        _scanBarcode = 'เกิดข้อผิดพลาดในการสแกน: $e';
        _productInfo = '';
      });
      return;
    }

    setState(() {
      _scanBarcode = barcodeScanRes;
      _isLoading = true;
      _productInfo = '';
    });

    await _getProductInfo(barcodeScanRes);
  }

  Future<void> _getProductInfo(String barcode) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/product/$barcode'));

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final product = json.decode(response.body);
        setState(() {
          _productInfo = 'ชื่อสินค้า: ${product['name']}\n'
              'รายละเอียด: ${product['description']}\n'
              'หมวดหมู่: ${product['category']}\n'
              'ราคา: ${product['price']} บาท';
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _productInfo = 'ไม่พบข้อมูลสินค้า';
        });
      } else {
        setState(() {
          _productInfo = 'เกิดข้อผิดพลาดในการเรียกข้อมูล: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _productInfo = 'เกิดข้อผิดพลาดในการเชื่อมต่อกับเซิร์ฟเวอร์: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สแกนบาร์โค้ด'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: const Text('เริ่มสแกนบาร์โค้ด'),
              onPressed: scanBarcodeNormal,
            ),
            const SizedBox(height: 20),
            Text('ผลการสแกน: $_scanBarcode'),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : Text('ข้อมูลสินค้า:\n$_productInfo', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}