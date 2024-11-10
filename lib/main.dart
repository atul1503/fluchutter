import 'package:fluchutter/components/chat.dart';
import 'package:fluchutter/components/login.dart';
import 'package:fluchutter/components/new_chat.dart';
import 'package:fluchutter/components/one_to_one_chat.dart';
import 'package:fluchutter/models/app_navigation.dart';
import 'package:fluchutter/models/messages.dart';
import 'package:fluchutter/models/personal_messages.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluchutter/models/user_details.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => UserDetails()),
      ChangeNotifierProvider(create: (context) => appNavigation()),
      ChangeNotifierProvider(create: (context) => Messages()),
      ChangeNotifierProvider(create: (context) => PersonalMessages())
    ], child: MaterialApp(home: FrontPage(), navigatorKey: navigatorKey));
  }
}

class FrontPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Builder(builder: (context) {
      appNavigation nav = context.watch<appNavigation>();
      if (nav.nav['frontpage'] == 'login/register') {
        return Login();
      } else if (nav.nav['frontpage'] == 'chat') {
        return Chat();
      } else if (nav.nav['frontpage'] == 'new_chat') {
        return NewChat();
      }
      else if (nav.nav['frontpage'] == 'personalChat') {
          return OneToOneChat();
      }
      else {
        return Login();
      }
    }));
  }
}
