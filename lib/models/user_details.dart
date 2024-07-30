
import 'package:flutter/widgets.dart';

class UserDetails with ChangeNotifier {
  Map<String,String> _state={
    'username': ''
  };

  Map<String,String> get userdetails => _state;

  void setusername(String newusername){
    _state['username']=newusername;
  }
  
}
