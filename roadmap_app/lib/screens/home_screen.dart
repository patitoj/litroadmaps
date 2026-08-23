import 'package:flutter/material.dart';
import 'book_search_screen.dart';
import 'author_search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final responsivePadding = screenWidth < 600 ? 16.0 : 32.0;
    
    return Scaffold(
      // Agregamos SafeArea para que el texto no se superponga con la barra de navegación del celular
      body: SafeArea(
        child: Stack(
          children: [
            // 1. TU CONTENIDO PRINCIPAL (Centrado)
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Padding(
                  padding: EdgeInsets.all(responsivePadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.menu_book_rounded, size: 90, color: Colors.deepPurple),
                      const SizedBox(height: 24),
                      const Text(
                        'LitRoadmaps',
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

            // 2. TEXTO EN LA PARTE INFERIOR
            const Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 24.0),
                child: Text(
                  'Hecho en Argentina 🇦🇷',
                  style: TextStyle(
                    color: Colors.black45, // Un gris oscuro estético
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.5, // Separa un poco las letras para darle un toque premium
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}