import 'package:flutter/material.dart';
import '../models/book_models.dart';
import '../services/api_service.dart';
import 'author_roadmap_screen.dart';
import 'package:flutter/services.dart';


class AuthorSearchScreen extends StatefulWidget {
  const AuthorSearchScreen({super.key});

  @override
  State<AuthorSearchScreen> createState() => _AuthorSearchScreenState();
}

class _AuthorSearchScreenState extends State<AuthorSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();
  
  List<AuthorSearchResult> _results = [];
  List<AuthorSearchResult> _suggestions = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    try {
      final suggestions = await _apiService.getSuggestedAuthors();
      setState(() => _suggestions = suggestions);
    } catch (e) {
      print('No se pudieron cargar las sugerencias de autores: $e');
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
      final results = await _apiService.searchAuthors(query); // O searchBooks para la otra pantalla
      setState(() => _results = results);
    } catch (e) {
      // Reemplazamos el error técnico por un mensaje amigable para el usuario
      setState(() => _errorMessage = 'Estamos teniendo problemas para conectarnos. Por favor, vuelve a intentarlo más tarde.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Extraemos el diseño de la tarjeta a un método
  Widget _buildAuthorCard(AuthorSearchResult author) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: const Icon(Icons.person, color: Colors.teal, size: 32),
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
  }

  @override
  Widget build(BuildContext context) {
    final bool isSearchEmpty = _searchController.text.trim().isEmpty;
    final screenWidth = MediaQuery.of(context).size.width;
    final responsivePadding = screenWidth < 600 ? 16.0 : 32.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Búsqueda por Autor')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: EdgeInsets.all(responsivePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _searchController,
                  
                  // NUEVO: Limitar longitud
                  maxLength: 50,
                  
                  // NUEVO: Bloquear caracteres extraños (solo letras, números y espacios)
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9áéíóúÁÉÍÓÚñÑ ]')),
                  ],
                  
                  onChanged: (_) {
                    // Si el usuario borra el texto, volvemos a mostrar sugerencias
                    if (_searchController.text.isEmpty) {
                      setState(() => _results = []);
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Ej: Albert Camus, Gabriel García Márquez...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _performSearch,
                    ),
                    // NUEVO: Ocultar el contador de caracteres si no querés que se vea abajo a la derecha
                    counterText: '', 
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),
                const SizedBox(height: 24),
                
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_errorMessage.isNotEmpty)
                  Text(_errorMessage, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center)
                
                // MODO SUGERENCIAS
                else if (isSearchEmpty && _suggestions.isNotEmpty)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'Autores para descubrir:',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _suggestions.length,
                            itemBuilder: (context, index) => _buildAuthorCard(_suggestions[index]),
                          ),
                        ),
                      ],
                    ),
                  )
                  
                // MODO RESULTADOS
                else if (!isSearchEmpty && _results.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) => _buildAuthorCard(_results[index]),
                    ),
                  )
                  
                else if (!isSearchEmpty && _results.isEmpty)
                  const Center(child: Text('No se encontraron autores con ese nombre.')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}