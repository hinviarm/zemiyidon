import 'package:another_flushbar/flushbar.dart';
import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:cache_storage/cache_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:switcher_button/switcher_button.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import '../Models/villes.dart';

class Accueil extends StatefulWidget {
  const Accueil({super.key});

  @override
  State<Accueil> createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  bool exec = false;
  bool estChauffeur = false;
  bool insert = false;

  final cacheStorage = CacheStorage.open();
  final Depart = TextEditingController();
  final Destination = TextEditingController();
  final NbrePersonnes = TextEditingController();
  var latitude = 0.0;
  var longitude = 0.0;
  List<String> arrets = [];
  List<Villes> villes = [];
  DateTime? selectedDay = null;
  TimeOfDay? _selectedTime = null;
  DateTime? dateVoyage = null;
  String dateAffiche = "Selectionnez la date";
  String dateAfficheAPI = "0000-00-00 00:00:00";
  String dateAfficheAPIPassager = "0000-00-00";
  List<Location> locationDest = [];
  List<Location> locationDep = [];
  List<int> identifiantTrajet = [];
  List<int> identifiantChauffeur = [];
  List<String> trajetTrouve = [];
  String info = "";
  String nom = "";
  String prenom = "";
  String telephone = "";
  List<String> telChauffeur = [];
  String mailChauffeur = "";
  int trajetID = 0;
  dynamic resultat = [];
  static const String title = 'title';

  late BuildContext dialogContext;

  void recSession() async {
    nom = await SessionManager().get("nom");
    prenom = await SessionManager().get("prenom");
    telephone = await SessionManager().get("telephone");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dialogContext = context; // Sauvegarde le contexte ici
  }

  Future<void> _Detection() async {
    if (!cacheStorage.has(key: 'villes')) {
      var urlString = 'http://149.202.45.36:8008/ville';
      var url = Uri.parse(urlString);
      var response = await http.get(url);
      if (response.statusCode == 200) {
        //var wordShow = (convert.jsonDecode(response.body)as List)?.map((item) => item as String)?.toList();

        villes = [];
        var wordShow = convert.jsonDecode(response.body);
        if (wordShow.toString() != "[]") {
          for (var elem in wordShow) {
            elem = elem
                .toString()
                .replaceAll("[", "")
                .replaceAll("]", "")
                .split(", ");
            villes.add(new Villes(int.parse(elem[0]), elem[1], elem[2]));
            arrets.add(elem[2]);
          }
          cacheStorage.save(
            key: 'villes',
            value: villes,
          );
        }
      }
    } else {
      if (villes.isEmpty) {
        villes = cacheStorage.match(key: 'villes') ?? [];
      }

      // Ajout des arrêts à partir des villes
      arrets = villes.map((elem) => elem.Arret).toList();
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    Depart.dispose();
    Destination.dispose();
    NbrePersonnes.dispose();
    //cacheStorage.delete();
    super.dispose();
  }

  // Fields in a Widget subclass are always marked "final".

  //final Widget title;
  _onChangeText(value) => debugPrint("_onChangeText: $value");

  String endwithSpace(tmp) {
    while (tmp.endsWith(' ')) {
      tmp = tmp.substring(0, tmp.length - 1);
    }
    return tmp;
  }

  Future<void> longitudeLatitude() async {
    try {
      if (arrets.contains(Depart.text)) {
        locationDep = await locationFromAddress(Depart.text);
      } else {
        throw new FormatException();
      }
    } catch (e) {
      Alert(
        context: context,
        type: AlertType.error,
        title: "Adresse non reconnu",
        desc:
            "L'adresse de départ n'est pas correcte. Saissisez un nom de ville Béninoise",
        buttons: [
          DialogButton(
            child: Text(
              "Fermer",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => Navigator.pop(context),
            width: 120,
          ),
        ],
      ).show();
      return;
    }

    try {
      if (arrets.contains(Destination.text)) {
        locationDest = await locationFromAddress(Destination.text);
      } else {
        throw new FormatException();
      }
    } catch (e) {
      Alert(
        context: context,
        type: AlertType.error,
        title: "Adresse non reconnu",
        desc:
            "L'adresse de destination n'est pas correcte. Saissisez un nom de ville Béninoise",
        buttons: [
          DialogButton(
            child: Text(
              "Fermer",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => Navigator.pop(context),
            width: 120,
          ),
        ],
      ).show();
      return;
    }
  }

  Future<void> rechercheTrajet() async {
    await longitudeLatitude();
    String? email = await SessionManager().get("email");
    var urlString =
        'http://149.202.45.36:8008/rechercheChauffeur?Email=${email}&DateDepart=${dateAfficheAPIPassager}&NombrePlaces=${int.parse(NbrePersonnes.text)}&'
        'QuartierDepart=${Depart.text}&DepartLogitude=${locationDep.first.longitude}&DepartLatitude=${locationDep.first.latitude}&QuartierDest=${Destination.text}&'
        'DestLogitude=${locationDest.first.longitude}&DestLatitude=${locationDest.first.latitude}';
    var url = Uri.parse(urlString);
    var response = await http.get(url);
    if (response.statusCode == 200) {
      trajetTrouve = [];
      debugPrint("Voici " + response.body.toString());
      resultat = convert.jsonDecode(response.body);
      if (resultat.toString() != "[]") {
        for (var elem in resultat) {
          debugPrint("happy : " + elem.toString());
          identifiantTrajet.add(elem[0]);
          identifiantChauffeur.add(elem[1]);
          setState(() {
            trajetTrouve.add("Trajet " +
                elem[7] +
                " à " +
                elem[8] +
                " Démarrant le " +
                elem[9].toString().replaceAll("T", " à ") +
                " " +
                elem[11].toString() +
                " Places restants");
          });
        }
      }
      else {
        Alert(
          context: context,
          type: AlertType.info,
          title: "Désolé !",
          desc:
          "Aucun trajet ne correspond à vos critères de recherche",
          buttons: [
            DialogButton(
              child: Text(
                "Fermer",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20),
              ),
              onPressed: () =>
                  Navigator.pop(context),
              width: 120,
            )
          ],
        ).show();
      }
    }
  }

  Future<void> chercheChauffeur(int index) async {
    var urlString =
        'http://149.202.45.36:8008/infoChauffeur?Identifiant=${identifiantChauffeur[index]}';
    var url = Uri.parse(urlString);
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var wordShow = convert.jsonDecode(response.body);
      if (wordShow.toString() != "[]") {
        for (var elem in wordShow) {
          setState(() {
            info = "Veuillez contacter " +
                elem[1] +
                " " +
                elem[0] +
                " au " +
                elem[2];
            telChauffeur = [];
            telChauffeur.add(elem[2]);
            mailChauffeur = elem[3];
          });
        }
      }
    }
  }

  Future<void> insertionChauffeur() async {
    await longitudeLatitude();
    String? email = await SessionManager().get("email");
    debugPrint("Voici votre email : ${email!}");
    var urlStringPost = 'http://149.202.45.36:8008/insertionchauffeur';
    var urlPost = Uri.parse(urlStringPost);
    var body = convert.jsonEncode({
      'Email': email!,
      'DateDepart': dateAfficheAPI,
      'NombrePlaces': int.parse(NbrePersonnes.text),
      'QuartierDepart': Depart.text,
      'DepartLogitude': locationDep.first.longitude,
      'DepartLatitude': locationDep.first.latitude,
      'QuartierDest': Destination.text,
      'DestLogitude': locationDest.first.longitude,
      'DestLatitude': locationDest.first.latitude,
    });

    try {
      var response = await http.post(
        urlPost,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      print('Statut de la réponse : ${response.statusCode}');
      print('Corps de la réponse : ${response.body}');
      if (response.statusCode == 200) {
        debugPrint('Insertion réussie : ${response.statusCode}');
        insert = true;
      }
    } catch (e) {
      print('Erreur : $e');
    }
  }

  Future<void> insertionPassager() async {
    await longitudeLatitude();
    recSession();
    String? email = await SessionManager().get("email");
    debugPrint("Voici votre email : ${email!}");
    String dateDep = "0000-00-00 00:00:00";
    for(var elem in resultat){
      if(elem[0] == trajetID){
        dateDep = elem[9].toString().replaceAll('T', ' ');
      }
    }
    var urlStringPost = 'http://149.202.45.36:8008/insertionpassager';
    var urlPost = Uri.parse(urlStringPost);
    var body = convert.jsonEncode({
      'Nom': nom,
      'Prenom': prenom,
      'Telephone': telephone,
      'Email': email,
      'EmailChauffeur': mailChauffeur,
      'DateDepart': dateDep,
      'NombrePlaces': int.parse(NbrePersonnes.text),
      'QuartierDepart': Depart.text,
      'DepartLogitude': locationDep.first.longitude,
      'DepartLatitude': locationDep.first.latitude,
      'QuartierDest': Destination.text,
      'DestLogitude': locationDest.first.longitude,
      'DestLatitude': locationDest.first.latitude,
      'IDVoyage': trajetID,
    });

    try {
      var response = await http.post(
        urlPost,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      print('Statut de la réponse : ${response.statusCode}');
      print('Corps de la réponse : ${response.body}');
      if (response.statusCode == 200) {
        debugPrint('Insertion réussie : ${response.statusCode}');
        insert = true;
      }
    } catch (e) {
      print('Erreur : $e');
    }
  }

  void _selectDayAndTime(BuildContext context) async {
    selectedDay = await showDatePicker(
      context: context,
      locale: const Locale("fr", "FR"),
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 360)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark(),
          child: child!,
        );
      },
    );

    _selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedDay != null && _selectedTime != null) {
      var datestr = selectedDay.toString().substring(0, 10);
      var timestr =
          '${_selectedTime?.hour.toString().padLeft(2, '0')}:${_selectedTime?.minute.toString().padLeft(2, '0')}';
      String newDate = (datestr + " " + timestr.substring(0, 5) + ":00.000");
      dateVoyage = DateTime.parse(newDate);
      setState(() {
        dateAffiche = DateFormat('yyyy-MM-dd – kk:mm').format(dateVoyage!);
        dateAfficheAPI = DateFormat('yyyy-MM-dd kk:mm:ss').format(dateVoyage!);
        dateAfficheAPIPassager = DateFormat('yyyy-MM-dd').format(dateVoyage!);
      });
    }
  }

  @override
  void initState() {
    _Detection();
    recSession();
    super.initState();
  }
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new Stack(
        children: <Widget>[
          new Container(
            decoration: new BoxDecoration(
              image: new DecorationImage(
                image: new AssetImage("images/voiture.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.white.withOpacity(0.7),
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                              child: Autocomplete<String>(
                                optionsBuilder: (TextEditingValue textEditingValue) {
                                  if (textEditingValue.text.isEmpty) {
                                    return const Iterable<String>.empty();
                                  }
                                  return arrets.where((String option) {
                                    return option.toLowerCase().startsWith(textEditingValue.text.toLowerCase());
                                  });
                                },
                                onSelected: (String selection) {
                                  Depart.text = selection; // Mise à jour du TextFormField
                                },
                                fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                                  return TextFormField(
                                    controller: textEditingController,
                                    focusNode: focusNode,
                                    onChanged: (value) async {
                                      await _Detection(); // Appelez la méthode async ici pour mettre à jour arrets
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Votre point de Départ',
                                      hintText: 'Votre point de Départ',
                                      prefixIcon: Icon(Icons.directions_car_filled),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Autocomplete<String>(
                              optionsBuilder: (TextEditingValue textEditingValue) {
                                // Vérifie si l'entrée est vide
                                if (textEditingValue.text.isEmpty) {
                                  return const Iterable<String>.empty();
                                }
                                // Filtre les résultats locaux
                                return arrets.where((String option) {
                                  return option.toLowerCase().startsWith(textEditingValue.text.toLowerCase());
                                });
                              },
                              onSelected: (String selection) {
                                Destination.text = selection; // Mise à jour du TextFormField
                              },
                              fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                                return TextFormField(
                                  controller: textEditingController,
                                  focusNode: focusNode,
                                  onChanged: (value) async {
                                    await _Detection(); // Appelez la méthode async ici pour mettre à jour arrets
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Votre destination',
                                    hintText: 'Votre destination',
                                    prefixIcon: Icon(Icons.flag),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              autocorrect: false,
                              onChanged: _onChangeText,
                              controller: NbrePersonnes,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.people),
                                labelText: estChauffeur
                                    ? "Nombre de places disponibles"
                                    : "Nombre de voyageurs",
                                hintText: estChauffeur
                                    ? "Nombre de places disponibles"
                                    : "Nombre de voyageurs",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onTap: () async {
                                await Alert(
                                  context: context,
                                  type: AlertType.info,
                                  title: "Serez-vous le conducteur",
                                  desc:
                                      "Serez-vous le conducteur sur ce trajet ?",
                                  buttons: [
                                    DialogButton(
                                      child: Text(
                                        "Oui",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      ),
                                      onPressed: () {
                                        // Mise à jour de l'état
                                        setState(() {
                                          estChauffeur = true;
                                        });
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop(); // Ferme correctement la boîte de dialogue
                                      },
                                      width: 120,
                                    ),
                                    DialogButton(
                                      child: Text(
                                        "Non",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      ),
                                      onPressed: () {
                                        // Mise à jour de l'état
                                        setState(() {
                                          estChauffeur = false;
                                        });
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop(); // Ferme correctement la boîte de dialogue
                                      },
                                      width: 120,
                                    ),
                                  ],
                                ).show();
                              },
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              _selectDayAndTime(context);
                            },
                            child: Text(dateAffiche),
                          ),
                          CupertinoSwitch(
                            value: estChauffeur,
                            trackColor: Colors.blue,
                            onChanged: (value) {
                              setState(() {
                                estChauffeur = value;
                              });
                            },
                          ),
                          Text(
                            estChauffeur
                                ? "Vous êtes conducteur "
                                : "Vous êtes passager",
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: TextButton(
                              style: TextButton.styleFrom(
                                fixedSize: const Size(200, 50),
                                backgroundColor: Color(0xffF18265),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: () async {
                                if(dateVoyage == null){
                                  Alert(
                                    context: context,
                                    type: AlertType.error,
                                    title: "Sélectionnez la date et l'heure !",
                                    desc:
                                    "Veuillez sélectionner une date et une heure minimale de voyage",
                                    buttons: [
                                      DialogButton(
                                        child: Text(
                                          "Fermer",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20),
                                        ),
                                        onPressed: () =>
                                            Navigator.pop(context),
                                        width: 120,
                                      )
                                    ],
                                  ).show();
                                  return;
                                }
                                // Insertion si chauffeur et recherche si voyageur
                                if (NbrePersonnes.text.isEmpty) {
                                  Alert(
                                    context: context,
                                    type: AlertType.error,
                                    title: estChauffeur
                                        ? "Nombre de places disponibles"
                                        : "Nombre de voyageurs",
                                    desc: estChauffeur
                                        ? "Nombre de places disponibles pour le voyage"
                                        : "Nombre de voyageurs vous y compris",
                                    buttons: [
                                      DialogButton(
                                        child: Text(
                                          "Fermer",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20),
                                        ),
                                        onPressed: () => Navigator.pop(context),
                                        width: 120,
                                      ),
                                    ],
                                  ).show();
                                  return;
                                }
                                if (estChauffeur) {
                                  await insertionChauffeur();
                                  if (insert) {
                                    setState(() {
                                    NbrePersonnes.text = "";
                                    dateVoyage = null;
                                    dateAffiche = "Selectionnez la date";
                                    });
                                    Alert(
                                      context: context,
                                      type: AlertType.success,
                                      title: "Merci !",
                                      desc:
                                          "La ligne a été ajoutée avec succès",
                                      buttons: [
                                        DialogButton(
                                          child: Text(
                                            "Fermer",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20),
                                          ),
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          width: 120,
                                        )
                                      ],
                                    ).show();
                                    exec = true;
                                  } else {
                                    Alert(
                                      context: context,
                                      type: AlertType.error,
                                      title: "Désolé !",
                                      desc: "La ligne n'a pas pu être ajoutée",
                                      buttons: [
                                        DialogButton(
                                          child: Text(
                                            "Fermer",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20),
                                          ),
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          width: 120,
                                        )
                                      ],
                                    ).show();
                                  }
                                } else {
                                  await rechercheTrajet();
                                }
                              },
                              child: Text(
                                "Valider",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Liste des trajets trouvés
                if ((trajetTrouve?.length ?? 0) > 0)
                  Expanded(
                    flex: 4,
                    child: ListView.builder(
                      itemCount: trajetTrouve.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            color: (index % 2 == 0)
                                ? Colors.white.withOpacity(0.7)
                                : Colors.cyanAccent.withOpacity(0.7),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(trajetTrouve[index]),
                            ),
                          ),
                          onTap: () async {
                            await chercheChauffeur(index);
                            trajetID = identifiantTrajet[index];
                            Alert(
                              context: context,
                              type: AlertType.none,
                              title: "Voulez vous reservez ?",
                              desc: "Un message sera envoyé au chauffeur. S'il accepte, votre voyage sera confirmé",
                              buttons: [
                                DialogButton(
                                  child: Text(
                                    "oui",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20),
                                  ),
                                  onPressed: () async{
                                    await insertionPassager();
                                    Navigator.pop(context);
                                    setState(() {
                                    trajetTrouve = [];
                                    NbrePersonnes.text = "";
                                    dateVoyage = null;
                                    dateAffiche = "Selectionnez la date";
                                    });
                                  },
                                  width: 120,
                                ),
                                DialogButton(
                                  child: Text(
                                    "non",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20),
                                  ),
                                  onPressed: () =>
                                      Navigator.pop(context),
                                  width: 120,
                                )
                              ],
                            ).show();

                            if(insert) {
                              Flushbar(
                                title: "Message concernant votre voyage sur Zemiyidon",
                                message: "Nous avons envoyé un email au chauffeur. On vous tiendra au courant de sa réponse. \n Merci \n Cordialement",
                                duration: const Duration(seconds: 15),
                              )
                                ..show(context);
                            }
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SectionWidget extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const SectionWidget({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 8, left: 16),
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Material(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).cardColor,
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: items,
          ),
        ),
      ],
    );
  }
}

class PickerItemWidget extends StatelessWidget {
  PickerItemWidget({
    super.key,
    required this.pickerType,
  });

  final DateTimePickerType pickerType;

  final ValueNotifier<DateTime> date = ValueNotifier(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final controller = BoardDateTimeController();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final result = await showBoardDateTimePicker(
            context: context,
            pickerType: pickerType,
            // initialDate: DateTime.now(),
            // minimumDate: DateTime.now().add(const Duration(days: 1)),
            options: BoardDateTimeOptions(
              languages: const BoardPickerLanguages.en(),
              startDayOfWeek: DateTime.sunday,
              pickerFormat: PickerFormat.ymd,
              // boardTitle: 'Board Picker',
              // pickerSubTitles: BoardDateTimeItemTitles(year: 'year'),
              withSecond: DateTimePickerType.time == pickerType,
              customOptions: DateTimePickerType.time == pickerType
                  ? BoardPickerCustomOptions(
                      seconds: [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55],
                    )
                  : null,
            ),
            // Specify if you want changes in the picker to take effect immediately.
            valueNotifier: date,
            controller: controller,
            // onTopActionBuilder: (context) {
            //   return Padding(
            //     padding: const EdgeInsets.symmetric(horizontal: 16),
            //     child: Wrap(
            //       alignment: WrapAlignment.center,
            //       spacing: 8,
            //       children: [
            //         IconButton(
            //           onPressed: () {
            //             controller.changeDateTime(
            //                 date.value.add(const Duration(days: -1)));
            //           },
            //           icon: const Icon(Icons.arrow_back_rounded),
            //         ),
            //         IconButton(
            //           onPressed: () {
            //             controller.changeDateTime(DateTime.now());
            //           },
            //           icon: const Icon(Icons.stop_circle_rounded),
            //         ),
            //         IconButton(
            //           onPressed: () {
            //             controller.changeDateTime(
            //                 date.value.add(const Duration(days: 1)));
            //           },
            //           icon: const Icon(Icons.arrow_forward_rounded),
            //         ),
            //       ],
            //     ),
            //   );
            // },
          );
          if (result != null) {
            date.value = result;
            print('result: $result');
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Row(
            children: [
              Material(
                color: pickerType.color,
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 32,
                  width: 32,
                  child: Center(
                    child: Icon(
                      pickerType.icon,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  pickerType.title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              ValueListenableBuilder(
                valueListenable: date,
                builder: (context, data, _) {
                  return Text(
                    BoardDateFormat(pickerType.formatter(
                      withSecond: DateTimePickerType.time == pickerType,
                    )).format(data),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension DateTimePickerTypeExtension on DateTimePickerType {
  String get title {
    switch (this) {
      case DateTimePickerType.date:
        return 'Date';
      case DateTimePickerType.datetime:
        return 'Date et heure';
      case DateTimePickerType.time:
        return 'Time';
    }
  }

  IconData get icon {
    switch (this) {
      case DateTimePickerType.date:
        return Icons.date_range_rounded;
      case DateTimePickerType.datetime:
        return Icons.date_range_rounded;
      case DateTimePickerType.time:
        return Icons.schedule_rounded;
    }
  }

  Color get color {
    switch (this) {
      case DateTimePickerType.date:
        return Colors.blue;
      case DateTimePickerType.datetime:
        return Colors.orange;
      case DateTimePickerType.time:
        return Colors.pink;
    }
  }

  String get format {
    switch (this) {
      case DateTimePickerType.date:
        return 'yyyy/MM/dd';
      case DateTimePickerType.datetime:
        return 'yyyy/MM/dd HH:mm';
      case DateTimePickerType.time:
        return 'HH:mm';
    }
  }

  String formatter({bool withSecond = false}) {
    switch (this) {
      case DateTimePickerType.date:
        return 'yyyy/MM/dd';
      case DateTimePickerType.datetime:
        return 'yyyy/MM/dd HH:mm';
      case DateTimePickerType.time:
        return withSecond ? 'HH:mm:ss' : 'HH:mm';
    }
  }
}
