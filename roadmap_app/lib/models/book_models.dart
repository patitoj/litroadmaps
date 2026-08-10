class SearchResult {
  final int id;
  final String title;
  final int authorId; // ¡Acá agregamos el ID del autor!
  final String authorName;

  SearchResult({
    required this.id, 
    required this.title, 
    required this.authorId, 
    required this.authorName
  });

  factory SearchResult.fromJson(Map json) {
    return SearchResult(
      id: json['id'],
      title: json['title'],
      authorId: json['author_id'], // Lo leemos del JSON de Go
      authorName: json['author_name'],
    );
  }
}

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

class AuthorRoadmapStep {
  final int stepNumber;
  final String bookTitle;
  final String justification;

  AuthorRoadmapStep({
    required this.stepNumber,
    required this.bookTitle,
    required this.justification,
  });

  factory AuthorRoadmapStep.fromJson(Map<String, dynamic> json) {
    return AuthorRoadmapStep(
      stepNumber: json['step_number'],
      bookTitle: json['book_title'],
      justification: json['justification'],
    );
  }
}

class AuthorSearchResult {
  final int id;
  final String name;

  AuthorSearchResult({required this.id, required this.name});

  factory AuthorSearchResult.fromJson(Map<String, dynamic> json) {
    return AuthorSearchResult(
      id: json['id'],
      name: json['name'],
    );
  }
}