import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';

import 'Vues/accueil.dart';
import 'Vues/onglet.dart';
import 'Vues/privacy.dart';
import 'Vues/profil.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //enableEdgeToEdge();
  runApp(const MyApp());
}
/*
void enableEdgeToEdge() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Rendre la barre de statut transparente
      systemNavigationBarColor: Colors.transparent, // Barre de navigation transparente
      systemNavigationBarIconBrightness: Brightness.light, // Icônes en blanc
      statusBarIconBrightness: Brightness.light, // Icônes de la barre de statut en blanc

      systemStatusBarContrastEnforced: false, // Empêche les modifications non voulues sur la barre de statut
      systemNavigationBarContrastEnforced: false, // Empêche les modifications non voulues sur la barre de navigation
    ),
  );
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge, // Active le mode "edge-to-edge"
  );
}
 */

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  Future<bool> checkSession() async {
    String? id = await SessionManager().get("email");
    String? mDP = await SessionManager().get("password");
    bool varaccord = await SessionManager().get("accord") ?? false;

    // Retourne true si les champs ne sont pas vides
    return id != null && id.isNotEmpty && mDP != null && mDP.isNotEmpty && varaccord == true;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zemiyidon',
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('fr'), // Français
      ],
      home: FutureBuilder<bool>(
        future: checkSession(), // Appelle la méthode asynchrone
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Affiche un indicateur de chargement pendant la vérification
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Affiche un message d'erreur si la vérification échoue
            return Center(child: Text('Erreur de session'));
          } else {
            // Vérifie si une session existe
            bool isLoggedIn = snapshot.data ?? false;
            return isLoggedIn ? Onglet() : Privacy();
          }
        },
      ),
      routes: {
        '/onglet': (context) => Onglet(),
        '/profil': (context) => Privacy(),
      },
    );
  }
}

