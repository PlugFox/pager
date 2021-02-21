import 'package:flutter/widgets.dart';

abstract class PagerTransitionsBuilder {
  const PagerTransitionsBuilder();
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Widget child,
  );
}
