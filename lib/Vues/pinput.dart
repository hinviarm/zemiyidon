import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:pinput/pinput.dart';
import 'package:zemiyidon/Vues/accueil.dart';
import 'package:zemiyidon/Vues/onglet.dart';
import 'package:zemiyidon/Vues/profil.dart';
import 'package:zemiyidon/Vues/transition.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class PinputCode extends StatefulWidget {
  final String code;
  final String email;
  final String nom;
  final String prenom;
  final String telephone;
  final String password;
  const PinputCode({required this.code, required this.email, required this.nom, required this.prenom, required this.telephone, required this.password, Key? key}) : super(key: key);

  @override
  State<PinputCode> createState() => _PinputCodeState();
}

class _PinputCodeState extends State<PinputCode> {
  late final SmsRetriever smsRetriever;
  late final TextEditingController pinController;
  late final FocusNode focusNode;
  late final GlobalKey<FormState> formKey;
  int n = 4;
  var sessionManager = SessionManager();

  Future<void> insertionSess() async {
    await sessionManager.set("email", widget.email);
    await sessionManager.set("password", widget.password);
    await sessionManager.set("nom", widget.nom);
    await sessionManager.set("prenom", widget.prenom);
    await sessionManager.set("telephone", widget.telephone);
  }

  @override
  void initState() {
    super.initState();
    formKey = GlobalKey<FormState>();
    pinController = TextEditingController();
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  Future<void> insertion(String mail, String password, String nom,
      String prenom, String telephone) async {
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
      debugPrint('Insertion réussie : ${response.statusCode}');
    } catch (e) {
      if (!mounted) {
        debugPrint('Erreur d\'insertion : $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const focusedBorderColor = Color.fromRGBO(23, 171, 144, 1);
    const fillColor = Color.fromRGBO(243, 246, 249, 0);
    const borderColor = Color.fromRGBO(23, 171, 144, 0.4);

    final defaultPinTheme = PinTheme(
      width: 84,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Color.fromRGBO(30, 60, 87, 1),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
    );

    /// Optionally you can use form to validate the Pinput
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
          new Container(
            color: Colors.white.withOpacity(0.7),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Directionality(
                    // Specify direction if desired
                    textDirection: TextDirection.ltr,
                    child: Pinput(
                      length: 4,
                      keyboardType: TextInputType.number,
                      controller: pinController,
                      defaultPinTheme: defaultPinTheme,
                      //focusedPinTheme: focusedPinTheme,
                      //submittedPinTheme: submittedPinTheme,
                      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                      textInputAction: TextInputAction.next,
                      showCursor: true,
                      separatorBuilder: (index) => const SizedBox(width: 8),
                      validator: (value) {
                        if (n > 1 && value != widget.code) {
                          n = n - 1;
                          Flushbar(
                          title: "Mauvais code",
                          message: "Mauvais code. Il vous reste " +
                              n.toString()+" essai(s)",
                          duration: const Duration(seconds: 5),
                          )
                            ..show(context);
                          return value == widget.code
                              ? null
                              : 'Mauvais code \nIl vous reste ' +
                                  n.toString() +
                                  ' essai(s)';
                        } else if (value != widget.code){
                          SessionManager().destroy();
                          Navigator.of(context).pushReplacement(
                            FadePageRoute(
                              builder: (context) => Profil(),
                            ),
                          );
                        }
                      },
                      hapticFeedbackType: HapticFeedbackType.lightImpact,
                      onCompleted: (pin) async{
                        if (pin == widget.code) {
                          insertionSess();
                          await insertion(widget.email, widget.password, widget.nom, widget.prenom, widget.telephone);
                          Navigator.of(context).pushReplacement(
                            FadePageRoute(
                              builder: (context) => Onglet(),
                            ),
                          );
                        }
                      },
                      onChanged: (value) {
                        debugPrint('onChanged: $value');
                      },
                      cursor: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 9),
                            width: 22,
                            height: 1,
                            color: focusedBorderColor,
                          ),
                        ],
                      ),
                      focusedPinTheme: defaultPinTheme.copyWith(
                        decoration: defaultPinTheme.decoration!.copyWith(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: focusedBorderColor),
                        ),
                      ),
                      submittedPinTheme: defaultPinTheme.copyWith(
                        decoration: defaultPinTheme.decoration!.copyWith(
                          color: fillColor,
                          borderRadius: BorderRadius.circular(19),
                          border: Border.all(color: focusedBorderColor),
                        ),
                      ),
                      errorPinTheme: defaultPinTheme.copyBorderWith(
                        border: Border.all(color: Colors.redAccent),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      focusNode.unfocus();
                      formKey.currentState!.validate();
                    },
                    child: const Text('Validate'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
