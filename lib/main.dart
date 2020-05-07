import 'package:Dietryz/screens/food_display.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget 
{
  @override
  Widget build(BuildContext context) 
  {
    return MaterialApp(
      title: 'Food',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: 'home_screen',
      routes: 
      {
        'home_screen'            : (context) => FoodDisplay(title: 'Foods',),
      },
    );
  }
}