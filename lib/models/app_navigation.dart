import 'package:flutter/material.dart';

class appNavigation with ChangeNotifier {
  Map<String,String> _nav={
    'frontpage': 'login/register'
  };

  Map<String,String> get nav => _nav;
  void setfrontpage(String pagename){
      _nav['frontpage']=pagename;
  }
}