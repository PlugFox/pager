import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'debug.dart';
import 'pager_fade_upwards_transitions_builder.dart';
import 'pager_transitions_builder.dart';

typedef PagerWidgetBuilder<S extends Object> = Widget Function(BuildContext context, S state);
typedef PagerBuilderCondition<S extends Object> = bool Function(BuildContext context, S previous, S current);

class Pager<S extends Object> extends StatefulWidget {
  final S initialData;
  final Stream<S> stream;
  final PagerWidgetBuilder<S> builder;
  final PagerBuilderCondition<S> buildWhen;
  final PagerTransitionsBuilder transitionsBuilder;
  const Pager({
    @required this.initialData,
    @required this.stream,
    @required this.builder,
    this.buildWhen,
    this.transitionsBuilder,
    Key key,
  }) : super(key: key);

  /// Перейти на указаную страницу
  static void showPage(BuildContext context, Widget page) {
    final state = context.findAncestorStateOfType<_PagerState>();
    assert(state is _PagerState, 'Pager не найден в контексте');
    state?.showPage(page);
  }

  @override
  State<Pager<S>> createState() => _PagerState<S>();
}

class _PagerState<S extends Object> extends State<Pager<S>> {
  /// Предидущие данные с которыми построена страница
  S _prevState;
  final GlobalKey<OverlayState> _overlayKey = GlobalKey<OverlayState>();
  final Queue<OverlayEntry> _screens = Queue<OverlayEntry>();
  StreamSubscription<S> _streamSubscription;

  //region Lifecycle
  @override
  void initState() {
    super.initState();
    final initialPage = widget.builder(context, widget.initialData);
    final initialEntry = OverlayEntry(builder: (context) => initialPage);
    _screens.add(initialEntry);
    _streamSubscription = widget.stream.listen(_buildAndShowScreen);
    assert(() {
      debug('Pager подписался на поток');
    }());
  }

  @override
  void didUpdateWidget(Pager<S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.stream, oldWidget.stream)) {
      assert(() {
        debug('Pager переподписался на поток');
      }());
      _streamSubscription?.cancel();
      _streamSubscription = widget.stream.listen(_buildAndShowScreen);
    }
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    assert(() {
      debug('Pager отписался от потока');
    }());
    super.dispose();
  }
  //endregion

  @override
  Widget build(BuildContext context) => Overlay(
        key: _overlayKey,
        initialEntries: [_screens.first],
      );

  /// Построить новый экран исходя из подписки на стрим
  void _buildAndShowScreen(S state) {
    if (widget.buildWhen?.call(context, _prevState, state) ?? true) {
      _prevState = state;
      showPage(widget.builder(context, state));
    }
  }

  void showPage(Widget page) {
    assert(page is Widget, 'Передаваемый экран должен быть виджетом');
    final overlayState = _overlayKey.currentState;
    assert(overlayState is OverlayState, 'Не найден OverlayState');
    if (page is! Widget || overlayState is! OverlayState) return;
    final animatedPage = _AnimatedPagerPage(
      child: page,
      transitionsBuilder: widget.transitionsBuilder ?? const PagerFadeUpwardsTransitionsBuilder(),
      popCallback: () => pop(),
    );
    final entry = OverlayEntry(
      builder: (context) => animatedPage,
    );
    _screens.add(entry);
    overlayState?.insert(entry);
    assert(() {
      debug('Показана новая страница, осталось: ${_screens.length}');
    }());
  }

  void pop() {
    assert(_screens.length > 1, 'Произведена попытка убрать из ScreenStreamBuilder единственный экран');
    if (_screens.length < 2) return;
    _screens.removeFirst().remove();
    assert(() {
      debug('Убрана предидущая страница, осталось: ${_screens.length}');
    }());
  }
}

@immutable
class _AnimatedPagerPage extends StatefulWidget {
  final Widget child;
  final PagerTransitionsBuilder transitionsBuilder;

  /// Вызывается в момент когда этот новый экран целиком отрисовался
  /// и надо убрать предидущий.
  final VoidCallback popCallback;
  const _AnimatedPagerPage({
    @required this.child,
    @required this.transitionsBuilder,
    @required this.popCallback,
    Key key,
  }) : super(key: key);

  @override
  State<_AnimatedPagerPage> createState() => _AnimatedPagerPageState();
}

class _AnimatedPagerPageState extends State<_AnimatedPagerPage> with SingleTickerProviderStateMixin<_AnimatedPagerPage> {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      lowerBound: 0,
      upperBound: 1,
      value: 0,
    )
      ..addStatusListener((status) {
        if (status != AnimationStatus.completed) return;
        widget.popCallback();
      })
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) => super.debugFillProperties(
        properties
          ..add(
            StringProperty(
              'description',
              '_AnimatedScreenState State<_AnimatedScreen>',
            ),
          ),
      );

  @override
  Widget build(BuildContext context) => Positioned.fill(
        child: widget.transitionsBuilder.buildTransitions(
          context,
          _controller,
          widget.child,
        ),
      );
}
