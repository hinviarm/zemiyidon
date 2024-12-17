import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:selectable_autolink_text/selectable_autolink_text.dart';
import 'package:zemiyidon/Vues/profil.dart';
import 'package:zemiyidon/Vues/transition.dart';

class Person extends StatefulWidget {
  Person({super.key});

  @override
  State<Person> createState() => _Person();
}

class _Person extends State<Person> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: new Stack(children: <Widget>[
      new Container(
        decoration: new BoxDecoration(
          image: new DecorationImage(
            image: new AssetImage("images/fond.jpg"),
            fit: BoxFit.cover,
          ),
        ),
      ),
      new Container(
          color: Colors.white.withOpacity(0.7),
          child: new Flex(direction: Axis.vertical, children: <Widget>[
            Expanded(
              flex: 7,
              child: Center(
                child: SelectableAutoLinkText(
                  //'Modifier les informations personnelles',
                  'Déconnection',
                  linkStyle: TextStyle(color: Colors.blueAccent),
                  highlightedLinkStyle: TextStyle(
                    color: Colors.blueAccent,
                    backgroundColor: Colors.blueAccent.withAlpha(0x33),
                  ),
                  onTap: (url) {
                    SessionManager().destroy();
                    Navigator.of(context).pushReplacement(
                      FadePageRoute(
                        builder: (context) => Profil(),
                      ),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: TextButton(
                style: TextButton.styleFrom(
                  fixedSize: const Size(200, 100),
                  backgroundColor: Color(0xffF18265),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  SessionManager().destroy();
                  Navigator.of(context).pushReplacement(
                    FadePageRoute(
                      builder: (context) => Profil(),
                    ),
                  );
                },
                child: Text(
                  "Déconnection",
                  style: TextStyle(
                    color: Color(0xffffffff),
                  ),
                ),
              ),
            )
          ]))
    ]));
  }
}
