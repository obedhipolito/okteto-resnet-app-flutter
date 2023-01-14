import 'package:flutter/material.dart';
import 'package:prueba2/HOME_SCREEN.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget{
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Resnet',
      home: HomeScreen(),
    );
  }
}