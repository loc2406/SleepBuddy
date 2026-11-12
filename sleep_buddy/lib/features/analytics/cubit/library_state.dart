import 'package:flutter/material.dart';
import 'package:sleep_buddy/features/analytics/model/models.dart';

class LibraryState {
  final String searchText;
  final GuideCategory selectedCategory;
  final List<GuideArticle> articles;

  const LibraryState({
    this.searchText = '',
    this.selectedCategory = GuideCategory.all,
    this.articles = const [],
  });

  LibraryState copyWith({
    String? searchText,
    GuideCategory? selectedCategory,
    List<GuideArticle>? articles,
  }) => LibraryState(
    searchText: searchText ?? this.searchText,
    selectedCategory: selectedCategory ?? this.selectedCategory,
    articles: articles ?? this.articles,
  );
}
