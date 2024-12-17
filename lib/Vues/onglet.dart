import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:zemiyidon/Vues/person.dart';
import 'accueil.dart';
import 'profil.dart';

class Onglet extends StatefulWidget {
  const Onglet({Key? key}) : super(key: key);
  @override
  _MonOnglet createState() => _MonOnglet();
}
class _MonOnglet extends State<Onglet> {
  final PageController _controller = PageController(initialPage: 0);
  int _currentIndex = 0;
  String prenom = "";

  @override
  void initState(){
    recupPrenom();
    super.initState();
  }

  void recupPrenom() async{
    prenom = await SessionManager().get("prenom");
    setState(() {
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
      bottomNavigationBar: new Theme(
        data: Theme.of(context).copyWith(
          // sets the background color of the `BottomNavigationBar`
            canvasColor: Colors.cyan,
            // sets the active color of the `BottomNavigationBar` if `Brightness` is light
            primaryColor: Colors.lightBlue,
            textTheme: Theme.of(context)
                .textTheme
                .copyWith(bodySmall: TextStyle(color: Colors.yellow))),
        child: new BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            _controller.jumpToPage(_currentIndex);
          },
          items: <BottomNavigationBarItem>[
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.boy_rounded),
              label: prenom,
            ),
          ],
        ),
      ),
    );
  }
}
