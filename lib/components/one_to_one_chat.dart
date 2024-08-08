import 'package:fluchutter/components/chat.dart';
import 'package:fluchutter/main.dart';
import 'package:fluchutter/models/personal_messages.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OneToOneChat extends StatefulWidget {
  

  @override
  State<OneToOneChat> createState() => OneToOneChatState();
}

class OneToOneChatState extends State<OneToOneChat> {

  List<Map<String,dynamic>> messages=[];

  @override
  void initState() {
    final BuildContext ctx=navigatorKey.currentContext as BuildContext;

    
  }

  @override
  Widget build(BuildContext context) {
     List<dynamic> messages=context.watch<PersonalMessages>().personal_messages;
    return Column(
      children: [for (var message in messages)  Expanded(child: Message(key: ValueKey(message['messageId'].toString()),  messageId: message['messageId'].toString(), preview: false))],
    );
  }
}