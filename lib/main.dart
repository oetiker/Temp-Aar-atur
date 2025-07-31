import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/widgets/error_boundary.dart';
import 'l10n/app_localizations.dart';
import 'features/temperature/screens/home_screen.dart';
void main() {
  runApp(
    ErrorBoundary(
      child: const TemperAareApp(),
    ),
  );
}

class TemperAareApp extends StatelessWidget {
  const TemperAareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('de'), // German  
        Locale('fr'), // French
      ],
      title: 'TemperAare - Olten',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}
