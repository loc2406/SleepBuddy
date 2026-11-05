import 'package:sleep_buddy/features/wellness/domain/model/models.dart';

class AnalyticsState {
  final AnalyticsSection selectedTab;

  const AnalyticsState({
    this.selectedTab = AnalyticsSection.report,
  });

  AnalyticsState copyWith({
    AnalyticsSection? selectedTab,
  }) => AnalyticsState(
    selectedTab: selectedTab ?? this.selectedTab,
  );
}
