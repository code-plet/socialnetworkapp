import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socialnetworkapp/services/auth.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  @override
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  String email = "";
  String password = "";
  String confirmPwd = "";

  String error = "";

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Container(
          margin: EdgeInsets.symmetric(vertical: 0, horizontal: 45),
          child: Text(
            'Sign up to Social',
            style: TextStyle(color: Colors.white),
          ),
        ),
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
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 40),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10)),
                  child: TextFormField(
                    validator: (val) {
                      return (val == null || val.isEmpty)
                          ? "Please enter an email"
                          : null;
                    },
                    decoration: InputDecoration(
                        icon: Icon(Icons.person), labelText: "Email"),
                    onChanged: (val) {
                      setState(() => email = val);
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10)),
                  child: TextFormField(
                    validator: (val) {
                      return (val == null || val.isEmpty)
                          ? "Please enter an password"
                          : val.length < 6
                              ? "Password should be at least 6 characters"
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
                SizedBox(
                  height: 20,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10)),
                  child: TextFormField(
                    validator: (val) {
                      return (val == null || val.isEmpty)
                          ? "Please enter an email"
                          : val != password
                              ? "Please write identical passwords"
                              : null;
                    },
                    decoration: const InputDecoration(
                        icon: Icon(Icons.lock), labelText: "Confirm password"),
                    obscureText: true,
                    onChanged: (val) {
                      setState(() => confirmPwd = val);
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
                    SizedBox(
                      height: 20,
                    )
                  ]),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 100),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                    onPressed: () async {
                      setState(() => error = "");
                      if (_formKey.currentState!.validate()) {
                        dynamic result =
                            await _auth.createUserWithEmailAndPassword(
                                email: email, password: password);
                        if (result is String) {
                          setState(() => error = result);
                        }
                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      "Register",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    )),
              ],
            ),
          ),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text(
            "Already have an account?",
            style: TextStyle(),
          ),
          TextButton(
            child: const Text(
              "Sign in",
              style: TextStyle(
                  color: Colors.blue, decoration: TextDecoration.underline),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ]),
        const SizedBox(
          height: 20,
        ),
      ]),
    );
  }
}
