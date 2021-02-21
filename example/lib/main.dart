import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pager/pager.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Pager',
        home: const PagerExample(),
      );
}

@immutable
class PagerExample extends StatefulWidget {
  const PagerExample({
    Key key,
  }) : super(key: key);

  static _PagerExampleState of(BuildContext context) => context.findAncestorStateOfType<_PagerExampleState>();

  @override
  State<PagerExample> createState() => _PagerExampleState();
}

class _PagerExampleState extends State<PagerExample> {
  final StreamController<int> _controller = StreamController<int>.broadcast();
  //StreamSubscription<void> _sub;

  void goToPage1() => _controller.add(1);
  void goToPage2() => _controller.add(2);
  void goToPage3() => _controller.add(3);

  @override
  void initState() {
    super.initState();
    //final Random rnd = Random();
    //_sub = Stream<void>.periodic(const Duration(milliseconds: 150)).listen((event) {
    //  _controller.add(rnd.nextInt(2) + 1);
    //});
  }

  @override
  void dispose() {
    //_sub.cancel();
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Pager<int>(
        initialData: 1,
        stream: _controller.stream,
        builder: (context, state) {
          switch (state) {
            case 1:
              return const Page1();
            case 2:
              return const Page2();
            case 3:
            default:
              return const Page3();
          }
        },
      );
}

@immutable
class Page1 extends StatelessWidget {
  const Page1({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Page #1'),
        ),
        body: SafeArea(
          child: Center(
            child: OutlinedButton(
              child: Text('Go to Page #2'),
              onPressed: () => PagerExample.of(context).goToPage2(),
            ),
          ),
        ),
      );
}

@immutable
class Page2 extends StatelessWidget {
  const Page2({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Page #2'),
        ),
        body: SafeArea(
          child: Center(
            child: OutlinedButton(
              child: Text('Go to Page #3'),
              onPressed: () => PagerExample.of(context).goToPage3(),
            ),
          ),
        ),
      );
}

@immutable
class Page3 extends StatelessWidget {
  const Page3({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Page #3'),
        ),
        body: SafeArea(
          child: Center(
            child: OutlinedButton(
              child: Text('Go to Page #4'),
              onPressed: () => Pager.showPage(context, const Page4()),
            ),
          ),
        ),
      );
}

@immutable
class Page4 extends StatelessWidget {
  const Page4({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Page #4'),
        ),
        body: SafeArea(
          child: Center(
            child: OutlinedButton(
              child: Text('Go to Page #1'),
              onPressed: () => Pager.showPage(context, const Page1()),
            ),
          ),
        ),
      );
}
