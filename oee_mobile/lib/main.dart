import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:oee_mobile/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'views/entity_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Server URL is now set automatically when needed by EntityController
  // No need to call EntityController.setServerUrl() anymore

  // run the application now
  runApp(const ProviderScope(child: OeeMobileApp()));
}

// the OEE application
class OeeMobileApp extends StatelessWidget {
  const OeeMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "OEE",
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
      ],
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const OeeEntityPage(),
    );
  }
}
