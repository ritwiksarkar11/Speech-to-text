import 'package:flutter/material.dart';
import 'HomePage.dart';

void main() => runApp(MyText());
class MyText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        primaryColor: Color(0xFF200f21),
        scaffoldBackgroundColor: Color(0xFF382039),
      ),
      home: HomePage(),
    );
  }
}

