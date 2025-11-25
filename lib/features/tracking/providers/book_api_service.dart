import 'dart:convert';
import 'package:http/http.dart' as http;

class BookApiService {
  static const String _baseUrl = 'https://www.googleapis.com/books/v1/volumes';

  Future<Map<String, dynamic>?> fetchBookByIsbn(String isbn) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl?q=isbn:$isbn'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['totalItems'] > 0) {
          return data['items'][0]['volumeInfo'];
        }
      }
    } catch (e) {
      print('Error fetching book: $e');
    }
    return null;
  }
}
