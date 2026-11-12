import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MinuteTickerCubit extends Cubit<DateTime> with WidgetsBindingObserver {
  MinuteTickerCubit() : super(DateTime.now()) {
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _emitNow());
  }

  late final Timer _timer;

  void _emitNow() {
    if (!isClosed) emit(DateTime.now());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _emitNow();
  }

  @override
  Future<void> close() {
    _timer.cancel();
    WidgetsBinding.instance.removeObserver(this);
    return super.close();
  }
}
