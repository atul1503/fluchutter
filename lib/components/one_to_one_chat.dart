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
  List<Map<String, dynamic>> messages = [];

  @override
  Widget build(BuildContext context) {
    List<dynamic> messages =
        context.watch<PersonalMessages>().personal_messages;
    messages
        .sort((a, b) => (a['time'] as String).compareTo(b['time'] as String));
    return ListView.builder(
      itemCount: messages.length,
      itemBuilder: (context, index) {
        var message = messages[index];
        return ListTile(
          title: Message(
            key: ValueKey(message['messageId'].toString()),
            messageId: message['messageId'].toString(),
            preview: false,
            chatroot: false,
          ),
        );
      },
    );
  }
}
