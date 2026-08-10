class SearchResult {
  final int id;
  final String title;
  final int authorId;
  final String authorName;
  final int publicationYear;
  final int pageCount;

  SearchResult({
    required this.id, 
    required this.title, 
    required this.authorId, 
    required this.authorName,
    required this.publicationYear,
    required this.pageCount,
  });

  factory SearchResult.fromJson(Map json) {
    return SearchResult(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? 'Sin título',
      authorId: int.tryParse(json['author_id']?.toString() ?? '0') ?? 0,
      authorName: json['author_name']?.toString() ?? 'Autor desconocido',
      publicationYear: int.tryParse(json['publication_year']?.toString() ?? '0') ?? 0,
      pageCount: int.tryParse(json['page_count']?.toString() ?? '0') ?? 0,
    );
  }
}

class Recommendation {
  final String recommendedBook;
  final String authorName;
  final String connectionReason;
  final String connectionType;
  final int order;

  Recommendation({
    required this.recommendedBook,
    required this.authorName,
    required this.connectionReason,
    required this.connectionType,
    required this.order,
  });

  factory Recommendation.fromJson(Map json) {
    return Recommendation(
      recommendedBook: json['recommended_book']?.toString() ?? 'Libro desconocido',
      authorName: json['author_name']?.toString() ?? 'Autor desconocido',
      connectionReason: json['connection_reason']?.toString() ?? '',
      connectionType: json['connection_type']?.toString() ?? 'relacionado',
      order: int.tryParse(json['recommendation_order']?.toString() ?? '1') ?? 1,
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

  factory AuthorRoadmapStep.fromJson(Map json) {
    return AuthorRoadmapStep(
      stepNumber: int.tryParse(json['step_number']?.toString() ?? '1') ?? 1,
      bookTitle: json['book_title']?.toString() ?? '',
      justification: json['justification']?.toString() ?? '',
    );
  }
}

class AuthorSearchResult {
  final int id;
  final String name;

  AuthorSearchResult({required this.id, required this.name});

  factory AuthorSearchResult.fromJson(Map json) {
    return AuthorSearchResult(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }
}