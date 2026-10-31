
import 'package:flutter/material.dart';

enum DeviceType {
  mobile,
  tablet,
  desktop,
}

class Responsive {
  Responsive._();

  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double maxContentWidth = 1440;

  static DeviceType getDeviceType(double width) {
    if (width < mobileBreakpoint) {
      return DeviceType.mobile;
    }

    if (width < tabletBreakpoint) {
      return DeviceType.tablet;
    }

    return DeviceType.desktop;
  }

  static int getGridColumns(double width) {
    switch (getDeviceType(width)) {
      case DeviceType.mobile:
        return 1;
      case DeviceType.tablet:
        return 2;
      case DeviceType.desktop:
        return 3;
    }
  }

  static EdgeInsets getScreenPadding(double width) {
    switch (getDeviceType(width)) {
      case DeviceType.mobile:
        return const EdgeInsets.all(20);
      case DeviceType.tablet:
        return const EdgeInsets.all(32);
      case DeviceType.desktop:
        return const EdgeInsets.all(60);
    }
  }
}
