import 'dart:convert';
import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://6695cf830312447373c01b6c.mockapi.io/api/v1/'));

  Future<List<dynamic>> getData() async {
    try {
      final response = await _dio.get('/generate');
      return response.data;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<void> postData(Map<String, dynamic> data) async {
    try {
      await _dio.post('/generate', data: data);
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> putData(String id, Map<String, dynamic> data) async {
    try {
      await _dio.put('/generate/$id', data: data);
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> deleteData(String id) async {
    try {
      await _dio.delete('/generate/$id');
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<bool> validateLogin(String username, String password) async {
    try {
      final response = await _dio.get('/generate');
      final data = response.data as List<dynamic>;
      for (var item in data) {
        if (item['Name'] == username && item['code'] == password) {
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }
}
