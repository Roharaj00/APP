import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const apiUrl = 'http://localhost:3000/api/mock';

  static Future<String> sendMockApiRequest(String qrData) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'qrData': qrData,
      }),
    );

    if (response.statusCode == 200) {
      return response.body; // HTML content
    } else {
      throw Exception('Failed to fetch data from API');
    }
  }

}
