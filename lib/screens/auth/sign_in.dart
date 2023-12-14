import 'package:flutter/material.dart';
import 'package:socialnetworkapp/services/auth.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  @override

  final AuthService _auth = AuthService();

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        title: Center(child: Text('Sign in to Social')),
        backgroundColor: Colors.blue[500],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: ElevatedButton(
          child: Text('Sign in anonymously'),
          onPressed: () async {
            dynamic result = await _auth.signInAnon();
            if(result == null) print('error sign in');
            else print('signed in');
            print(result);
          },
        ),
      ),
    );
  }
}
