import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fluchutter/components/chat.dart';
import 'package:fluchutter/main.dart';
import 'package:fluchutter/models/personal_messages.dart';
import 'package:fluchutter/models/user_details.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class OneToOneChat extends StatefulWidget {
  @override
  State<OneToOneChat> createState() => OneToOneChatState();
}

class OneToOneChatState extends State<OneToOneChat> {
  List<Map<String, dynamic>> messages = [];

  @override
  Widget build(BuildContext context) {
    var screensize = MediaQuery.of(context).size;
    List<dynamic> messages =
        context.watch<PersonalMessages>().personal_messages;
    messages
        .sort((a, b) => (a['time'] as String).compareTo(b['time'] as String));
    return Stack(children: [
      ListView.builder(
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
      ),
      Positioned(child: MessageInput())
    ]);
  }
}

class MessageInput extends StatefulWidget {
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  XFile? image;
  String image_name="";
  ImagePicker picker = ImagePicker();
  String upload_response = "";
  TextEditingController messageController=TextEditingController();

  void pickImage(BuildContext ctx) {
    picker.pickImage(source: ImageSource.gallery).then((picketFile) {
      if (picketFile != null) {
          setState(() {
            image_name=picketFile.name;
            image=picketFile;
          });
        }
      else {
        print("No filed picked..");
      }
    });
  }

  void uploadImage() async {
    if (image == null) {
      showDialog(
          context: context,
          builder: (BuildContext ctx) {
            var friend = ctx.read<PersonalMessages>().friend;
            return AlertDialog(
              title: Text("No image picked"),
              actions: [
                TextButton(
                    onPressed: () => {Navigator.of(context).pop()},
                    child: Text("Dismiss"))
              ],
            );
          });
    }

    
    //upload image
    BuildContext ctx = navigatorKey.currentContext as BuildContext;
    var friend = ctx.read<PersonalMessages>().friend;
    var username = ctx.read<UserDetails>().userdetails['username'] as String;
    final Uri uri = Uri.parse("http://localhost:8080/messages/create");
    var request = http.MultipartRequest('POST', uri);
    request.fields['recid'] = friend;
    request.fields['senderid'] = username;
    request.files.add(await http.MultipartFile.fromBytes('image',await image!.readAsBytes(),filename: image_name,contentType: MediaType('image', image_name.split(".")[1])));

    request.send().then((response) async {
      http.Response.fromStream(response).then((final_response) {
        setState(() async {
          upload_response = final_response.body;
          showDialog(
              context: context,
              builder: (BuildContext ctx) {
                return AlertDialog(
                  title: Text(upload_response),
                  actions: [
                    TextButton(onPressed: (){Navigator.of(ctx).pop();}, child: Text("Dismiss"))
                  ],
                );
              });
          if(final_response.statusCode==200){
              Uri uri=Uri.parse("http://localhost:8080/messages/latest?userone=${friend}&usertwo=${username}");
        var response= await http.get(uri);
        ctx.read<PersonalMessages>().setmessages(jsonDecode(response.body));
          }
        });
      });
    });
  }

  void sendMessage(BuildContext ctx) async {
      var friend=ctx.read<PersonalMessages>().friend;
      var username=ctx.read<UserDetails>().userdetails['username'];
      var response=await http.post(Uri.parse("http://localhost:8080/messages/createSimple?text=${messageController.text}&senderid=${username}&recid=${friend}"));
      if(response.statusCode==200){
        var username=ctx.read<UserDetails>().userdetails['username'];
        Uri uri=Uri.parse("http://localhost:8080/messages/latest?userone=${friend}&usertwo=${username}");
        var response=await http.get(uri);
        ctx.read<PersonalMessages>().setmessages(jsonDecode(response.body));
      }
  }

  @override
  Widget build(BuildContext context) {
    var screensize = MediaQuery.of(context).size;
    return Stack(
      children: [
        Positioned(
            width: screensize.width * 0.6,
            bottom: 0,
            child: TextField(
              decoration: InputDecoration(labelText: "Type your message"),
              controller: messageController,
            )),
        Positioned(
            bottom: 0,
            right: screensize.width * 0.3,
            child: ElevatedButton(
                onPressed: () {
                  pickImage(context);
                },
                child: Text("pick image"))),
        Positioned(
            bottom: 0,
            right: screensize.width * 0.15,
            child: ElevatedButton(
                onPressed: () {
                  sendMessage(context);
                },
                child: Text("Send"))),
        Positioned(
            bottom: 0,
            right: screensize.width * 0,
            child: ElevatedButton(
              child: Text("Upload it"),
              onPressed: uploadImage,
            ))
      ],
    );
  }
}
