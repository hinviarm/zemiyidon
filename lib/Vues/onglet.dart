import 'package:flutter/material.dart';
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
          Profil(),
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
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.boy_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
