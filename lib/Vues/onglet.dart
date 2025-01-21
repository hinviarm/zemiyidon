import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
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
  List<String> telChauffeur = [];
  String email = "";
  String nom = "";
  String telephone = "";

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

  void notificationAlerte() async {
    email = await SessionManager().get("email");
    var urlString = 'http://149.202.45.36:8008/rechercheVoyage?Email=${email}';
    var url = Uri.parse(urlString);
    var response = await http.get(url);

    if (response.statusCode == 200 && mounted) {
      var wordShow = convert.jsonDecode(response.body);
      if (wordShow.toString() != "[]") {
        for (var elem in wordShow) {
          if (elem[2] == 1) {
            _showFlushbar(
              title: "Vous êtes chauffeur:",
              message: "Votre trajet est de: ${elem[7]} à ${elem[8]} le : ${elem[9].toString().replaceAll('T', " à ")}",
            );
          } else if (elem[2] == null) {
            var message = "Voulez-vous accepter la réservation de : ${elem[14]} ${elem[15]} "
                "sur le trajet ${elem[7]} à ${elem[8]} le : ${elem[9].toString().replaceAll('T', " à ")}";
            debugPrint(message);

            await _showAlert(
              context: context,
              title: "Réservation",
              description: message,
              onConfirm: () async {
                await _acceptReservation(elem);
              },
              onCancel: () async {
                await _cancelReservation(elem);
              },
            );
          } else if (elem[2] == 0) {
            _showFlushbar(
              title: "Vous êtes passager:",
              message: "Votre trajet est de: ${elem[7]} à ${elem[8]} le : ${elem[9].toString().replaceAll('T', " à ")}",
            );
          } else {
            _showFlushbar(
              title: "Patientez !",
              message: "Votre trajet n'a pas encore été validé. Un message vous sera envoyé dès que le chauffeur aura validé.",
            );
          }
        }
      }
    }
  }

  Future<void> _showFlushbar({required String title, required String message}) async {
    await Flushbar(
      title: title,
      message: message,
      duration: const Duration(seconds: 15),
    ).show(context);
  }

  Future<void> _showAlert({
    required BuildContext context,
    required String title,
    required String description,
    required VoidCallback onConfirm,
    required VoidCallback onCancel,
  }) async {
    await Alert(
      context: context,
      type: AlertType.none,
      title: title,
      desc: description,
      buttons: [
        DialogButton(
          child: const Text("Oui", style: TextStyle(color: Colors.white, fontSize: 20)),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop(); // Ferme le dialogue
            onConfirm();
          },
          width: 120,
        ),
        DialogButton(
          child: const Text("Non", style: TextStyle(color: Colors.white, fontSize: 20)),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop(); // Ferme le dialogue
            onCancel();
          },
          width: 120,
        ),
      ],
    ).show();
  }

  Future<void> _acceptReservation(dynamic elem) async {
    email = await SessionManager().get("email");
    nom = await SessionManager().get("nom");
    telephone = await SessionManager().get("telephone");

    var urlString = 'http://149.202.45.36:8008/miseAJourReservation?Email=${email}&Nom=${nom}&Prenom=${prenom}&Telephone=${telephone}&Identifiant=${elem[0]}';
    var url = Uri.parse(urlString);
    var response = await http.put(url);

    if (response.statusCode == 200) {
      debugPrint("Réservation acceptée");
      /*
      var urlString2 =
          'http://149.202.45.36:8008/infoChauffeur?Identifiant=${elem[0]}';
      var url2 = Uri.parse(urlString2);
      var repse = await http.get(url2);
      if (repse.statusCode == 200) {
        var wordShow = convert.jsonDecode(repse.body);
        if (wordShow.toString() != "[]") {
          for (var elem2 in wordShow) {
            telChauffeur.add(elem2[2]);
          }
        }
      }
        _sendSMS(
            "Votre reservation a été acceptée. Vous pouvez contacter votre chauffeur au: " +
                elem[16],
            telChauffeur);
       */
    } else {
      debugPrint("Erreur lors de l'acceptation de la réservation");
    }
  }

  Future<void> _cancelReservation(dynamic elem) async {
    var urlString = 'http://149.202.45.36:8008/suppressionReservation?Identifiant=${elem[0]}';
    var url = Uri.parse(urlString);
    var response = await http.delete(url);

    if (response.statusCode == 200) {
      debugPrint("Réservation supprimée");
      /*
      var urlString2 =
          'http://149.202.45.36:8008/infoChauffeur?Identifiant=${elem[0]}';
      var url2 = Uri.parse(urlString2);
      var repnse = await http.get(url2);
      if (repnse.statusCode == 200) {
        var wordShow = convert.jsonDecode(repnse.body);
        if (wordShow.toString() != "[]") {
          for (var elem2 in wordShow) {
            telChauffeur.add(elem2[2]);
          }
        }
      }
      _sendSMS(
          "Votre reservation n'a pas pu être acceptée. Veuillez contactez un autre chauffeur.",
          telChauffeur);
       */
    }  else {
      debugPrint("Erreur lors de l'annulation de la réservation");
    }
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    notificationAlerte();
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
