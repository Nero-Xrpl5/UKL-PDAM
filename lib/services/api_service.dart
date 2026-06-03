import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../constants/api.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => message;
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) : super(message, statusCode: 401);
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;
  void Function()? onUnauthorized;

  void setToken(String token) => _token = token;
  void clearToken() => _token = null;
  void setOnUnauthorized(void Function() callback) => onUnauthorized = callback;

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'app-key': ApiConfig.appKey,
    };
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  get token => null;

  Future<dynamic> _safeRequest(Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(const Duration(seconds: 15));
      return _processResponse(response);
    } on SocketException catch (_) {
      throw ApiException('Tidak ada koneksi internet. Periksa jaringan Anda.');
    } on TimeoutException catch (_) {
      throw ApiException('Koneksi timeout. Server terlalu lambat, coba lagi.');
    } on FormatException catch (_) {
      throw ApiException('Format respons server tidak valid.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Terjadi kesalahan: ${e.toString()}');
    }
  }

  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    return _safeRequest(() => http.get(url, headers: _headers));
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    return _safeRequest(() => http.post(
          url,
          headers: _headers,
          body: body != null ? jsonEncode(body) : null,
        ));
  }

  Future<dynamic> patch(String endpoint, {Map<String, dynamic>? body}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    return _safeRequest(() => http.patch(
          url,
          headers: _headers,
          body: body != null ? jsonEncode(body) : null,
        ));
  }

  Future<dynamic> delete(String endpoint) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    return _safeRequest(() => http.delete(url, headers: _headers));
  }

  Future<dynamic> postMultipart(
    String endpoint, {
    required Map<String, String> fields,
    required File file,
    required String fileField,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final request = http.MultipartRequest('POST', url);

    request.headers['app-key'] = ApiConfig.appKey;
    if (_token != null && _token!.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $_token';
    }

    fields.forEach((key, value) => request.fields[key] = value);

    final multipartFile = await http.MultipartFile.fromPath(
      fileField,
      file.path,
      contentType: MediaType('image', 'jpeg'),
    );
    request.files.add(multipartFile);

    try {
      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse)
          .timeout(const Duration(seconds: 10));
      return _processResponse(response);
    } on SocketException catch (_) {
      throw ApiException('Tidak ada koneksi internet.');
    } on TimeoutException catch (_) {
      throw ApiException('Upload timeout. Coba lagi.');
    } catch (e) {
      throw ApiException('Upload gagal: ${e.toString()}');
    }
  }

  dynamic _processResponse(http.Response response) {
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    String message = 'Error ${response.statusCode}';
    if (body != null && body is Map && body['message'] != null) {
      message = body['message'].toString();
    } else {
      switch (response.statusCode) {
        case 400:
          message = 'Permintaan tidak valid (400).';
          break;
        case 401:
          message = 'Sesi tidak valid. Silakan login ulang.';
          break;
        case 403:
          message = 'Akses ditolak (403).';
          break;
        case 404:
          message = 'Data tidak ditemukan (404).';
          break;
        case 500:
          message = 'Server sedang bermasalah (500).';
          break;
      }
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      onUnauthorized?.call();
      throw UnauthorizedException(message);
    }
    throw ApiException(message, statusCode: response.statusCode);
  }
}