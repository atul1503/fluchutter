import 'package:flutter/material.dart';

class Messages with ChangeNotifier {
  List<Map<String,dynamic>> messages=[];

  void addMessage(Map<String,dynamic> message){
    messages.add(message);
    notifyListeners();
  }

  void makeItEmpty(){
    messages=[];
    notifyListeners();
  }
}