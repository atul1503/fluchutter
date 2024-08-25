import 'dart:convert';

import 'package:fluchutter/endpoint.dart';
import 'package:fluchutter/models/app_navigation.dart';
import 'package:fluchutter/models/personal_messages.dart';
import 'package:http/http.dart' as http;
import 'package:fluchutter/models/user_details.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewChat extends StatefulWidget {
  @override
  State<NewChat> createState() => _NewChatState();
}

class _NewChatState extends State<NewChat> {
  final TextEditingController newFriendUsernameController =
      TextEditingController();

  void getFriendMessages(BuildContext ctx) {
    final String username =
        ctx.read<UserDetails>().userdetails['username'] as String;
    final Uri uri = Uri.parse(
        "http://${endpoint_with_port}/messages/latest?userone=${newFriendUsernameController.text}&usertwo=${username}");
    http.get(uri).then((response) {
      List<dynamic> data = jsonDecode(response.body);
      ctx.read<PersonalMessages>().setFriend(newFriendUsernameController.text);
      if (data.isEmpty) {
        ctx.read<PersonalMessages>().setmessages([]);
      } else {
        ctx.read<PersonalMessages>().setmessages(data);
      }
      ctx.read<appNavigation>().setfrontpage('chat');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration:
              InputDecoration(labelText: "Enter your new friend's username"),
          controller: newFriendUsernameController,
        ),
        ElevatedButton(
            onPressed: () => getFriendMessages(context),
            child: Text("chat with them"))
      ],
    );
  }
}
