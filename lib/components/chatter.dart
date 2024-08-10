import 'package:fluchutter/components/chat.dart';
import 'package:fluchutter/components/one_to_one_chat.dart';
import 'package:flutter/material.dart';

class Chatter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screensize = MediaQuery.of(context).size;
    return Container(
        width: screensize.width,
        child: Row(children: [
          Container(
              decoration: BoxDecoration(
                  border:
                      Border(right: BorderSide(color: Colors.green, width: 3))),
              width: screensize.width * 0.3,
              child: Chat()),
          Container(
            width: screensize.width * 0.7,
            child: OneToOneChat(),
          )
        ]));
  }
}
