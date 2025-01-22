import 'package:another_flushbar/flushbar.dart';
import 'package:crypt/crypt.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:selectable_autolink_text/selectable_autolink_text.dart';
import 'package:zemiyidon/Vues/profil.dart';
import 'package:zemiyidon/Vues/transition.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class Person extends StatefulWidget {
  Person({super.key});

  @override
  State<Person> createState() => _Person();
}

class _Person extends State<Person> {
  _onChangeTextNom(value) {
    infoChange.add(1);
    debugPrint("_onChangeTextNom: $value");
  }

  _onChangeTextPrenom(value) {
    infoChange.add(2);
    debugPrint("_onChangeTextPrenom: $value");
  }

  _onChangeTextMotDePasse(value) {
    infoChange.add(4);
    debugPrint("_onChangeTextMotDePasse: $value");
  }

  _onChangeTextTelephone(value) {
    infoChange.add(3);
    debugPrint("_onChangeTextTelephone: $value");
  }

  final Nom = TextEditingController();
  final Prenom = TextEditingController();
  final MotDePasse = TextEditingController();
  final Telephone = TextEditingController();
  List<int> infoChange = [];
  String id = "";
  String mDP = "";
  bool obscureText = true;
  List<String> _MyListOID = [];
  List<int> IdTrajet = [];
  String info = "";
  bool rep = false;
  bool dem = false;
  List<bool> estChauffeur = [];

  @override
  void initState() {
    recSession();
    super.initState();
  }

  void recupTrajets(String mail) async {
    var urlString = 'http://149.202.45.36:8008/consultation?Email=${mail}';
    var url = Uri.parse(urlString);
    var reponse = await http.get(url);
    if (reponse.statusCode == 200) {
      var wordShow = convert.jsonDecode(reponse.body);
      setState(() {
        for (var elem in wordShow) {
          IdTrajet.add(elem[6]);
          if (elem[0] == 1) {
            //EstChauffeur, DateArrive, QuartierDepart, QuartierArrivee, DateDepart, NombrePlaces
            _MyListOID.add(" Vous êtes chauffeur sur le trajet: " +
                elem[2] +
                " à " +
                elem[3] +
                " démarrant le: " +
                elem[4].replaceAll('T', " à "));
            estChauffeur.add(true);
          } else {
            _MyListOID.add(" Vous êtes passager sur le trajet: " +
                elem[2] +
                " à " +
                elem[3] +
                " démarrant le: " +
                elem[4].replaceAll('T', " à "));
            estChauffeur.add(false);
          }
          debugPrint(elem[2] + " à " + elem[3]);
        }
      });
    }
  }

  void recSession() async {
    id = await SessionManager().get("email");
    mDP = await SessionManager().get("password");
    Nom.text = await SessionManager().get("nom");
    Prenom.text = await SessionManager().get("prenom");
    Telephone.text = await SessionManager().get("telephone");
    recupTrajets(id);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    Nom.dispose();
    Prenom.dispose();
    MotDePasse.dispose();
    Telephone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
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
        padding: EdgeInsets.only(top: 60),
        color: Colors.white.withOpacity(0.7),
        child: Flex(
          direction: Axis.vertical,
          children: <Widget>[
            Expanded(
              flex: 5,
              child: Container(
                margin: const EdgeInsets.only(left: 20, right: 20),
                child: TextFormField(
                  onChanged: _onChangeTextNom,
                  controller: Nom,
                  decoration: InputDecoration(
                    labelText: 'Entrez Votre Nom ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'S\'il vous plaît entrez votre nom';
                    }
                    return null;
                  },
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                margin: const EdgeInsets.only(left: 20, right: 20),
                child: TextFormField(
                  onChanged: _onChangeTextPrenom,
                  controller: Prenom,
                  decoration: InputDecoration(
                    labelText: 'Entrez votre prénom',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'S\'il vous plaît entrez votre prénom';
                    }
                    return null;
                  },
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                margin: const EdgeInsets.only(left: 20, right: 20),
                child: TextFormField(
                  onChanged: _onChangeTextMotDePasse,
                  controller: MotDePasse,
                  obscureText: obscureText,
                  decoration: InputDecoration(
                    labelText: "Votre Mot de Passe",
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureText ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureText = !obscureText;
                        });
                      },
                    ),
                    hintText: "***",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'S\'il vous plaît entrez un nom correcte';
                    }
                    return null;
                  },
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                margin: const EdgeInsets.only(left: 20, right: 20),
                child: TextFormField(
                  keyboardType: TextInputType.phone,
                  autocorrect: false,
                  onChanged: _onChangeTextTelephone,
                  controller: Telephone,
                  decoration: InputDecoration(
                    labelText: "Votre numéro de téléphone",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    final phoneRegExp = RegExp(
                      '^(\\+\\d{1,2}\\s)?\\(?\\d{3}\\)?[\\s.-]?\\d{3}[\\s.-]?\\d{4}\$',
                    );
                    if (value != null &&
                        value.length < 7 &&
                        !phoneRegExp.hasMatch(value)) {
                      return "This isn't a valid phone number";
                    }
                    return null;
                  },
                ),
              ),
            ),
            Expanded(
              flex: _MyListOID.isEmpty ? 0 : 16,
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return InkWell(
                    child: Container(
                      margin: const EdgeInsets.only(left: 20, right: 20),
                      color: (index % 2 == 0)
                          ? Colors.white.withOpacity(0.7)
                          : Colors.cyanAccent.withOpacity(0.7),
                      child: Text(_MyListOID[index]),
                    ),
                    onTap: () async {
                      if (estChauffeur[index]) {
                        await Alert(
                          context: context,
                          type: AlertType.warning,
                          title: "Bloquer ce trajet",
                          desc: "Voulez vous empêcher d'autres reservation sur ce trajet ?" +
                              _MyListOID[index] + " ?",
                          buttons: [
                            DialogButton(
                              child: Text(
                                "Oui",
                                style:
                                TextStyle(color: Colors.white, fontSize: 20),
                              ),
                              onPressed: () async {
                                var urlString =
                                    'http://149.202.45.36:8008/miseAJourTrajet?Identifiant=${IdTrajet[index]}';
                                var url = Uri.parse(urlString);
                                var reponse = await http.put(url);
                                if (reponse.statusCode != 200) {
                                  dem = true;
                                  rep = false;
                                } else {
                                  rep = true;
                                  dem = true;
                                }
                                Navigator.pop(context);
                              },
                              width: 120,
                            ),
                            DialogButton(
                              child: Text(
                                "Non",
                                style:
                                TextStyle(color: Colors.white, fontSize: 20),
                              ),
                              onPressed: () => Navigator.pop(context),
                              width: 120,
                            )
                          ],
                        ).show();
                      }else{
                        Flushbar(
                          title: "Blocage en échec",
                          message: "Vous n'êtes pas chauffeur sur ce trajet :" +
                              _MyListOID[index],
                          duration: const Duration(seconds: 5),
                        )
                          ..show(context);
                      }
                      if(dem == true) {
                        if (!rep) {
                          await Flushbar(
                            title: "Blocage en échec",
                            message: "Nous n'avons pas pu bloquer votre trajet :" +
                                _MyListOID[index] + " contactez andel.arm06@gmail.com",
                            duration: const Duration(seconds: 5),
                          )
                            ..show(context);
                          dem = false;
                        } else {
                          await Flushbar(
                            title: "Blocage réussi",
                            message: "Blocage réussi de votre trajet :" +
                                _MyListOID[index],
                            duration: const Duration(seconds: 5),
                          )
                            ..show(context);
                          dem = false;
                          rep = false;
                        }
                      }
                    },
                  );
                },
                itemCount: _MyListOID.length,
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                child: new Flex(
                  direction: Axis.horizontal,
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          fixedSize: const Size(100, 50),
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
                    ),
                    Expanded(
                      flex: 3,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          fixedSize: const Size(100, 50),
                          backgroundColor: Color(0xffF18265),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () async {
                          if (infoChange == []) {
                            return;
                          } else {
                            var distinctinfoChange =
                                infoChange.toSet().toList();
                            var dchang = "";
                            var dtype = "";
                            var dsesstype = "";
                            bool rep = false;
                            for (var elem in distinctinfoChange) {
                              switch (elem) {
                                case 1:
                                  dchang = Nom.text;
                                  dtype = "Nom";
                                  dsesstype = "nom";
                                  break;
                                case 2:
                                  dchang = Prenom.text;
                                  dtype = "Prenom";
                                  dsesstype = "prenom";
                                  break;
                                case 3:
                                  dchang = Telephone.text;
                                  dtype = "Telephone";
                                  dsesstype = "telephone";
                                  break;
                                case 4:
                                  dchang =
                                      Crypt.sha256(MotDePasse.text).toString();
                                  dtype = "Mot de Passe";
                                  dsesstype = "password";
                                  break;
                              }
                              await Alert(
                                context: context,
                                type: AlertType.warning,
                                title: "Enregistrement de " + dtype,
                                desc:
                                    "Voulez vous enregistrer la modification de votre " +
                                        dtype,
                                buttons: [
                                  DialogButton(
                                    child: Text(
                                      "Oui",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                    onPressed: () async {
                                      var urlString =
                                          'http://149.202.45.36:8008/miseAJour?champ=${dchang}&Email=${id}&selecteur=${elem}';
                                      var url = Uri.parse(urlString);
                                      var reponse = await http.put(url);
                                      if (reponse.statusCode != 200) {
                                        rep = false;
                                      } else {
                                        rep = true;
                                      }
                                      Navigator.pop(context);
                                    },
                                    width: 120,
                                  ),
                                  DialogButton(
                                    child: Text(
                                      "Non",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                    width: 120,
                                  )
                                ],
                              ).show();
                              if (rep == false) {
                                Alert(
                                  context: context,
                                  type: AlertType.error,
                                  title: "Désolé !",
                                  desc: "L'enregistrement de votre " +
                                      dtype +
                                      " n'a pu être effectuée",
                                  buttons: [
                                    DialogButton(
                                      child: Text(
                                        "Fermer",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      ),
                                      onPressed: () => Navigator.pop(context),
                                      width: 120,
                                    )
                                  ],
                                ).show();
                              } else {
                                await SessionManager().set(dsesstype, dchang);
                                Alert(
                                  context: context,
                                  type: AlertType.success,
                                  title: "Merci !",
                                  desc:
                                      "L'enregistrement a été effectuée avec succès",
                                  buttons: [
                                    DialogButton(
                                      child: Text(
                                        "Fermer",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      ),
                                      onPressed: () => Navigator.pop(context),
                                      width: 120,
                                    )
                                  ],
                                ).show();
                              }
                            }
                          }
                          recSession();
                        },
                        child: Text(
                          "Enregistrer",
                          style: TextStyle(
                            color: Color(0xffffffff),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      )
    ]));
  }
}
