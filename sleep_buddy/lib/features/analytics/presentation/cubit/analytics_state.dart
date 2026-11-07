import 'package:sleep_buddy/features/analytics/presentation/models/models.dart';

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
