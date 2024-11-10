import 'dart:convert';
import 'package:fluchutter/endpoint.dart';
import 'package:fluchutter/models/app_navigation.dart';
import 'package:fluchutter/main.dart';
import 'package:fluchutter/models/personal_messages.dart';
import 'package:fluchutter/models/user_details.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:fluchutter/models/messages.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Chat extends StatefulWidget {
  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final BuildContext ctx = navigatorKey.currentContext as BuildContext;
  String? username,token;
  List<dynamic> messages = [];
  List<Expanded> messageWidgets = [];
  bool get_new_old_flag = true;

  void setMessages(List<dynamic> _message) {
    setState(() {
      messages = _message;
    });
  }

  void setUsername(String _username){
    setState(() {
      username=_username;
    });
  }

  void setToken(String _token){
    setState(() {
      token=_token;
    });
  }

  void addMsgWidgets(InkWell widgets) {
    setState(() {
      messageWidgets.add(Expanded(child: widgets));
    });
  }

  @override
  void initState() {
    super.initState();

    setUsername(ctx.watch<UserDetails>().userdetails['username'] ?? '');
    setToken(token = ctx.watch<UserDetails>().token);

    http.get(
        Uri.parse(
            'http://${endpoint_with_port}/messages/getlatestfromfriends?username=$username'),
        headers: {'Authorization': 'Bearer $token'}).then((response) {
      messages = jsonDecode(response.body);
      messages.sort((a, b) => a['time'].compareTo(b['time']));
      setMessages(messages);
      ctx.read<Messages>().moveMessages(messages);
    });
  }

  void changePersonChat(BuildContext ctx, String friend_username) {
    var personal_messages = ctx.read<PersonalMessages>();
    http
        .get(Uri.parse(
            "http://${endpoint_with_port}/messages/latest?userone=${friend_username}&usertwo=${username}"),headers: {
          'Authorization': 'Bearer $token'
    })
        .then((response) {
      personal_messages.setmessages(jsonDecode(response.body));
      personal_messages.setFriend(friend_username);
    });
  }

  void getOld(PointerEnterEvent) {
    if (!get_new_old_flag) {
      return;
    }
    if (messages.length < 1) {
      return;
    }
    String? username = ctx.read<UserDetails>().userdetails['username'];
    http.get(
        Uri.parse(
            'http://${endpoint_with_port}/messages/getlatestfromfriends?username=$username&afterDate=${messages[0]['time']}'),
        headers: {
    'Authorization': 'Bearer $token'
    }).then((response) {
      messages = jsonDecode(response.body);
      messages.sort((a, b) => a['time'].compareTo(b['time']));
      setMessages(messages);
      ctx.read<Messages>().moveMessages(messages);
      setState() {
        get_new_old_flag = false;
      }
    });
  }

  void getNew(PointerEnterEvent e) {
    if (!get_new_old_flag) {
      return;
    }
    if (messages.length < 1) {
      return;
    }
    String? username = ctx.read<UserDetails>().userdetails['username'];
    http.get(
        Uri.parse(
            'http://${endpoint_with_port}/messages/getlatestfromfriends?username=$username&beforeDate=${messages[messages.length - 1]['time']}'),
        headers: {
    'Authorization': 'Bearer $token'
    }).then((response) {
      messages = jsonDecode(response.body);
      messages.sort((a, b) => a['time'].compareTo(b['time']));
      setMessages(messages);
      ctx.read<Messages>().moveMessages(messages);
      setState() {
        get_new_old_flag = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String? username = context.watch<UserDetails>().userdetails['username'];
    var screensize = MediaQuery.of(context).size;

    return Stack(
      children: [
        ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            var item = messages[index];
            var friend;
            if (messages[index]['sender']['username'] == username) {
              friend = messages[index]['receiver']['username'];
            } else {
              friend = messages[index]['sender']['username'];
            }
            return ListTile(
              title: InkWell(
                onTap: () => changePersonChat(context, friend),
                child: Message(
                    chatroot: true,
                    key: ValueKey(item['messageId'].toString()),
                    messageId: item['messageId'].toString(),
                    preview: true),
              ),
            );
          },
        ),
        Positioned(
            bottom: screensize.height * 0.05,
            right: screensize.width * 0.02,
            child: ElevatedButton(
              child: Icon(Icons.add),
              onPressed: () {
                context.read<appNavigation>().setfrontpage('new_chat');
              },
            )),
        Positioned(
            bottom: screensize.height * 0.05,
            left: screensize.width * 0.1,
            child: ElevatedButton(
                onPressed: () {
                  context.read<appNavigation>().setfrontpage('login/register');
                  context.read<PersonalMessages>().setmessages([]);
                  context.read<Messages>().makeItEmpty();
                  context.read<PersonalMessages>().setFriend("");
                  context.read<UserDetails>().setusername('');
                },
                child: Icon(Icons.logout))),
        Positioned(
            bottom: 0,
            child: MouseRegion(
                    onEnter: getNew,
                    onExit: (PointerExitEvent e) {
                      setState() {
                        get_new_old_flag = true;
                      }
                    },
                    child: ElevatedButton(onPressed: (){}, child:Icon(Icons.arrow_downward)))),
        Positioned(
            top: 0,
            child: MouseRegion(
                    onEnter: getOld,
                    onExit: (PointerExitEvent e) {
                      setState() {
                        get_new_old_flag = true;
                      }
                    },
                    child: ElevatedButton(onPressed: (){}, child: Icon(Icons.arrow_upward))))
      ],
    );
  }
}

class Message extends StatefulWidget {
  final String messageId;
  final bool preview;
  final chatroot;
  Message(
      {required this.messageId,
      required this.preview,
      required bool this.chatroot,
      required Key key})
      : super(key: key);
  @override
  State<Message> createState() => _MessageState();
}

class _MessageState extends State<Message> {
  String messageid = "";
  String username = "";
  String token="";
  bool preview = false;
  bool chatroot = false;
  Map<String, dynamic> message = {};
  Uint8List photobytes = Uint8List.fromList([0, 0, 0, 0]);

  bool compareUint8Lists(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void setmessage(Map<String, dynamic> msg) {
    setState(() {
      message = msg;
    });
  }

  void setmessageid(String id) {
    setState(() {
      messageid = id;
    });
  }

  void setusername(String name) {
    setState(() {
      username = name;
    });
  }

  @override
  void initState() {
    super.initState();
    setmessageid(widget.messageId);
    preview = widget.preview;
    chatroot = widget.chatroot;
    BuildContext ctx = navigatorKey.currentContext as BuildContext;
    setusername(ctx.watch<UserDetails>().userdetails['username'] as String);
    setState(() {
      token=ctx.watch<UserDetails>().token;
    });
    List<dynamic> messages = ctx.watch<Messages>().messages;
    List<dynamic> personal_messages =
        ctx.watch<PersonalMessages>().personal_messages;
    for (int i = 0; i < messages.length; i++) {
      if (messages[i]['messageId'].toString() == messageid) {
        setmessage(messages[i]);
      }
    }
    for (int i = 0; i < personal_messages.length; i++) {
      if (personal_messages[i]['messageId'].toString() == messageid) {
        setmessage(personal_messages[i]);
      }
    }

    if (message['msgcontent']['type'] != 'text') {
      http
          .get(Uri.parse(
              'http://${endpoint_with_port}/messages/image?image_name=${message['msgcontent']['photourl']}'),headers: {
        'Authorization': 'Bearer $token'
      })
          .then((response) {
        if (mounted) {
          setState(() {
            photobytes = response.bodyBytes;
          });
        }
      });
    }
    var nmsg = message;
    String datestring = nmsg['time'];
    DateTime datetime = DateTime.parse(datestring);
    DateTime current_time = DateTime.now();
    Duration diff = current_time.difference(datetime);
    String humantimediff = '';
    if (diff.inDays > 0) {
      humantimediff = diff.inDays.toString() + " days ";
    }
    if (diff.inHours > 0) {
      humantimediff =
          humantimediff + (diff.inHours % 24).toString() + " hours ";
    }
    if (diff.inMinutes > 0) {
      humantimediff =
          humantimediff + (diff.inMinutes % 60).toString() + " minutes ";
    }
    if (diff.inSeconds > 0) {
      humantimediff =
          humantimediff + (diff.inSeconds % 60).toString() + " seconds ago ";
    }
    if (diff.inDays == 0 &&
        diff.inHours == 0 &&
        diff.inMinutes == 0 &&
        diff.inSeconds > 0) {
      humantimediff = "just moments ago";
    }
    nmsg['chatformattime'] = humantimediff;
    setState(() {
      message = nmsg;
    });
  }

  @override
  Widget build(BuildContext context) {
    var screensize = MediaQuery.of(context).size;
    return Container(
      alignment: chatroot == false
          ? message['sender']['username'] == username
              ? Alignment.centerRight
              : Alignment.centerLeft
          : Alignment.center,
      child: Column(
        crossAxisAlignment:
            chatroot || message['sender']['username'] == username
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
        children: [
          chatroot
              ? (message['sender']['username'] == username
                  ? Text("${message['receiver']['username']}",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20))
                  : Text(message['sender']['username'],
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20)))
              : Text(""),
          chatroot == false
              ? (message['sender']['username'] == username
                  ? Text(
                      "You said: ",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    )
                  : Text("${message['sender']['username']} said: ",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20)))
              : Text(""),
          message['msgcontent']['type'] == 'text'
              ? Text(message['msgcontent']['text'])
              : preview
                  ? const Text("(image)")
                  : Container(
                      width: screensize.width * 0.3,
                      child: compareUint8Lists(
                              photobytes, Uint8List.fromList([0, 0, 0, 0]))
                          ? Text("")
                          : Image.memory(
                              photobytes,
                              fit: BoxFit.cover,
                            )),
          Text(message['chatformattime']),
        ],
      ),
    );
  }
}
