import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const List<String> kAvailableFonts = [
  'Roboto',
  'Pacifico',
  'Lato',
  'Poppins',
  'Montserrat',
  'Open Sans',
  'Raleway',
  'Nunito',
  'Oswald',
  'Merriweather',
  'Quicksand',
  'Source Sans Pro',
  'Ubuntu',
  'PT Sans',
  'Playfair Display',
  'Muli',
  'Arimo',
  'Josefin Sans',
  'Work Sans',
  'Rubik',
  'Fira Sans',
  'Dosis',
  'Archivo',
  'Exo 2',
  'Cabin',
  'Titillium Web',
  'Karla',
  'Asap',
  'Varela Round',
  'Teko',
  'Bebas Neue',
  'Barlow',
  'Manrope',
  'Inter',
  'Heebo',
  'Zilla Slab',
  'Righteous',
  'Cairo',
  'Signika',
  'Overpass',
  'Abel',
  'Questrial',
  'Chivo',
  'IBM Plex Sans',
  'Mukta',
  'Hind',
  'Space Grotesk',
  'Noto Sans',
  'Baloo 2',
  'Mulish',
  'DM Sans',
];

TextStyle safeFont({
  required String fontName,
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
}) {
  try {
    return GoogleFonts.getFont(
      fontName,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  } catch (e) {
    return GoogleFonts.roboto(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }
}

const List<Color> kAvailableColors1 = [
  Color(0xFF0037B3), // Default Blue
  Color(0xFF2563EB), // Blue
  Color(0xFF10B981), // Green
  Color(0xFFEF4444), // Red
  Color(0xFFF59E0B), // Amber
  Color(0xFF8B5CF6), // Purple
  Color(0xFFEC4899), // Pink
  Color(0xFF06B6D4), // Cyan
];

final List<Color> kAvailableColors = [
  const Color(0xFF6366F1),
  ...List.generate(
    100,
    (index) => Color((0xFF000000 + index * 200000) | 0xFF000000),
  ),
];
