import 'package:flutter/material.dart';
import '../models/book_models.dart';
import '../services/api_service.dart';

class RoadmapScreen extends StatefulWidget {
  final int bookId;
  final String bookTitle;

  const RoadmapScreen({super.key, required this.bookId, required this.bookTitle});

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  final ApiService _apiService = ApiService();
  List<Recommendation> _roadmap = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchRoadmap();
  }

  Future<void> _fetchRoadmap() async {
    try {
      final roadmap = await _apiService.getRoadmap(widget.bookId);
      setState(() {
        _roadmap = roadmap;
        _isLoading = false;
      });
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
                                    Text('Siguiente parada:', style: TextStyle(color: Colors.deepPurple.shade300, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    Text(rec.recommendedBook, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                    Text('por ${rec.authorName}', style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
                                    const Divider(height: 32),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.lightbulb_outline, color: Colors.amber),
                                        const SizedBox(width: 12),
                                        Expanded(child: Text(rec.connectionReason, style: const TextStyle(fontSize: 15, height: 1.5))),
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