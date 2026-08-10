import 'package:flutter/material.dart';
import '../models/book_models.dart';
import '../services/api_service.dart';
import 'roadmap_screen.dart';

class BookSearchScreen extends StatefulWidget {
  const BookSearchScreen({super.key});

  @override
  State<BookSearchScreen> createState() => _BookSearchScreenState();
}

class _BookSearchScreenState extends State<BookSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();
  
  List<SearchResult> _results = [];
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _results = [];
    });

    try {
      final results = await _apiService.searchBooks(query);
      setState(() => _results = results);
    } catch (e) {
      setState(() => _errorMessage = 'No se pudo conectar a la API.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Búsqueda por Libro')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Ej: El Hobbit, Dorian Gray...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _performSearch,
                    ),
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),
                const SizedBox(height: 24),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_errorMessage.isNotEmpty)
                  Text(_errorMessage, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center)
                else if (_results.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final book = _results[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: const Icon(Icons.book, color: Colors.deepPurple),
                            title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            subtitle: Text('Autor: ${book.authorName}', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RoadmapScreen(bookId: book.id, bookTitle: book.title),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}