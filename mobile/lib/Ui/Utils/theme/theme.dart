import 'package:flutter/material.dart';
import 'appcolor.dart';

import 'color_helpers.dart';

ThemeData themeData = ThemeData(
  primarySwatch: createMaterialColor(
    AppColors.bittersweet,
  ),
  colorScheme: const ColorScheme.light(
    primary: AppColors.bittersweet,
    secondary: AppColors.madison,
  ),
  visualDensity: VisualDensity.adaptivePlatformDensity,
  fontFamily: 'SofiaPro',
);
