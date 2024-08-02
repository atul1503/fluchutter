import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:fluchutter/main.dart';
import 'package:fluchutter/models/user_details.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:fluchutter/models/messages.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Chat extends StatefulWidget {

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  List<dynamic> messages=[];
  List<Message> messageWidgets=[];

  void setMessages(List<dynamic> _message){
    setState(() {
      messages=_message;
    });
  }

  void addMsgWidgets(Message widgets){
    setState(() {
      messageWidgets.add(widgets);
    });
  }

  @override
  void initState() {
    super.initState();
    final BuildContext ctx=navigatorKey.currentContext as BuildContext;

    String? username=ctx.watch<UserDetails>().userdetails['username'];
    http.get(Uri.parse('http://localhost:8080/messages/getlatestfromfriends?username=$username'),headers: {'credentials': 'include'})
    .then((response){
      setMessages(jsonDecode(response.body));
      ctx.read<Messages>().moveMessages(jsonDecode(response.body));
    });
  }
  

  @override
  Widget build(BuildContext context) {
    for(int i=0;i<messages.length;i++){
      addMsgWidgets(Message(messageId: messages[i]['messageId'].toString()));
    }
    return Column(children: messageWidgets,);
  }


}

class Message extends StatefulWidget {

  final String messageId;
  Message({required this.messageId});
  @override
  State<Message> createState() => _MessageState();
}

class _MessageState extends State<Message> {
  
  String messageid="";
  String username="";
  Map<String,dynamic> message={};
  late Uint8List photobytes;

  void setmessage(Map<String,dynamic> msg){
    setState(() {
      message=msg;
    });
  }

  void setmessageid(String id){
    setState(() {
      messageid=id;
    });
  }

  void setusername(String name){
    setState(() {
      username=name;
    });
  }

  @override
  void initState(){
    super.initState();
    setmessageid(widget.messageId);
    BuildContext ctx=navigatorKey.currentContext as BuildContext;
    setusername(ctx.watch<UserDetails>().userdetails['username'] as String);
    List<dynamic> messages=ctx.watch<Messages>().messages;
    for(int i=0;i<messages.length;i++){
      if(messages[i]['messageId'].toString()==messageid){
        setmessage(messages[i]);
      }
    }
    if(message['msgcontent']['type']!='text'){
      http.get(Uri.parse('http://localhost:8080/messages/image?image_name=${message['msgcontent']['photourl']}'))
      .then((response){
          setState(() {
            photobytes=response.bodyBytes;
          });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(children: [
        message['msgcontent']['type']=='text'?Text(message['msgcontent']['text']):Image.memory(photobytes),
        Text(message['time'])
      ],)
    );
  }
}