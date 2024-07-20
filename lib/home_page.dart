import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const BarcodeScannerPage();  // แก้ไขจาก Barcode() เป็น BarcodeScannerPage()
  }
}

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({Key? key}) : super(key: key);  // เพิ่ม constructor

  @override
  _BarcodeScannerPageState createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  String _scanBarcode = 'ยังไม่ได้สแกน';

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'ยกเลิก', true, ScanMode.BARCODE);
    } catch (e) {
      barcodeScanRes = 'เกิดข้อผิดพลาดในการสแกน: $e';
    }

    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
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
          ],
        ),
      ),
    );
  }
}