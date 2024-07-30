import 'dart:async';
import 'dart:convert';

import 'package:fluchutter/main.dart';
import 'package:fluchutter/models/user_details.dart';
import 'package:http/http.dart' as http;
import 'package:fluchutter/models/messages.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Chat extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _ChatState();
}

class _ChatState extends State<StatefulWidget> {
  var messages=[];
  List<Message> messageWidgets=[];

  @override
  void initState() {
    final BuildContext? ctx=navigatorKey.currentContext;
    if(ctx==null){return;}
    String? username=ctx.watch<UserDetails>().userdetails['username'];
    http.get(Uri.parse('http://localhost:8080/messages/getlatestfromfriends?username=$username'))
    .then((response){
      messages=jsonDecode(response.body);
    });
    super.initState();
  }
  

  @override
  Widget build(BuildContext context) {
    messages.map((item){
      messageWidgets.add(Message(messageId: item['messageId']));
    });
    return Row(
        children: messageWidgets,
      );
  }


}

class Message extends StatefulWidget {

  final String messageId;
  Message({required this.messageId});
  @override
  State<Message> createState() => _MessageState();
}

class _MessageState extends State<Message> {
  bool isUserMessage=false;
  late Future<bool> gotImage;
  String _messageid="";
  @override
  void initState() {
    _messageid=widget.messageId;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Map<String,dynamic> message={};
    List<Map<String,dynamic>> messages=context.watch<Messages>().messages;
    String username=context.watch<String>();
    messages.forEach((messageitem){
      if(messageitem['messageId']==_messageid){
        message=messageitem;
      }
    });

    if(message['msgcontent']['type']=='text'){
      if(username==message['sender']['username']) {
          return Container(
            alignment: Alignment.centerRight,
            child: Row(children: [
              Text('${message['msgcontent']['text']}'),
              Text('${message['time']}',style: TextStyle(fontSize: 10)) 
            ],
            )
          );
      }
      else{
          return Container(
            alignment: Alignment.centerLeft,
            child: Row(children: [
              Text('${message['msgcontent']['text']}'),
              Text('${message['time']}',style: TextStyle(fontSize: 10)) 
            ],
            )
          );
      }
    }
    else{
      String photoname=message['msgcontent']['photourl'];
      http.get(Uri.parse('http://localhost:8080/messages/image?image_name=$photoname'))
      .then((response){
        message['photobyte']=response.body;
        gotImage=Future.value(true);
      });
      return FutureBuilder(future: gotImage, builder: (context,snapshot){
        if(snapshot.connectionState==ConnectionState.waiting){
          return Center(child: CircularProgressIndicator());
        }
        else{
          return Row(children: [
              Image.memory(base64Decode(message['photobyte'])),
              Text('${message['time']}',style: TextStyle(fontSize: 10))
            ],);
        }
      });
    }
  }
}