import 'package:equatable/equatable.dart';

class SearchHistoryItem extends Equatable {
  final String query;
  final DateTime timestamp;

  const SearchHistoryItem({
    required this.query,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'query': query,
        'timestamp': timestamp.toIso8601String(),
      };

  factory SearchHistoryItem.fromJson(Map<String, dynamic> json) =>
      SearchHistoryItem(
        query: json['query'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  @override
  List<Object?> get props => [query, timestamp];
}
