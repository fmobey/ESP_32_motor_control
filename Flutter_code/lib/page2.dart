import 'package:flutter/material.dart';
import 'package:flutter_app_joypad_ble/main.dart';


class page2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Komutlar',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Komutlar'),
          
        ),
        body: Center(
          child: Text('Hello World'),
        ),
      ),
    );
  }
}