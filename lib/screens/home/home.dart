import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socialnetworkapp/services/auth.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {

    final _auth = AuthService();

    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Social",
            style: GoogleFonts.dancingScript(
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: 40
              )
            )
          ),
          backgroundColor: Colors.blue[500],
          actions: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              child: ElevatedButton(
                  onPressed: () async {
                    await _auth.logOut();
                  },
                  child: Text(
                    "Log out",
                    style: TextStyle(
                      color: Colors.blue[300]
                    ),
                  ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
