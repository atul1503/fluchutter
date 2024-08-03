import 'package:flutter/material.dart';

class OneToOneChat extends StatefulWidget {
  

  @override
  State<OneToOneChat> createState() => OneToOneChatState();
}

class OneToOneChatState extends State<OneToOneChat> {


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: Text("Hi bieatch")),
        Expanded(child: Text("Hi bieatch")),
        Expanded(child: Text("Hi bieatch")),
        Expanded(child: Text("Hi bieatch")),
        Expanded(child: Text("Hi bieatch")),
      ],
    );
  }
}