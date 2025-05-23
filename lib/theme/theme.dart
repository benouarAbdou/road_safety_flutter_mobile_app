import 'package:flutter/material.dart';
import 'package:my_pfe/constants/colors.dart';
import 'package:my_pfe/theme/widget_themes/appbar_theme.dart';
import 'package:my_pfe/theme/widget_themes/bottom_sheet_theme.dart';
import 'package:my_pfe/theme/widget_themes/checkbox_theme.dart';
import 'package:my_pfe/theme/widget_themes/chip_theme.dart';
import 'package:my_pfe/theme/widget_themes/elevated_button_theme.dart';
import 'package:my_pfe/theme/widget_themes/outlined_button_theme.dart';
import 'package:my_pfe/theme/widget_themes/text_field_theme.dart';
import 'package:my_pfe/theme/widget_themes/text_theme.dart';

class my_pfe_Theme {
  my_pfe_Theme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: false,
    fontFamily: 'Poppins',
    disabledColor: TColors.grey,
    brightness: Brightness.light,
    primaryColor: TColors.primary,
    textTheme: TTextTheme.lightTextTheme,
    chipTheme: TChipTheme.lightChipTheme,
    scaffoldBackgroundColor: const Color(0xFFF1F1F1), // White background
    appBarTheme: TAppBarTheme.lightAppBarTheme,
    checkboxTheme: TCheckboxTheme.lightCheckboxTheme,
    bottomSheetTheme: TBottomSheetTheme.lightBottomSheetTheme,
    elevatedButtonTheme: TElevatedButtonTheme.lightElevatedButtonTheme,
    outlinedButtonTheme: TOutlinedButtonTheme.lightOutlinedButtonTheme,
    inputDecorationTheme: TTextFormFieldTheme.lightInputDecorationTheme,
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    disabledColor: TColors.grey,
    brightness: Brightness.dark,
    primaryColor: TColors.primary,
    textTheme: TTextTheme.darkTextTheme,
    chipTheme: TChipTheme.darkChipTheme,
    scaffoldBackgroundColor: TColors.black,
    appBarTheme: TAppBarTheme.darkAppBarTheme,
    checkboxTheme: TCheckboxTheme.darkCheckboxTheme,
    bottomSheetTheme: TBottomSheetTheme.darkBottomSheetTheme,
    elevatedButtonTheme: TElevatedButtonTheme.darkElevatedButtonTheme,
    outlinedButtonTheme: TOutlinedButtonTheme.darkOutlinedButtonTheme,
    inputDecorationTheme: TTextFormFieldTheme.darkInputDecorationTheme,
  );
}
