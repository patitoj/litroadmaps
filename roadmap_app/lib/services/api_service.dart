import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book_models.dart';

class ApiService {
  static const String _baseUrl = 'https://litroadmaps.onrender.com/api';

  Future<List<SearchResult>> searchBooks(String query) async {
    final url = Uri.parse('$_baseUrl/search?q=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => SearchResult.fromJson(json)).toList();
    } else {
      throw Exception('Error del servidor: ${response.statusCode}');
    }
  }

  Future<List<Recommendation>> getRoadmap(int bookId) async {
    final url = Uri.parse('$_baseUrl/roadmap?book_id=$bookId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Recommendation.fromJson(json)).toList();
    } else {
      throw Exception('Error del servidor: ${response.statusCode}');
    }
  }

  Future<List<AuthorRoadmapStep>> getAuthorRoadmap(int authorId) async {
    final url = Uri.parse('$_baseUrl/author-roadmap?author_id=$authorId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => AuthorRoadmapStep.fromJson(json)).toList();
    } else {
      throw Exception('Error del servidor: ${response.statusCode}');
    }
  }

  Future<List<AuthorSearchResult>> searchAuthors(String query) async {
    final url = Uri.parse('$_baseUrl/search/authors?q=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => AuthorSearchResult.fromJson(json)).toList();
    } else {
      throw Exception('Error del servidor: ${response.statusCode}');
    }
  }
  
  Future<List<SearchResult>> getSuggestedBooks() async {
    final url = Uri.parse('$_baseUrl/suggestions/books');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => SearchResult.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar sugerencias');
    }
  }

  Future<List<AuthorSearchResult>> getSuggestedAuthors() async {
    final url = Uri.parse('$_baseUrl/suggestions/authors');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => AuthorSearchResult.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar sugerencias');
    }
  }

}