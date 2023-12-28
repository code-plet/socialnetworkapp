import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:socialnetworkapp/screens/auth/sign_up.dart';
import 'package:socialnetworkapp/services/auth.dart';

import '../../models/local_user.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  @override
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  String email = "";
  String password = "";

  String error = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Center(
            child: Text(
          'Sign in to Social',
          style: TextStyle(color: Colors.white),
        )),
        backgroundColor: Colors.blue[500],
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Text(
          "Social",
          style: GoogleFonts.dancingScript(
            textStyle: TextStyle(color: Colors.blue[500], fontSize: 100),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 40),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10)),
                  child: TextFormField(
                    validator: (val) {
                      return (val == null || val.isEmpty)
                          ? "Please enter an email"
                          : null;
                    },
                    decoration: const InputDecoration(
                        icon: Icon(Icons.person), labelText: "Email"),
                    onChanged: (val) {
                      setState(() => email = val);
                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10)),
                  child: TextFormField(
                    validator: (val) {
                      return (val == null || val.isEmpty)
                          ? "Please enter an password"
                          : null;
                    },
                    decoration: const InputDecoration(
                        icon: Icon(Icons.lock), labelText: "Password"),
                    obscureText: true,
                    onChanged: (val) {
                      setState(() => password = val);
                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                if (error.isNotEmpty)
                  Column(children: [
                    Text(
                      error,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(
                      height: 20,
                    )
                  ]),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: 0, horizontal: 100),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                    onPressed: () async {
                      setState(() => error = "");
                      if (_formKey.currentState!.validate()) {
                        dynamic result = await _auth.signInWithEmailAndPassword(
                            email: email, password: password);
                        if (result is String) {
                          setState(() => error = result);
                        }
                        if (result is LocalUser) {}
                      }
                    },
                    child: const Text(
                      "Sign in",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    )),
              ],
            ),
          ),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text(
            "Don't have an account?",
            style: TextStyle(),
          ),
          TextButton(
            child: const Text(
              "Sign up",
              style: TextStyle(
                  color: Colors.blue, decoration: TextDecoration.underline),
            ),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const SignUp()));
            },
          ),
        ]),
        Row(children: <Widget>[
          Expanded(
            child: Container(
                margin: const EdgeInsets.only(left: 10.0, right: 20.0),
                child: const Divider(
                  color: Colors.black,
                  height: 36,
                )),
          ),
          const Text("OR"),
          Expanded(
            child: Container(
                margin: const EdgeInsets.only(left: 20.0, right: 10.0),
                child: const Divider(
                  color: Colors.black,
                  height: 36,
                )),
          ),
        ]),
        SignInButton(Buttons.google, text: "Sign up with Google",
            onPressed: () {
          _auth.signInWithGoogle();
        }),
      ]),
    );
  }
}
