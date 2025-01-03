import 'dart:math';

import 'package:crypt/crypt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:zemiyidon/Vues/transition.dart';
import 'dart:convert' as convert;

import '../Models/utile.dart';
import 'onglet.dart';
import 'pinput.dart';

class Profil extends StatefulWidget {
  static const routeName = '/profil';

  Profil({super.key});

  @override
  State<Profil> createState() => _MonProfil();
}

class _MonProfil extends State<Profil> {
  Duration get loginTime => Duration(milliseconds: 250);
  var sessionManager = SessionManager();
  bool connect = false;
  String? id = '';
  String? mDP = '';
  String Nom = "";
  String Prenom = "";
  String Telephone = "";
  String? nOmS = "";
  String? prenOmS = "";
  String? teLephoneS = "";
  bool sess = false;
  bool mailOK = false;
  String randomCode = "";
  bool insert = false;
  //String message = "";
  //List<String> recipents = [];

  @override
  void initState() {
    recSession();
    super.initState();
  }

  void recSession() async {
    id = await SessionManager().get("email");
    mDP = await SessionManager().get("password");
    nOmS = await SessionManager().get("nom");
    prenOmS = await SessionManager().get("prenom");
    teLephoneS = await SessionManager().get("telephone");
    if (id != '' && mDP != '') {
      await sessionConnect(id!, mDP!);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> insertion(String mail, String password, String nom,
      String prenom, String telephone) async {
    await sessionManager.set("email", mail);
    await sessionManager.set("password", password);
    await sessionManager.set("nom", nom);
    await sessionManager.set("prenom", prenom);
    await sessionManager.set("telephone", telephone);
    insert = true;
  }

  Future<void> sessionConnect(String mail, String password) async {
    debugPrint('id ${mail}');
    debugPrint('MDP ${password}');
    var urlString = 'http://149.202.45.36:8008/identification?Email=${mail}';
    var url = Uri.parse(urlString);
    var reponse = await http.get(url);
    if (reponse.statusCode == 200) {
      setState(() {
        connect = true;
        var wordShow = convert.jsonDecode(reponse.body);
        for (var elem in wordShow) {
          elem = elem
              .toString()
              .replaceAll("[", "")
              .replaceAll("]", "")
              .split(", ");
          id = elem[3];
          nOmS = elem[0];
          prenOmS = elem[1];
          teLephoneS = elem[2];
          mDP = elem[4];
          debugPrint('$elem');
        }
        final h = Crypt(mDP!);
        if (h.match(password)) {
          sess = true;
        }
      });
      if (sess == true || insert == true) {
        await sessionManager.set("email", id);
        await sessionManager.set("password", mDP);
        await sessionManager.set("nom", nOmS);
        await sessionManager.set("prenom", prenOmS);
        await sessionManager.set("telephone", teLephoneS);
      }
    }
    debugPrint('connect = $connect');
    debugPrint('sess = $sess');
  }

  Future<String?> _authUser(LoginData data) {
    final c1 = Crypt.sha256(data.password);
    debugPrint('Name: ${data.name}, Password: ${c1.toString()}');
    return Future.delayed(loginTime).then((_) async {
      await sessionConnect(data.name, data.password);
      if (!connect || !sess) {
        return 'Identifiants ou Mot de passe incorrect';
      }
      return null;
    });
  }

  Future<String?> _signupUser(SignupData data) async {
    // Générer et chiffrer le code
    randomCode = generateRandomCode(4); // 6 caractères alphanumériques
    bool envoye = await emailing(data.name!, randomCode, 2);
    if (!envoye) {
      return null;
    }
    debugPrint('Signup Name: ${data.name}, Password: ${data.password}');
    final c1 = Crypt.sha256(data.password!);
    data.additionalSignupData?.forEach((key, value) {
      debugPrint('$key: $value');
    });
    Nom = data.additionalSignupData!["Nom"]!;
    Prenom = data.additionalSignupData!["Prenom"]!;
    Telephone = data.additionalSignupData!["Telephone"]!;
    await insertion(data.name!, c1.toString(), Nom, Prenom, Telephone);
    return Future.delayed(loginTime).then((_) {
      if (!mounted) return null;
      return null;
    });
  }

  String generateRandomCode(int length) {
    final random = Random();
    const characters = '0123456789';
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => characters.codeUnitAt(random.nextInt(characters.length)),
      ),
    );
  }

/*
  void envoiMessage (String tel, String code, int appelant)async{
    recipents.add(tel);
    if(appelant == 1){
      message = "Bonjour,\n\nCliquez sur le lien suivant pour réinitialiser votre mot de passe :\n$code\n\nCordialement,\nL'équipe Zemiyidon";
    }
    else if (appelant == 2){
      message = "Bonjour,\n\nCliquez sur le lien suivant pour valider votre mot de passe :\n$code\n\nCordialement,\nL'équipe Zemiyidon";
    }
    String _result = await sendSMS(message: message, recipients: recipents, sendDirect: true)
        .catchError((onError) {
      print(onError);
    });
    print(_result);
  }
 */

  Future<bool> emailing(String mail, String code, int appelant) async {
    var urlString =
        'http://149.202.45.36:8008/envoiMail?Email=${mail}&Code=${code}';
    var url = Uri.parse(urlString);
    var reponse = await http.get(url);
    if (reponse.statusCode == 200) {
      var wordShow = convert.jsonDecode(reponse.body);
      debugPrint("wordShow : " + wordShow.toString());
      if (wordShow.toString() == "true" || wordShow.toString() == "True") {
        return true;
      }
    }
    return false;
  }

  Future<String?> _recoverPassword(String mail) async {
    debugPrint('Name: $mail');
    insert = true;
    sessionConnect(mail, "");
    randomCode = generateRandomCode(4);
    bool envoye = await emailing(mail, randomCode, 1);
    if (!envoye) {
      return "Votre adresse mail n'est pas valide" as Future<String>;
    }
    else {
      Navigator.of(context).pushReplacement(
        FadePageRoute(
          //builder: (context) => const Onglet(),
          builder: (context) => PinputCode(code: randomCode),
        ),
      );
    }
    return Future.delayed(loginTime).then((_) {
      if (!mounted) return null;
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: Scaffold(
        extendBodyBehindAppBar: true,
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/fond.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: FlutterLogin(
            logo: 'images/homeli.png',
            onLogin: _authUser,
            onSignup: _signupUser,
            additionalSignupFields: [
              const UserFormField(keyName: 'Nom'),
              const UserFormField(keyName: 'Prenom', displayName: 'Prénom'),
              UserFormField(
                keyName: 'Telephone',
                displayName: 'Téléphone',
                icon: Icon(Icons.phone),
                userType: LoginUserType.phone,
                fieldValidator: (value) {
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
            ],
            theme: LoginTheme(
              pageColorLight: Colors.transparent,
              pageColorDark: Colors.transparent,
            ),
            onSubmitAnimationCompleted: () {
              if (insert) {
                Navigator.of(context).pushReplacement(
                  FadePageRoute(
                    //builder: (context) => const Onglet(),
                    builder: (context) => PinputCode(code: randomCode),
                  ),
                );
              }
              if (sess) {
                Navigator.of(context).pushReplacement(
                  FadePageRoute(
                    builder: (context) => const Onglet(),
                  ),
                );
              }
            },
            onRecoverPassword: _recoverPassword,
          ),
        ),
      ),
    );
  }
}

class User {
  final String? nomconnection;
  final String? nom;
  final String? prenom;
  final String? password;
  final String? email;
  final String? telephone;

  User(
      {this.nomconnection,
      this.nom,
      this.prenom,
      this.password,
      this.email,
      this.telephone});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> user = Map<String, dynamic>();
    user["nomconnection"] = nomconnection;
    user["nom"] = nom;
    user["prenom"] = prenom;
    user["password"] = password;
    user["email"] = email;
    user["telephone"] = telephone;
    return user;
  }
}
