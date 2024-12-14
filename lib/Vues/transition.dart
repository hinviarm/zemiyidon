import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zemiyidon/Vues/profil.dart';

class FadePageRoute<T> extends MaterialPageRoute<T> {
  FadePageRoute({
    required super.builder,
    super.settings,
  });

  @override
  Duration get transitionDuration => const Duration(milliseconds: 600);

  @override
  Widget buildTransitions(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    if (settings.name == Profil.routeName) {
      return child;
    }

    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}