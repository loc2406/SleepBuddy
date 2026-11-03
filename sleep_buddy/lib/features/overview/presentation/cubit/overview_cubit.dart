import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sleep_buddy/core/utils/shared_pref.dart';
import 'package:sleep_buddy/features/overview/presentation/cubit/overview_state.dart';

class OverviewCubit extends Cubit<OverviewState> {
  OverviewCubit() : super(OverviewState());

  Future<void> loadTheme() async {
    final isNightMode = await SharedPref.getBool(SharedPref.themeMode);
    emit(state.change(isNightMode: isNightMode));
  }

  Future<void> changeTheme(bool isNightMode) async {
    await SharedPref.setBool(key: SharedPref.themeMode, value: isNightMode);
    emit(state.change(isNightMode: isNightMode));
  }
}
