import 'dart:convert';

import 'package:fluchutter/models/app_navigation.dart';
import 'package:fluchutter/models/user_details.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class Login extends StatefulWidget {

  @override
  State<Login> createState() => _LoginState();  
}

class _LoginState extends State<Login> {

  final TextEditingController username_controller=TextEditingController();
  final TextEditingController password_controller=TextEditingController();
  bool login_status=false;
  bool attempted_login=false;
  bool register_status=false;

  void attempt_login(BuildContext ctx) async {
    final String username=username_controller.text;
    final String password=password_controller.text;
    http.post(Uri.parse("http://localhost:8080/users/login"),headers: {
        'Content-Type': 'application/json',
        'username': username,
        'password': password,
      },
      )
    .then((response) async {
      if(response.statusCode==200){ 
            setState(() {
              login_status=true;
            });
            await Future.delayed(Duration(seconds: 3));
            ctx.read<UserDetails>().setusername(username);
            ctx.read<appNavigation>().setfrontpage("chat");
      }
      else{
        setState(() {
          login_status=false;
        });
        setState((){
      attempted_login=true;
    });
      }
    }
    
    );
  }

  void attempt_signup() {
    final String username=username_controller.text;
    final String password=password_controller.text;
    http.post(Uri.parse("http://localhost:8080/users/register"),headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
      'username': username,
      'password': password
    }))
    .then((response){
      if(response.statusCode==200){ 
            setState(() {
              register_status=true;
            });
      }
      else{
        setState(() {
          register_status=false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
        return Container(
          color: Colors.white,
          child: Column(children: 
          [
            TextField(
              decoration: InputDecoration(labelText: "Enter your username:" ),
              controller: username_controller,
            )
          , TextField(decoration: InputDecoration(labelText: "Enter your password"), controller: password_controller),
          ElevatedButton(onPressed: () {attempt_login(context);}, child: Text('Sign in')),
          ElevatedButton(onPressed: attempt_signup, child: Text('Sign up')),
          attempted_login?(login_status?Text("Login is a success!"):Text("Login has failed. Either credentials are wrong.")):Text("")
          ]),
        );
      }
}