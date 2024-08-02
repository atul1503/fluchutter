
import 'package:flutter/widgets.dart';

class UserDetails with ChangeNotifier {
  Map<String,String> _state={
    'username': '',
    'Cookie': ''
  };

  Map<String,String> get userdetails => _state;

  void setusername(String newusername){
    _state['username']=newusername;
    notifyListeners();
  }

  void setcookie(String cookie){
    _state['Cookie']=cookie;
    notifyListeners();
  }
  
}
