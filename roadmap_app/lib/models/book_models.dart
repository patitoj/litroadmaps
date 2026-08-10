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