import 'package:flutter/material.dart';

class Login extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
        return Container(
          color: Colors.white,
          child: Row(children: 
          [
            TextField(
              decoration: InputDecoration(labelText: "Enter your username:" )
            )
          , TextField(decoration: InputDecoration(labelText: "Enter your password"))
          ])
        );
      }
  
}