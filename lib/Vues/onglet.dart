import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'accueil.dart';
import 'person.dart';

class Onglet extends StatefulWidget {
  const Onglet({Key? key}) : super(key: key);

  @override
  _MonOnglet createState() => _MonOnglet();
}

class _MonOnglet extends State<Onglet> {
  final PageController _controller = PageController(initialPage: 0);
  int _currentIndex = 0;
  String prenom = "Utilisateur"; // Valeur par défaut

  @override
  void initState() {
    super.initState();
    recupPrenom();
  }

  void recupPrenom() async {
    String? fetchedPrenom = await SessionManager().get("prenom");
    setState(() {
      prenom = fetchedPrenom ?? "Utilisateur"; // Valeur par défaut si null
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        controller: _controller,
        children: <Widget>[
          Accueil(),
          Person(),
        ],
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.cyan,
          primaryColor: Colors.lightBlue,
          textTheme: Theme.of(context).textTheme.copyWith(
            bodySmall: const TextStyle(color: Colors.yellow),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index; // Gère directement sans null
            });
            _controller.jumpToPage(index); // Synchronisation
          },
          items: <BottomNavigationBarItem>[
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.boy_rounded),
              label: prenom.isNotEmpty ? prenom : 'Profil', // Valeur par défaut
            ),
          ],
        ),
      ),
    );
  }
}
