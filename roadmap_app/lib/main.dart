import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const RoadmapApp());
}

class RoadmapApp extends StatelessWidget {
  const RoadmapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Literary Roadmap',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SearchScreen(),
    );
  }
}

// --- MODELOS DE DATOS ---

class SearchResult {
  final int id;
  final String title;
  final String authorName;

  SearchResult({required this.id, required this.title, required this.authorName});

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      id: json['id'],
      title: json['title'],
      authorName: json['author_name'],
    );
  }
}

// NUEVO: Modelo para las recomendaciones del Roadmap
class Recommendation {
  final String recommendedBook;
  final String authorName;
  final String connectionReason;

  Recommendation({
    required this.recommendedBook,
    required this.authorName,
    required this.connectionReason,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      recommendedBook: json['recommended_book'],
      authorName: json['author_name'],
      connectionReason: json['connection_reason'],
    );
  }
}

// --- PANTALLA 1: BUSCADOR ---

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
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
      final url = Uri.parse('http://localhost:8080/api/search?q=$query');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        setState(() {
          _results = jsonList.map((json) => SearchResult.fromJson(json)).toList();
        });
      } else {
        setState(() => _errorMessage = 'Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _errorMessage = 'No se pudo conectar a la API.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                const Icon(Icons.menu_book_rounded, size: 80, color: Colors.deepPurple),
                const SizedBox(height: 24),
                const Text(
                  'Descubrí tu próxima lectura',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Ej: Dorian Gray, Gabriel García Márquez...',
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
                            title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(book.authorName),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              // NUEVO: Navegamos a la pantalla del Roadmap pasando el ID
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RoadmapScreen(
                                    bookId: book.id,
                                    bookTitle: book.title,
                                  ),
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

// --- PANTALLA 2: EL ROADMAP (NUEVA) ---

class RoadmapScreen extends StatefulWidget {
  final int bookId;
  final String bookTitle;

  const RoadmapScreen({super.key, required this.bookId, required this.bookTitle});

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  List<Recommendation> _roadmap = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchRoadmap(); // Cargamos los datos apenas se abre la pantalla
  }

  Future<void> _fetchRoadmap() async {
    try {
      final url = Uri.parse('http://localhost:8080/api/roadmap?book_id=${widget.bookId}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        setState(() {
          _roadmap = jsonList.map((json) => Recommendation.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Error del servidor: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'No se pudo conectar a la API.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Roadmap: ${widget.bookTitle}'),
        backgroundColor: Colors.deepPurple.withOpacity(0.1),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
                  ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
                  : _roadmap.isEmpty
                      ? const Center(child: Text('Aún no hay lecturas conectadas para este libro.'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(32),
                          itemCount: _roadmap.length,
                          // El separador actúa como la "línea" del mapa
                          separatorBuilder: (context, index) => const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Icon(Icons.arrow_downward, color: Colors.deepPurple, size: 40),
                          ),
                          itemBuilder: (context, index) {
                            final rec = _roadmap[index];
                            return Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Siguiente parada:',
                                      style: TextStyle(color: Colors.deepPurple.shade300, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      rec.recommendedBook,
                                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'por ${rec.authorName}',
                                      style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                                    ),
                                    const Divider(height: 32),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.lightbulb_outline, color: Colors.amber),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            rec.connectionReason,
                                            style: const TextStyle(fontSize: 15, height: 1.5),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
        ),
      ),
    );
  }
}