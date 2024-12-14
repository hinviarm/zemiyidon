import 'package:crypt/crypt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';
import 'dart:convert' as convert;

import '../Models/utile.dart';
import 'onglet.dart';

class Profil extends StatefulWidget {
  Profil({super.key});

  @override
  State<Profil> createState() => _MonProfil();
}

class _MonProfil extends State<Profil> {
  Duration get loginTime => Duration(milliseconds: 2250);
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

  @override
  void initState() {
    recSession();
    if (id != '' && mDP != '') {
      sessionConnect(id!, mDP!);
    }
    super.initState();
  }

  void recSession() async {
    id = await SessionManager().get("email");
    mDP = await SessionManager().get("password");
    nOmS = await SessionManager().get("nom");
    prenOmS = await SessionManager().get("prenom");
    teLephoneS = await SessionManager().get("telephone");
  }

  @override
  void dispose(){
    super.dispose();
  }

  void insertion(String mail, String password, String nom, String prenom, String telephone ) async {
    var urlStringPost = 'http://149.202.45.36:8008/insertion';
    var urlPost = Uri.parse(urlStringPost);
    try {
      var response = await http.post(
        urlPost,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: convert.jsonEncode(<String, String>{
          'Email': mail,
          'MDP': password,
          'Nom': nom,
          'Prenom': prenom,
          'Telephone': telephone,
        }),
      );
      if (!mounted) {
        debugPrint('Insertion réussie : ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) {
        debugPrint('Erreur d\'insertion : $e');
      }
    }
  }


  void sessionConnect(String mail, String password) async {
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
          elem = elem.toString().replaceAll("[", "").replaceAll("]", "").split(", ");
          id = elem[4];
          nOmS = elem[1];
          prenOmS = elem[2];
          teLephoneS = elem[3];
          mDP = elem[5];
            debugPrint('$elem');
        }
        final h = Crypt(mDP!);
        if (h.match(password)) {
          sess = true;
        }
      });
      if (sess) {
        var sessionManager = SessionManager();
        await sessionManager.set("email", id);
        await sessionManager.set("password", mDP);
        await sessionManager.set("nom", nOmS);
        await sessionManager.set("prenom", prenOmS);
        await sessionManager.set("telephone", teLephoneS);
        //await sessionManager.set("user", User(mail: mail, password: password));
      }
    }
    debugPrint('connect = $connect');
    debugPrint('sess = $sess');
  }

  void session(String mail, String password) async {
    await SessionManager().destroy();
    var sessionManager = SessionManager();
    await sessionManager.set("email", mail);
    await sessionManager.set("password", password);
    //await sessionManager.set("user", User(nom: mail, password: password));
    var urlString = 'http://149.202.45.36:8008/identification?Email=${mail}';
    var url = Uri.parse(urlString);
    var reponse = await http.get(url);
    if (reponse.statusCode == 200) {
      setState(() {
        connect = true;
        var wordShow = convert.jsonDecode(reponse.body);
        final h = Crypt(wordShow);
        if (h.match(password)) {
          sess = true;
        }
      });
    }
  }

  Future<String?> _authUser(LoginData data) {
    final c1 = Crypt.sha256(data.password);
    debugPrint('Name: ${data.name}, Password: ${c1.toString()}');
    return Future.delayed(loginTime).then((_) {
      sessionConnect(data.name, data.password);
      if (!connect) {
        return 'Identifiants ou Mot de passe incorrect';
      } 
      return null;
    });
  }


  Future<String?> _signupUser(SignupData data) {
    debugPrint('Signup Name: ${data.name}, Password: ${data.password}');
    final c1 = Crypt.sha256(data.password!);
    data.additionalSignupData?.forEach((key, value) {
      debugPrint('$key: $value');
    });
    Nom = data.additionalSignupData!["Nom"]!;
    Prenom = data.additionalSignupData!["Prenom"]!;
    Telephone = data.additionalSignupData!["Telephone"]!;
    insertion(data.name!, data.password!, Nom, Prenom, Telephone);
    return Future.delayed(loginTime).then((_) {
      if (!mounted) return null;
      return null;
    });
  }

  void emailing(String mail) async {
    var urlString = 'http://149.202.45.36:8001/miseAJour?Email=${mail}';
    var url = Uri.parse(urlString);
    var reponse = await http.get(url);
    if (reponse.statusCode == 200) {
      connect = true;
      var wordShow = convert.jsonDecode(reponse.body);
      if (wordShow.toString().contains('true')) {
        final Email email = Email(
          body: "L'utilisateur $mail a oublié son mot de passe ",
          subject: 'Mot de passe oublié',
          recipients: ['armand.hinvi@gmail.com'],
          isHTML: false,
        );
        await FlutterEmailSender.send(email);
        mailOK = true;
      }
    }
  }

  Future<String> _recoverPassword(String mail) {
    debugPrint('Name: $mail');
    emailing(mail);
    return Future.delayed(loginTime).then((_) {
      if (!mailOK) {
        return 'User not exists';
      }
      //emailing(mail);
      return 'Bonjour';
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
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
    if (!mounted && !connect) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => Onglet(),
      ));
    }
            },
            onRecoverPassword: _recoverPassword,
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

  User({this.nomconnection, this.nom, this.prenom, this.password, this.email, this.telephone});

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
