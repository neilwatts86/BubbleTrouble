import 'package:flutter/material.dart';

class Counter extends StatelessWidget {

  final counter;

  Counter({this.counter});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('$counter',style: TextStyle(color: Colors.blue,fontStyle: FontStyle.normal),)
          ],
        ),
      ),
    );
  }
}
