import 'package:flutter/material.dart';

class EmptyPage extends StatelessWidget {
  final String text;

  EmptyPage(this.text);

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Center(
        child: Padding(
          padding: const EdgeInsets.all(35),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, color: Colors.grey),
          ),
        ),
      ),
      ListView(),
    ]);
  }
}
