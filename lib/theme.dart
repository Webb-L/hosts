import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(4283196971),
      surfaceTint: Color(4283196971),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4291685795),
      onPrimaryContainer: Color(4279246848),
      secondary: Color(4283982409),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4292667336),
      onSecondaryContainer: Color(4279574027),
      tertiary: Color(4281886307),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4290571495),
      onTertiaryContainer: Color(4278198302),
      error: Color(4290386458),
      onError: Color(4294967295),
      errorContainer: Color(4294957782),
      onErrorContainer: Color(4282449922),
      surface: Color(4294572783),
      onSurface: Color(4279901206),
      onSurfaceVariant: Color(4282665021),
      outline: Color(4285888876),
      outlineVariant: Color(4291152058),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281282858),
      inversePrimary: Color(4289843594),
      primaryFixed: Color(4291685795),
      onPrimaryFixed: Color(4279246848),
      primaryFixedDim: Color(4289843594),
      onPrimaryFixedVariant: Color(4281683478),
      secondaryFixed: Color(4292667336),
      onSecondaryFixed: Color(4279574027),
      secondaryFixedDim: Color(4290759597),
      onSecondaryFixedVariant: Color(4282403379),
      tertiaryFixed: Color(4290571495),
      onTertiaryFixed: Color(4278198302),
      tertiaryFixedDim: Color(4288729291),
      onTertiaryFixedVariant: Color(4280241739),
      surfaceDim: Color(4292533200),
      surfaceBright: Color(4294572783),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294178025),
      surfaceContainer: Color(4293849059),
      surfaceContainerHigh: Color(4293454302),
      surfaceContainerHighest: Color(4293059544),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(4281420306),
      surfaceTint: Color(4283196971),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4284579135),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4282140207),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4285429854),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4279913031),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4283399545),
      onTertiaryContainer: Color(4294967295),
      error: Color(4287365129),
      onError: Color(4294967295),
      errorContainer: Color(4292490286),
      onErrorContainer: Color(4294967295),
      surface: Color(4294572783),
      onSurface: Color(4279901206),
      onSurfaceVariant: Color(4282401849),
      outline: Color(4284309845),
      outlineVariant: Color(4286086256),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281282858),
      inversePrimary: Color(4289843594),
      primaryFixed: Color(4284579135),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4282999849),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4285429854),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4283785031),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4283399545),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4281754720),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4292533200),
      surfaceBright: Color(4294572783),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294178025),
      surfaceContainer: Color(4293849059),
      surfaceContainerHigh: Color(4293454302),
      surfaceContainerHighest: Color(4293059544),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(4279510784),
      surfaceTint: Color(4283196971),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4281420306),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4280034577),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4282140207),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4278200101),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4279913031),
      onTertiaryContainer: Color(4294967295),
      error: Color(4283301890),
      onError: Color(4294967295),
      errorContainer: Color(4287365129),
      onErrorContainer: Color(4294967295),
      surface: Color(4294572783),
      onSurface: Color(4278190080),
      onSurfaceVariant: Color(4280362268),
      outline: Color(4282401849),
      outlineVariant: Color(4282401849),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281282858),
      inversePrimary: Color(4292278188),
      primaryFixed: Color(4281420306),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4280038144),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4282140207),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4280692763),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4279913031),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4278203185),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4292533200),
      surfaceBright: Color(4294572783),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294178025),
      surfaceContainer: Color(4293849059),
      surfaceContainerHigh: Color(4293454302),
      surfaceContainerHighest: Color(4293059544),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(4289843594),
      surfaceTint: Color(4289843594),
      onPrimary: Color(4280235777),
      primaryContainer: Color(4281683478),
      onPrimaryContainer: Color(4291685795),
      secondary: Color(4290759597),
      onSecondary: Color(4280955678),
      secondaryContainer: Color(4282403379),
      onSecondaryContainer: Color(4292667336),
      tertiary: Color(4288729291),
      onTertiary: Color(4278204213),
      tertiaryContainer: Color(4280241739),
      onTertiaryContainer: Color(4290571495),
      error: Color(4294948011),
      onError: Color(4285071365),
      errorContainer: Color(4287823882),
      onErrorContainer: Color(4294957782),
      surface: Color(4279374862),
      onSurface: Color(4293059544),
      onSurfaceVariant: Color(4291152058),
      outline: Color(4287599237),
      outlineVariant: Color(4282665021),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4293059544),
      inversePrimary: Color(4283196971),
      primaryFixed: Color(4291685795),
      onPrimaryFixed: Color(4279246848),
      primaryFixedDim: Color(4289843594),
      onPrimaryFixedVariant: Color(4281683478),
      secondaryFixed: Color(4292667336),
      onSecondaryFixed: Color(4279574027),
      secondaryFixedDim: Color(4290759597),
      onSecondaryFixedVariant: Color(4282403379),
      tertiaryFixed: Color(4290571495),
      onTertiaryFixed: Color(4278198302),
      tertiaryFixedDim: Color(4288729291),
      onTertiaryFixedVariant: Color(4280241739),
      surfaceDim: Color(4279374862),
      surfaceBright: Color(4281874994),
      surfaceContainerLowest: Color(4278980361),
      surfaceContainerLow: Color(4279901206),
      surfaceContainer: Color(4280164378),
      surfaceContainerHigh: Color(4280822564),
      surfaceContainerHighest: Color(4281546286),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(4290106766),
      surfaceTint: Color(4289843594),
      onPrimary: Color(4278983168),
      primaryContainer: Color(4286421593),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4291088305),
      onSecondary: Color(4279245063),
      secondaryContainer: Color(4287272313),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4288992464),
      onTertiary: Color(4278196761),
      tertiaryContainer: Color(4285241749),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294949553),
      onError: Color(4281794561),
      errorContainer: Color(4294923337),
      onErrorContainer: Color(4278190080),
      surface: Color(4279374862),
      onSurface: Color(4294704368),
      onSurfaceVariant: Color(4291415230),
      outline: Color(4288783511),
      outlineVariant: Color(4286678392),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4293059544),
      inversePrimary: Color(4281749271),
      primaryFixed: Color(4291685795),
      onPrimaryFixed: Color(4278719488),
      primaryFixedDim: Color(4289843594),
      onPrimaryFixedVariant: Color(4280630533),
      secondaryFixed: Color(4292667336),
      onSecondaryFixed: Color(4278916099),
      secondaryFixedDim: Color(4290759597),
      onSecondaryFixedVariant: Color(4281350436),
      tertiaryFixed: Color(4290571495),
      onTertiaryFixed: Color(4278195219),
      tertiaryFixedDim: Color(4288729291),
      onTertiaryFixedVariant: Color(4278730042),
      surfaceDim: Color(4279374862),
      surfaceBright: Color(4281874994),
      surfaceContainerLowest: Color(4278980361),
      surfaceContainerLow: Color(4279901206),
      surfaceContainer: Color(4280164378),
      surfaceContainerHigh: Color(4280822564),
      surfaceContainerHighest: Color(4281546286),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(4294246367),
      surfaceTint: Color(4289843594),
      onPrimary: Color(4278190080),
      primaryContainer: Color(4290106766),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4294246367),
      onSecondary: Color(4278190080),
      secondaryContainer: Color(4291088305),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4293591036),
      onTertiary: Color(4278190080),
      tertiaryContainer: Color(4288992464),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294965753),
      onError: Color(4278190080),
      errorContainer: Color(4294949553),
      onErrorContainer: Color(4278190080),
      surface: Color(4279374862),
      onSurface: Color(4294967295),
      onSurfaceVariant: Color(4294573293),
      outline: Color(4291415230),
      outlineVariant: Color(4291415230),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4293059544),
      inversePrimary: Color(4279906304),
      primaryFixed: Color(4291949223),
      onPrimaryFixed: Color(4278190080),
      primaryFixedDim: Color(4290106766),
      onPrimaryFixedVariant: Color(4278983168),
      secondaryFixed: Color(4292930508),
      onSecondaryFixed: Color(4278190080),
      secondaryFixedDim: Color(4291088305),
      onSecondaryFixedVariant: Color(4279245063),
      tertiaryFixed: Color(4290834668),
      onTertiaryFixed: Color(4278190080),
      tertiaryFixedDim: Color(4288992464),
      onTertiaryFixedVariant: Color(4278196761),
      surfaceDim: Color(4279374862),
      surfaceBright: Color(4281874994),
      surfaceContainerLowest: Color(4278980361),
      surfaceContainerLow: Color(4279901206),
      surfaceContainer: Color(4280164378),
      surfaceContainerHigh: Color(4280822564),
      surfaceContainerHighest: Color(4281546286),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }


  ThemeData theme(ColorScheme colorScheme) => ThemeData(
     useMaterial3: true,
     brightness: colorScheme.brightness,
     colorScheme: colorScheme,
     textTheme: textTheme.apply(
       bodyColor: colorScheme.onSurface,
       displayColor: colorScheme.onSurface,
     ),
     scaffoldBackgroundColor: colorScheme.background,
     canvasColor: colorScheme.surface,
  );


  List<ExtendedColor> get extendedColors => [
  ];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
