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
  List<SearchResult> _suggestions = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    try {
      final suggestions = await _apiService.getSuggestedBooks();
      setState(() => _suggestions = suggestions);
    } catch (e) {
      // Si fallan las sugerencias, simplemente no mostramos nada
      print('No se pudieron cargar las sugerencias: $e');
    }
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _errorMessage = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _results = [];
    });

    try {
      final results = await _apiService.searchBooks(query);
      setState(() => _results = results);
    } catch (e) {
      setState(() => _errorMessage = 'Error técnico detectado:\n$e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Extraemos el diseño de la tarjeta a un método para reusarlo en sugerencias y resultados
  Widget _buildBookCard(SearchResult book) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: const Icon(Icons.book, color: Colors.deepPurple, size: 32),
        title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Autor: ${book.authorName}', 
                style: const TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w500)
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text('${book.publicationYear}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(width: 16),
                  const Icon(Icons.auto_stories, size: 14, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text('${book.pageCount} págs', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ],
          ),
        ),
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
  }

  @override
  Widget build(BuildContext context) {
    final bool isSearchEmpty = _searchController.text.trim().isEmpty;

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
                  onChanged: (_) {
                    // Si el usuario borra el texto, volvemos a mostrar sugerencias
                    if (_searchController.text.isEmpty) {
                      setState(() => _results = []);
                    }
                  },
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
                
                // MODO SUGERENCIAS (Cuando no hay búsqueda)
                else if (isSearchEmpty && _suggestions.isNotEmpty)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'Sugerencias para empezar:',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _suggestions.length,
                            itemBuilder: (context, index) => _buildBookCard(_suggestions[index]),
                          ),
                        ),
                      ],
                    ),
                  )
                  
                // MODO RESULTADOS DE BÚSQUEDA
                else if (!isSearchEmpty && _results.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) => _buildBookCard(_results[index]),
                    ),
                  )
                  
                else if (!isSearchEmpty && _results.isEmpty)
                  const Center(child: Text('No se encontraron libros con ese nombre.')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}