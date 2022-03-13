import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:puzzle/app/resources/reusables.dart';

ThemeData lightTheme = ThemeData(
  fontFamily: GoogleFonts.convergence().fontFamily,
  tooltipTheme: TooltipThemeData(
    textStyle: GoogleFonts.openSans().copyWith(
      fontWeight: FontWeight.w400,
      fontSize: 14,
      color: Colors.white,
    ),
    margin: const EdgeInsets.only(left: 100, right: 40),
    triggerMode: TooltipTriggerMode.tap,
    padding: padding8,
    decoration: BoxDecoration(
      color: Colors.grey.shade900,
      borderRadius: circular4,
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.grey.shade300.withOpacity(.5),
    sizeConstraints: BoxConstraints(
       maxWidth: 300,
      minWidth: 300
    ),

    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: BorderSide(
         color: Colors.grey.shade700,
        width: 3,
      )
    )
  )
);
