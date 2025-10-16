import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = "https://api-flights-uya5.vercel.app";
  // Use localhost for iOS simulator, your IP for real device

  static Future<Map<String, dynamic>> signup(String name, String mobile) async {
    final url = Uri.parse("$baseUrl/auth/signup");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'mobile': mobile}),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> login(String name, String mobile) async {
    final url = Uri.parse("$baseUrl/auth/login");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'name': name,
          'phone': "+91-$mobile",
        },
      );

      // Handle non-200 responses
      if (response.statusCode != 200) {
        return {
          'success': false,
          'message':
          'Server responded with status ${response.statusCode}: ${response.reasonPhrase}',
        };
      }

      // Safely decode JSON
      final data = jsonDecode(response.body);
      return data is Map<String, dynamic>
          ? data
          : {'success': false, 'message': 'Invalid response format'};
    } on http.ClientException catch (e) {
      return {'success': false, 'message': 'Client error: ${e.message}'};
    } on FormatException {
      return {'success': false, 'message': 'Invalid JSON in response'};
    } catch (e) {
      return {'success': false, 'message': 'Unexpected error: $e'};
    }
  }

}
