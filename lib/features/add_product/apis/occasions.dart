import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OccasionService {
  Future<List<String>> fetchOccasionOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final wholesalerId = prefs.getInt('wholesalerId');

    if (wholesalerId == null) {
      throw Exception('wholesalerId not found in shared preferences');
    }
    final response = await http.get(
      Uri.parse(
          'https://upload-service-254137058023.asia-south1.run.app/upload/$wholesalerId/occasion'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      print('API Response: $data'); // Debugging purposes

      // Extract giftingName field
      return data.map((item) => item['giftingName'].toString()).toList();
    } else {
      throw Exception('Failed to load occasion options');
    }
  }
}
