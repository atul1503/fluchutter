
import 'package:flutter/widgets.dart';

class UserDetails with ChangeNotifier {
  Map<String,String> _state={
    'username': '',
    'JwtToken': ''
  };

  Map<String,String> get userdetails => _state;

  String get token => _state['JwtToken'] ?? '';

  void setusername(String newusername){
    _state['username']=newusername;
    notifyListeners();
  }

  void setToken(String token){
    _state['JwtToken']=token;
    notifyListeners();
  }
  
}
