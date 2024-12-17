import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';

import 'Vues/onglet.dart';
import 'Vues/profil.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> checkSession() async {
    String? id = await SessionManager().get("email");
    String? mDP = await SessionManager().get("password");

    // Retourne true si les champs ne sont pas vides
    return id != null && id.isNotEmpty && mDP != null && mDP.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zemiyidon',
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
            return isLoggedIn ? Onglet() : Profil();
          }
        },
      ),
      routes: {
        '/onglet': (context) => Onglet(),
        '/profil': (context) => Profil(),
      },
    );
  }
}

