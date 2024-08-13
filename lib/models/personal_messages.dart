import 'package:flutter/foundation.dart';

class PersonalMessages with ChangeNotifier {
  List<dynamic> _messages=[];
  
  List<dynamic> get personal_messages => _messages;

  String friend='';

  void setFriend(String _friend){
    friend=_friend;
    notifyListeners();
  }

  void addMessage(Map<String,String> msg){
    _messages.add(msg);
    notifyListeners();
  }

  void setmessages(List<dynamic> msgs){
    _messages=msgs;
    notifyListeners();
  }

  void delete_message_by_id(String id){
      _messages.removeWhere((msg)=> msg['messageId'].toString()==id);
      notifyListeners();
  }
}