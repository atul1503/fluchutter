import 'dart:convert';

import 'package:fluchutter/components/chat.dart';
import 'package:fluchutter/endpoint.dart';
import 'package:fluchutter/main.dart';
import 'package:fluchutter/models/app_navigation.dart';
import 'package:fluchutter/models/personal_messages.dart';
import 'package:fluchutter/models/user_details.dart';
import 'package:flutter/material.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class OneToOneChat extends StatefulWidget {
  @override
  State<OneToOneChat> createState() => OneToOneChatState();
}

class OneToOneChatState extends State<OneToOneChat> {
  final BuildContext ctx = navigatorKey.currentContext as BuildContext;
  String token = "";

  @override
  void initState() {
    setState(() {
      token = ctx.watch<UserDetails>().token;
    });

    super.initState();
  }

  void getOld() {
    List<dynamic> messages = ctx.read<PersonalMessages>().personal_messages;
    var friend = ctx.read<PersonalMessages>().friend;
    var username = ctx.read<UserDetails>().userdetails['username'];
    Uri uri = Uri.parse(
        "http://${endpoint_with_port}/messages/latest?userone=${friend}&usertwo=${username}&afterDate=${messages[0]['time']}");
    http.get(uri, headers: {'Authorization': 'Bearer $token'}).then((response) {
      List _new_messages = jsonDecode(response.body) as List;
      List new_messages = _new_messages.where((msg) {
        for (int i = 0; i < messages.length; i++) {
          if (messages[i]['messageId'] == msg["messageId"]) {
            return false;
          }
        }
        return true;
      }).toList();
      ctx.read<PersonalMessages>().setmessages(messages + new_messages);
    });
  }

  void getNew() {
    List<dynamic> messages = ctx.read<PersonalMessages>().personal_messages;
    var friend = ctx.read<PersonalMessages>().friend;
    var username = ctx.read<UserDetails>().userdetails['username'];
    Uri uri = Uri.parse(
        "http://${endpoint_with_port}/messages/latest?userone=${friend}&usertwo=${username}&beforeDate=${messages[messages.length - 1]['time']}");
    http.get(uri, headers: {'Authorization': 'Bearer $token'}).then((response) {
      var _new_messages = jsonDecode(response.body) as List;
      if (_new_messages.length == 1) {
        return;
      }

      List new_messages = _new_messages.where((msg) {
        for (int i = 0; i < messages.length; i++) {
          if (messages[i]['messageId'] == msg["messageId"]) {
            return false;
          }
        }
        return true;
      }).toList();
      ctx.read<PersonalMessages>().setmessages(messages + new_messages);
    });
  }

  @override
  Widget build(BuildContext ctx) {
    var screensize = MediaQuery.of(context).size;
    List<dynamic> messages =
        context.watch<PersonalMessages>().personal_messages;
    String friend = context.watch<PersonalMessages>().friend;

    messages
        .sort((a, b) => (a['time'] as String).compareTo(b['time'] as String));
    return Stack(children: [
      Flex(direction: Axis.vertical, children: [
        Flexible(
            flex: 2,
            fit: FlexFit.tight,
            child: Center(
                child: Text(friend,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 25)))),
        Flexible(
            flex: 7,
            fit: FlexFit.tight,
            child: ListView.builder(
              padding: EdgeInsets.only(bottom: 100),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                var message = messages[index];
                return FocusDetector(
                    onVisibilityGained: () {
                      if (index == 0) {
                        getOld();
                      }
                      if (index == messages.length - 1) {
                        getNew();
                      }
                    },
                    child: ListTile(
                        title: Message(
                      key: ValueKey(message['messageId'].toString()),
                      messageId: message['messageId'].toString(),
                      preview: false,
                      chatroot: false,
                    )));
              },
            )),
        Flexible(flex: 1, child: MessageInput())
      ])
    ]);
  }
}

class MessageInput extends StatefulWidget {
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  XFile? image;
  String image_name = "";
  ImagePicker picker = ImagePicker();
  String token = "";
  String upload_response = "";
  TextEditingController messageController = TextEditingController();
  final BuildContext ctx = navigatorKey.currentContext as BuildContext;

  @override
  void initState() {
    setState(() {
      token = ctx.watch<UserDetails>().token;
    });
    super.initState();
  }

  void pickImage(BuildContext ctx) {
    picker.pickImage(source: ImageSource.gallery).then((picketFile) {
      if (picketFile != null) {
        setState(() {
          image_name = picketFile.name;
          image = picketFile;
        });
      } else {
        print("No filed picked..");
      }
    });
  }

  void uploadImage() async {
    if (image == null) {
      showDialog(
          context: context,
          builder: (BuildContext ctx) {
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
    final Uri uri = Uri.parse("http://${endpoint_with_port}/messages/create");
    var request = http.MultipartRequest('POST', uri);
    request.fields['recid'] = friend;
    request.fields['senderid'] = username;
    request.files.add(await http.MultipartFile.fromBytes(
        'image', await image!.readAsBytes(),
        filename: image_name,
        contentType: MediaType('image', image_name.split(".")[1])));

    request.headers['Authorization'] = 'Bearer $token';
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
                    TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        child: Text("Dismiss"))
                  ],
                );
              });
          if (final_response.statusCode == 200) {
            Uri uri = Uri.parse(
                "http://${endpoint_with_port}/messages/latest?userone=${friend}&usertwo=${username}");
            var response = await http
                .get(uri, headers: {'Authorization': 'Bearer $token'});
            ctx.read<PersonalMessages>().setmessages(jsonDecode(response.body));
          }
        });
      });
    });
  }

  void sendMessage(BuildContext ctx) async {
    if (image != null) {
      uploadImage();
      setState(() {
        image = null;
      });
      return;
    }
    var friend = ctx.read<PersonalMessages>().friend;
    var username = ctx.read<UserDetails>().userdetails['username'];
    var response = await http.post(
        Uri.parse(
            "http://${endpoint_with_port}/messages/createSimple?text=${messageController.text}&senderid=${username}&recid=${friend}"),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      var username = ctx.read<UserDetails>().userdetails['username'];
      Uri uri = Uri.parse(
          "http://${endpoint_with_port}/messages/latest?userone=${friend}&usertwo=${username}");
      var response =
          await http.get(uri, headers: {'Authorization': 'Bearer $token'});
      ctx.read<PersonalMessages>().setmessages(jsonDecode(response.body));
    }
  }

  @override
  Widget build(BuildContext context) {
    var screensize = MediaQuery.of(context).size;
    return Container(
        color: Colors.white,
        child: PopScope(
            canPop: false,
            onPopInvoked: (bool didPop) {
              ctx.read<appNavigation>().setfrontpage("chat");
            },
            child: Stack(
              children: [
                Positioned(
                    top: screensize.height * 0.95,
                    child: Container(
                      width: screensize.width * 0.7,
                      height: screensize.height * 0.1,
                      color: Colors.white,
                    )),
                Positioned(
                    width: screensize.width * 0.6,
                    bottom: 0,
                    child: TextField(
                      decoration:
                          InputDecoration(labelText: "Type your message"),
                      controller: messageController,
                    )),
                Positioned(
                    bottom: 0,
                    right: screensize.width * 0.3,
                    child: ElevatedButton(
                        onPressed: () {
                          pickImage(context);
                        },
                        child: Icon(Icons.image))),
                Positioned(
                    bottom: 0,
                    right: screensize.width * 0.15,
                    child: ElevatedButton(
                        onPressed: () {
                          sendMessage(context);
                        },
                        child: Icon(Icons.send)))
              ],
            )));
  }
}
