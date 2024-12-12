import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:switcher_button/switcher_button.dart';

class Accueil extends StatefulWidget {
  const Accueil({super.key});

  @override
  State<Accueil> createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  var _Depart = '';
  var _Destination = '';
  var _NbrePersonnes = '';
  bool? _Rep;
  bool exec = false;
  bool estChauffeur = false;

  final Depart = TextEditingController();
  final Destination = TextEditingController();
  final NbrePersonnes = TextEditingController();
  var latitude = 0.0;
  var longitude = 0.0;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    Depart.dispose();
    Destination.dispose();
    NbrePersonnes.dispose();
    super.dispose();
  }

  // Fields in a Widget subclass are always marked "final".

  //final Widget title;
  _onChangeText(value) => debugPrint("_onChangeText: $value");

  _onSubmittedText(value) => debugPrint("_onSubmittedText: $value");

  String endwithSpace(tmp) {
    while (tmp.endsWith(' ')) {
      tmp = tmp.substring(0, tmp.length - 1);
    }
    return tmp;
  }

  @override
  void initState() {
    super.initState();
  }

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
          new Flex(
            direction: Axis.vertical,
            children: <Widget>[
              Expanded(
                flex: 7,
                child: Container(
                  color: Colors.white.withOpacity(0.7),
                  height: 40,
                  child: TextFormField(
                    onChanged: _onChangeText,
                    controller: Depart,
                    decoration: InputDecoration(
                      labelText: 'Votre point de Départ ',
                      hintText: 'Votre point de Départ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (Depart.text.isEmpty) {
                        return 'S\'il vous plaît entrez votre nom';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 7,
                child: Container(
                  color: Colors.white.withOpacity(0.7),
                  height: 40,
                  child: TextFormField(
                    onChanged: _onChangeText,
                    controller: Destination,
                    decoration: InputDecoration(
                      labelText: 'Votre destination',
                      hintText: 'Votre destination',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (Destination.text.isEmpty) {
                        return 'S\'il vous plaît entrez votre destination';
                      }
                      return null;
                    },
                    onTap: () {
                      Alert(
                        context: context,
                        type: AlertType.info,
                        title: "Serez vous le conducteur",
                        desc: "Serez vous le conducteur sur ce trajet ?",
                        buttons: [
                          DialogButton(
                            child: Text(
                              "Oui",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            onPressed: () {
                              setState(() {
                                estChauffeur = true;
                              });
                              debugPrint("!!!!!!!!!!!!!!"+estChauffeur.toString());
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
                            onPressed: () {
                              setState(() {
                                estChauffeur = false;
                              });
                              Navigator.pop(context);
                            },
                            width: 120,
                          ),
                        ],
                      ).show();
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 7,
                child: Container(
                  color: Colors.white.withOpacity(0.7),
                  height: 40,
                  child: TextFormField(
                    onChanged: _onChangeText,
                    controller: NbrePersonnes,
                    decoration: InputDecoration(
                      labelText: "Nombre de voyageurs",
                      hintText: "Nombre de voyageurs",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (NbrePersonnes.text.isEmpty ||
                          !NbrePersonnes.text.startsWith("@")) {
                        return 'S\'il vous plaît entrez un nom correcte';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 7,
                child: Container(
                  color: Colors.white.withOpacity(0.7),
                  height: 40,
                  child: PickerItemWidget(
                    pickerType: DateTimePickerType.datetime,
                  ),
                ),
              ),
              Column(
                children: [
                  CupertinoSwitch(
                    value: estChauffeur,
                    trackColor: Colors.blue,
                    onChanged: (value) {
                      setState(() {
                        estChauffeur = value;
                      });
                    },
                  ),
                  Text("Vous êtes le conducteur "+ estChauffeur.toString()),
                ],
              ),
              Expanded(
                flex: 3,
                child: TextButton(
                  style: TextButton.styleFrom(
                    fixedSize: const Size(200, 100),
                    backgroundColor: Color(0xffF18265),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    if (_Rep == true && exec == false) {
                      Alert(
                        context: context,
                        type: AlertType.success,
                        title: "Merci !",
                        desc: "La ligne a été ajoutée avec succès",
                        buttons: [
                          DialogButton(
                            child: Text(
                              "Fermer",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            onPressed: () => Navigator.pop(context),
                            width: 120,
                          )
                        ],
                      ).show();
                      exec = true;
                    } else {
                      Alert(
                        context: context,
                        type: AlertType.error,
                        title: "Merci !",
                        desc: "La ligne n'a pas pu être ajoutée",
                        buttons: [
                          DialogButton(
                            child: Text(
                              "Fermer",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            onPressed: () => Navigator.pop(context),
                            width: 120,
                          )
                        ],
                      ).show();
                    }
                  },
                  child: Text(
                    "Valider",
                    style: TextStyle(
                      color: Color(0xffffffff),
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
