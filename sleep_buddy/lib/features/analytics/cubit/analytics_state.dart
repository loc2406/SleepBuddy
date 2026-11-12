import 'package:sleep_buddy/features/analytics/model/models.dart';

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
