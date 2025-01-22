import 'package:flutter/material.dart';
import 'package:scrollable_text_indicator/scrollable_text_indicator.dart';

class Apropos extends StatefulWidget {
  Apropos({Key? key}) : super(key: key);

  @override
  _MyApropos createState() => _MyApropos();
}

class _MyApropos extends State<Apropos> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new Stack(
        children: <Widget>[
          new Container(
            decoration: new BoxDecoration(
              image: new DecorationImage(
                image: new AssetImage("images/fond.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Flex(
            direction: Axis.vertical,
            children: <Widget>[
              Expanded(
                flex: 7,
                child: Container(
                  padding: EdgeInsets.only(top: 60),
                  margin: const EdgeInsets.only(left: 20, right: 20),
                child: const ScrollableTextIndicator(
                  text: Text(
                    """A Propos \nZémiyidon gère aussi bien l'enrégistrement des trajets des chauffeurs que celui des passager et envoi des mails à chacun pour le notifier d'un changement; reservation faite, reservation acceptée. Comment fonctionne t'il? \nDès que vous avez passé la page de connexion, vous enrégistrez les données sur votre trajet (date minimale de départ, lieu de départ, lieu de destination, nombre de personnes) tout en cochant ou en indiquant si vous serai passager(s) ou chauffeur. Après validation, des trajets vous seront proposés si vous êtes passager; vous en sélectionnez un et le validez. Un email sera envoyé au chauffeur. Dès que ce dernier aura accepté, un email contenant vos coordonnées lui sera envoyé et un contenant ses coordonnées vous sera envoyé. Vous pourrez ensuite vous appeler et convenir du lieu de rencontre pour votre voyage\n\nPour toute information ou demande, vous pouvez nous écrire à armand.hinvi@gmail.com en précisant dans le motif Zémiyidon""",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
    ),
            ],
          ),
        ],
      ),
    );
  }
}
