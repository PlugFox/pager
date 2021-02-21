import 'package:flutter/widgets.dart';

import 'pager_transitions_builder.dart';

class PagerFadeUpwardsTransitionsBuilder implements PagerTransitionsBuilder {
  const PagerFadeUpwardsTransitionsBuilder();
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Widget child,
  ) =>
      _PagerFadeUpwardsTransition(
        animation: animation,
        child: child,
      );
}

class _PagerFadeUpwardsTransition extends StatelessWidget {
  _PagerFadeUpwardsTransition({
    @required Animation<double> animation,
    @required this.child,
    Key key,
  })  : _positionAnimation = animation.drive(_bottomUpTween.chain(_fastOutSlowInTween)),
        _opacityAnimation = animation.drive(_easeInTween),
        super(key: key);

  // Fractional offset from 1/4 screen below the top to fully on screen.
  static final Tween<Offset> _bottomUpTween = Tween<Offset>(
    begin: const Offset(0.0, 0.25),
    end: Offset.zero,
  );
  static final Animatable<double> _fastOutSlowInTween = CurveTween(curve: Curves.fastOutSlowIn);
  static final Animatable<double> _easeInTween = CurveTween(curve: Curves.easeIn);

  final Animation<Offset> _positionAnimation;
  final Animation<double> _opacityAnimation;
  final Widget child;

  @override
  Widget build(BuildContext context) => SlideTransition(
        position: _positionAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: child,
        ),
      );
}
