import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:form_widgets/checkbox_form_widget.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:scrollable_text_indicator/scrollable_text_indicator.dart';
import 'package:zemiyidon/Vues/profil.dart';

class Privacy extends StatefulWidget {
  Privacy({Key? key}) : super(key: key);

  @override
  _MyPrivacyState createState() => _MyPrivacyState();
}

class _MyPrivacyState extends State<Privacy> {
  bool varaccord = false;

  void sessManager() async {
    await SessionManager().set("accord", varaccord);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Zémiyidon"),
      ),
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
          new Flex(
            direction: Axis.vertical,
            children: <Widget>[
              Expanded(
                flex: 7,
                child: Container(
    margin: const EdgeInsets.symmetric(
    horizontal: 20, vertical: 10),
                child: const ScrollableTextIndicator(
                  text: Text(
                    """Politique de confidentialité\n 1.Collecte de l’information\n
    Nous recueillons des informations sur votre identité et vos contacts sur Zémiyidon dans le but de pouvoir établir un lien entre vous et vos passager ou votre chauffeur. Celà est indispensable au bon fonctionnement de l'application. Ces données seront supprimées sur votre demande.\n

    2.Utilisation des informations\n
    Toutes les informations que nous recueillons auprès de vous peuvent être utilisées pour :\n

    Vous permettre de trouver un chauffeur ou des passagers dont l'itinéraire se chevauche\n
    
    3.Confidentialité du commerce en ligne\n
    Nous sommes les seuls propriétaires des informations recueillies sur ce site. Vos informations personnelles ne seront pas vendues, échangées, transférées, ou données à une autre société pour n’importe quelle raison, sans votre consentement.\n

    4.Divulgation à des tiers\n
    Nous ne vendons, n’échangeons et ne transférons pas vos informations personnelles identifiables à des tiers. Cela ne comprend pas les tierce parties de confiance qui nous aident à exploiter notre application ou à mener nos affaires, tant que ces parties conviennent de garder ces informations confidentielles.
    Nous pensons qu’il est nécessaire de partager des informations afin d’enquêter, de prévenir ou de prendre des mesures concernant des activités illégales, fraudes présumées, situations impliquant des menaces potentielles à la sécurité physique de toute personne, violations de nos conditions d’utilisation, ou quand la loi nous y contraint.
    Les informations non-privées, cependant, peuvent être fournies à d’autres parties pour le marketing, la publicité, ou d’autres utilisations.\n
    
    5.Protection des informations\n
    Nous mettons en œuvre une variété de mesures de sécurité pour préserver la sécurité de vos informations personnelles. Votre mot de passe est crypté avant d'être envoyé à notre serveur pour être stocké. Vos informations, hormis votre mot de passe qui ne peut être décrypté que par votre appareil lors de la comparaison avec votre mot de passe non crypté inséré, ne sont accessibles que par l’administrateur de l’application Zémiyidon\n
    Est-ce que nous utilisons des cookies ?\n
    Nous enregistrons toutes vos données (Nom, Prénom, Email, Mot de passe, Téléphone) en session de même qu'une variable nous indiquant si c'est votre première connection\n
    6.Suppression des informations\n
    Vous pouvez demander la suppression de vos informations personnelles à tout moment en envoyant
    Un mail à HINVI Armand Armel : armand.hinvi@gmail.com tout en précisant l’objet de votre demande\n

    7.Consentement\n
    En utilisant notre application Zémiyidon, vous consentez à notre politique de confidentialité. """,
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                ),
              ),
              Expanded(
                flex: 1,
                child:CheckboxFormField(
                  initialValue: false,
                  onChanged: (value) {varaccord = value ?? false;
                  sessManager();
                  },
                  title: const Text("J'ai lu et j'accepte", style:  TextStyle(color: Colors.white, fontSize: 20),),
                  validator: (value) {
                    if (value == null || value == false) {
                      return "Vous devez accepter les conditions générales pour utiliser Zémiyidon";
                    }
                    return null;
                  },
                ),

              ),
              new Flex(direction: Axis.horizontal, children: <Widget>[
                Expanded(
                  flex: 2,
                  child: MaterialButton(
                    color: Theme.of(context).colorScheme.secondary,
                    onPressed: () async {
                      if(varaccord) {
                        Future.delayed(Duration(seconds: 1)).then((value) =>
                        Navigator.of(context)
                          ..pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => Profil()),
                                  (route) => false));
                      }
                      else{
                        Alert(
                          context: context,
                          type: AlertType.error,
                          title: "Erreur",
                          desc:
                          "Vous ne pouvez utiliser cette application sans lire et cocher la case: j'ai lu et j'accepte",
                          buttons: [
                        DialogButton(
                        child: Text(
                        "Fermer",
                          style:
                          TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      onPressed: () async {
                          Navigator.pop(context);
                      }),
                      ]).show();





                      }
                    },
                    child: Text(
                      "Accepter",
                      style: TextStyle(
                        color: Color(0xffffffff),
                      ),
                    ),
                  ),
                ),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}
