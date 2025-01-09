import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/joke.dart';

class JokeService {
  final String apiUrl = "https://api.example.com/jokes";

  Future<List<Joke>> fetchJokes() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((joke) => Joke.fromJson(joke)).toList();
    } else {
      throw Exception('Failed to load jokes');
    }
  }
}
