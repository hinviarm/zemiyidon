import 'dart:async';
import 'dart:math';

import 'package:another_flushbar/flushbar.dart';
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
  Duration get loginTime => const Duration(milliseconds: 20);
  Duration get timeoutDuration => const Duration(seconds: 5);
  var sessionManager = SessionManager();
  bool connect = false;
  String? id = '';
  String? mDP = '';
  String Email = "";
  String Password = "";
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
      if (sess == true) {
        await sessionManager.set("email", id);
        await sessionManager.set("password", mDP);
        await sessionManager.set("nom", nOmS);
        await sessionManager.set("prenom", prenOmS);
        await sessionManager.set("telephone", teLephoneS);
      }
      Nom = nOmS!;
      Prenom = prenOmS!;
      Email = id!;
      Telephone = teLephoneS!;
      Password = mDP!;
    }
    else {
      return;
    }
    debugPrint('connect = $connect');
    debugPrint('sess = $sess');
  }

  Future<String?> _authUser(LoginData data) async {
    final c1 = Crypt.sha256(data.password);
    debugPrint('Name: ${data.name}, Password: ${c1.toString()}');
    try {
      await Future.any([
        Future.delayed(timeoutDuration, () => throw TimeoutException("Temps d'attente dépassé")),
        sessionConnect(data.name, data.password),
      ]);

      // Vérifiez les états après l'opération
      if (!connect || !sess) {
        return 'Identifiants ou Mot de passe incorrect';
      }

      return null; // Connexion réussie
    } on TimeoutException {
      return 'Temps d’attente dépassé. Vérifiez votre connexion et réessayez.';
    } catch (e) {
      debugPrint('Erreur inattendue : $e');
      return 'Une erreur est survenue. Réessayez plus tard.';
    }
  }


  Future<String?> _signupUser(SignupData data) async {
    var urlString = 'http://149.202.45.36:8008/identification?Email=${data.name}';
    var url = Uri.parse(urlString);
    var reponse = await http.get(url);
    if (reponse.statusCode == 200) {
      connect = true;
      var wordShow = convert.jsonDecode(reponse.body);
      for (var elem in wordShow) {
        if(elem != []){
          return "Votre email existe déjà. Faites mot de passe oublié.";
        }
      }
    }
    Future<bool> envoye = Future.value(false);
    // Générer et chiffrer le code
    randomCode = generateRandomCode(4); // 6 caractères alphanumériques
    try {
      Future.any([
      Future.delayed(timeoutDuration, () => throw TimeoutException("Temps d'attente dépassé")),
        envoye = emailing(data.name!, randomCode, 2),
    ]);
    if (!mounted) return "Impossible de vous enregistrer";
    } on TimeoutException catch (_) {
    return 'Temps d’attente dépassé. Vérifiez votre connexion et réessayez.';
    }
    if (await envoye == false) {
      return "Votre Email n'est pas valide";
    }
    debugPrint('Signup Name: ${data.name}, Password: ${data.password}');
    final c1 = Crypt.sha256(data.password!);
    data.additionalSignupData?.forEach((key, value) {
      debugPrint('$key: $value');
    });
    Nom = data.additionalSignupData!["Nom"]!;
    Prenom = data.additionalSignupData!["Prenom"]!;
    Telephone = data.additionalSignupData!["Telephone"]!;
    Email = data.name!;
    Password = c1.toString();
    insert = true;


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

  Future<bool> emailing(String mail, String code, int appelant) async {
    var urlString =
        'http://149.202.45.36:8008/envoiMail?Email=${mail}&Code=${code}';
    var url = Uri.parse(urlString);
    var reponse = await http.get(url);
    if (reponse.statusCode == 200) {
      var wordShow = convert.jsonDecode(reponse.body);
      debugPrint("wordShow : " + wordShow.toString());
      if (wordShow.toString() == "true" || wordShow.toString() == "True") {
        await Alert(
          context: context,
          type: AlertType.info,
          title: "Code envoyé par mail !",
          desc: "Un code de validation de 4 chiffres vous a été envoyé par mail. Veuillez le consulter et le saisir dans la page suivante",
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
    try {
    bool envoye = await emailing(mail, randomCode, 1);
    if (!envoye) {
      return "Votre adresse mail n'est pas valide" as Future<String>;
    }
    else {
      Navigator.of(context).pushReplacement(
        FadePageRoute(
          //builder: (context) => const Onglet(),
          builder: (context) => PinputCode(code: randomCode, nom: Nom, prenom: Prenom, telephone: Telephone, email: Email, password: Password, insert: false,),
        ),
      );
    }

      await Future.delayed(loginTime).then((_) {
        if (!mounted) return null;
        return null;
      }).timeout(timeoutDuration);
    }on TimeoutException catch (_) {
      return 'Temps d’attente dépassé. Vérifiez votre connexion et réessayez.';
    }
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
              UserFormField(keyName: 'Nom',
    fieldValidator: (value) { if (value!.isEmpty){
    return "Veuillez entrer votre nom";
    }
    return null; }),
              UserFormField(keyName: 'Prenom', displayName: 'Prénom',
                  fieldValidator: (value) { if (value!.isEmpty){
                    return "Veuillez entrer votre prénom";
                  }
                  return null; }),
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
                    return "Ce numéro de téléphone n'est pas valide";
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
                    builder: (context) => PinputCode(code: randomCode, nom: Nom, prenom: Prenom, telephone: Telephone, email: Email, password: Password, insert: true,),
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
            messages: LoginMessages(
              userHint: 'Email',
              passwordHint: 'Mot de Passe',
              confirmPasswordHint: 'Confirmer',
              loginButton: 'Se Connecter',
              signupButton: "S'inscrire",
              forgotPasswordButton: 'Mot de passe oublié?',
              recoverPasswordButton: 'Aide à la connection',
              goBackButton: 'Retour',
              signUpSuccess: 'Un mail contenant le code de validation vous a été envoyé',
              confirmPasswordError: 'Mot de passe Incorrect!',
              recoverPasswordDescription:
              'Un email vous aidera à vous connecter. Vous pouvez ensuite modifier votre mot de passe',
              recoverPasswordSuccess: 'Email identifié avec succès',
              additionalSignUpSubmitButton: "Soumettre",
              additionalSignUpFormDescription: "Ajoutez vos informations d'identification",
            ),
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
