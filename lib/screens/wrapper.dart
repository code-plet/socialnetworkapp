import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialnetworkapp/models/local_user.dart';
import 'package:socialnetworkapp/screens/auth/auth.dart';
import 'package:socialnetworkapp/screens/home/home.dart';

class Wrapper extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<LocalUser?>(context);
    print(user.toString());

    if(user == null) return Auth();
    else return Home();
  }
}
