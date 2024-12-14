import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';

import 'Vues/onglet.dart';
import 'Vues/profil.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  String? id = "";
  String? mDP = "";

  bool sess = false;
  void recSession() async {
    id = await SessionManager().get("email");
    mDP = await SessionManager().get("password");
  }
  @override
  Widget build(BuildContext context) {
    recSession();
    if (id != null && mDP != null && id !="" && mDP != "") {
      sess = true;
    }
    debugPrint("session: "+sess.toString());
    return MaterialApp(
        title: 'Zemiyidon',
        home:Column(
          children: [
            if (sess) ...[
              Onglet(),
            ] else ...[
              Profil(),
            ],
          ],
        ),
        routes: {
          '/onglet': (context) => Onglet(),
          '/profil': (context) => Profil(),
        },
        initialRoute: sess == true ? '/onglet': '/profil');
  }
}
