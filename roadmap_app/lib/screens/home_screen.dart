import 'package:flutter/material.dart';
import 'book_search_screen.dart';
import 'author_search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.menu_book_rounded, size: 90, color: Colors.deepPurple),
                const SizedBox(height: 24),
                const Text(
                  'Literary Roadmap',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  '¿Cómo te gustaría comenzar tu exploración?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 48),
                
                // Botón Buscar por Libro
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(20),
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.book, size: 28),
                  label: const Text('Buscar por Libro', style: TextStyle(fontSize: 18)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BookSearchScreen()),
                    );
                  },
                ),
                
                const SizedBox(height: 20),

                // Botón Buscar por Autor
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(20),
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.person, size: 28),
                  label: const Text('Buscar por Autor', style: TextStyle(fontSize: 18)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AuthorSearchScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}