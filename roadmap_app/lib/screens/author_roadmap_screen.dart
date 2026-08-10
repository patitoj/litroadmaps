import 'package:flutter/material.dart';
import '../models/book_models.dart';
import '../services/api_service.dart';

class AuthorRoadmapScreen extends StatefulWidget {
  final int authorId;
  final String authorName;

  const AuthorRoadmapScreen({super.key, required this.authorId, required this.authorName});

  @override
  State<AuthorRoadmapScreen> createState() => _AuthorRoadmapScreenState();
}

class _AuthorRoadmapScreenState extends State<AuthorRoadmapScreen> {
  final ApiService _apiService = ApiService();
  List<AuthorRoadmapStep> _steps = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchAuthorRoadmap();
  }

  Future<void> _fetchAuthorRoadmap() async {
    try {
      final steps = await _apiService.getAuthorRoadmap(widget.authorId);
      setState(() {
        _steps = steps;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'No se pudo cargar la guía de lectura.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;
    final responsivePadding = screenWidth < 600 ? 16.0 : 32.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Guía de Lectura: ${widget.authorName}'),
        backgroundColor: Colors.teal.withOpacity(0.1), // Color distinto para diferenciar
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
                  ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
                  : _steps.isEmpty
                      ? const Center(child: Text('Aún no hay una guía para este autor.'))
                      : ListView.builder(
                          padding: EdgeInsets.all(responsivePadding),
                          itemCount: _steps.length,
                          itemBuilder: (context, index) {
                            final step = _steps[index];
                            return Card(
                              elevation: 3,
                              margin: const EdgeInsets.only(bottom: 24),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(24),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.teal,
                                  foregroundColor: Colors.white,
                                  radius: 24,
                                  child: Text('${step.stepNumber}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                ),
                                // AQUÍ ESTÁ EL CAMBIO: El título ahora es una columna con los metadatos
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(step.bookTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text('${step.publicationYear}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                        const SizedBox(width: 16),
                                        const Icon(Icons.auto_stories, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text('${step.pageCount} págs', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                      ],
                                    ),
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 12.0),
                                  child: Text(step.justification, style: const TextStyle(fontSize: 16)),
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