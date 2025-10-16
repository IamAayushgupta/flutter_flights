import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/flight.dart';
import '../models/user.dart';

class ApiService {
  static const String baseUrl = "http://localhost:8000";
  // ⚠️ If testing on real device/emulator, replace localhost:
  // Android Emulator: http://10.0.2.2:8000
  // iOS Simulator: http://localhost:8000
  // Real Device (USB/WiFi): http://<your-pc-ip>:8000

  // Fetch all flights
  static Future<List<Flight>> getFlights() async {
    final response = await http.get(Uri.parse('$baseUrl/flights'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data);
      final List flights = data['data'] ?? [];
      return flights.map((f) => Flight.fromJson(f)).toList();
    } else {
      throw Exception("Failed to load flights");
    }
  }

  // Search flights
  static Future<List<Flight>> searchFlights(String from, String to, String date) async {
    final response = await http.get(
      Uri.parse('$baseUrl/flights/search?from=$from&to=$to&date=$date'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List flights = data['data'] ?? [];
      return flights.map((f) => Flight.fromJson(f)).toList();
    } else {
      throw Exception("Failed to search flights");
    }
  }

  // Fetch all users
  static Future<List<User>> getUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data);
      return (data as List).map((u) => User.fromJson(u)).toList();
    } else {
      throw Exception("Failed to load users");
    }
  }

  // Fetch single user by ID
  static Future<User> getUserById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$id'));
    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception("User not found");
    }
  }
}
