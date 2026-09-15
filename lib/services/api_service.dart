import 'dart:convert';
import 'package:http/http.dart' as http;

/// Generic wrapper for any external REST API calls
/// (not Firebase — Firebase is accessed directly via its own SDKs).
/// Use this if you later integrate something like Google Maps Directions API,
/// a weather API, or a third-party transit API.
class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('GET $endpoint failed: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('POST $endpoint failed: ${response.statusCode}');
    }
  }
}