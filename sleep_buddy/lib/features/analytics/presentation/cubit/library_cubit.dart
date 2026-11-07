import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sleep_buddy/core/db/guide_article_dao.dart';
import 'package:sleep_buddy/features/analytics/presentation/cubit/library_state.dart';
import 'package:sleep_buddy/features/analytics/presentation/models/models.dart';

class LibraryCubit extends Cubit<LibraryState> {
  int _filterVersion = 0;

  LibraryCubit() : super(LibraryState()) {
    _getInitData();
  }

  Future<void> _getInitData() async {
    final articles = await GuideArticleDao.getAll();
    emit(state.copyWith(articles: articles));
  }

  Future<void> searchArticles(String searchText) async {
    final normalizedText = searchText.trim();
    emit(state.copyWith(searchText: normalizedText));
    await _applyFilters();
  }

  Future<void> selectCategory(GuideCategory category) async {
    emit(state.copyWith(selectedCategory: category));
    await _applyFilters();
  }

  Future<void> _applyFilters() async {
    final filterVersion = ++_filterVersion;
    final articles = await GuideArticleDao.search(
      searchText: state.searchText,
      category: state.selectedCategory,
    );

    if (isClosed) return;
    if (filterVersion != _filterVersion) return;
    emit(state.copyWith(articles: articles));
  }
}
