import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/main_navigation_shell.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.midnightObsidian,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const ApertureApp());
}

class ApertureApp extends StatelessWidget {
  const ApertureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aperture Travel',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      home: const MainNavigationShell(),
    );
  }
}
