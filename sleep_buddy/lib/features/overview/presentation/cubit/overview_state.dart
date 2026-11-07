class OverviewState {
  final bool isNightMode;

  OverviewState({this.isNightMode = false});

  OverviewState change({bool? isNightMode}) =>
      OverviewState(isNightMode: isNightMode ?? this.isNightMode);
}
