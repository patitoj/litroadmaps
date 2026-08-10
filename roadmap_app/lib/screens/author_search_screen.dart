import 'package:flutter/material.dart';
import '../models/book_models.dart';
import '../services/api_service.dart';
import 'author_roadmap_screen.dart';

class AuthorSearchScreen extends StatefulWidget {
  const AuthorSearchScreen({super.key});

  @override
  State<AuthorSearchScreen> createState() => _AuthorSearchScreenState();
}

class _AuthorSearchScreenState extends State<AuthorSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();
  
  List<AuthorSearchResult> _results = [];
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
      final results = await _apiService.searchAuthors(query);
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
      appBar: AppBar(title: const Text('Búsqueda por Autor')),
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
                    hintText: 'Ej: Tolkien, Gabriel García Márquez...',
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
                        final author = _results[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: const Icon(Icons.person, color: Colors.teal),
                            title: Text(author.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AuthorRoadmapScreen(authorId: author.id, authorName: author.name),
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