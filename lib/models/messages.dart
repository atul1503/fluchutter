import 'package:flutter/material.dart';

class Messages with ChangeNotifier {
  List<dynamic> messages=[];

  void addMessage(Map<String,dynamic> message){
    messages.add(message);
    notifyListeners();
  }

  void moveMessages(List<dynamic> _messages){
    messages=_messages;
    notifyListeners();
  } 

  void makeItEmpty(){
    messages=[];
    notifyListeners();
  }
}