import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socialnetworkapp/models/local_user.dart';
import 'package:socialnetworkapp/screens/home/home.dart';
import 'package:socialnetworkapp/services/auth.dart';

class CreateProfile extends StatefulWidget {
  const CreateProfile({super.key});

  @override
  State<CreateProfile> createState() => _CreateProfileState();
}

class _CreateProfileState extends State<CreateProfile> {

  final AuthService _auth = AuthService();

  final _formKey = GlobalKey<FormState>();

  String displayName = "";

  dynamic image = AssetImage("assets/images/empty_avatar.png");

  late XFile photo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Create new profile", style: TextStyle(color: Colors.white),)),
        backgroundColor: Colors.blue[500],
      ),
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 40,),
                CircleAvatar(
                  backgroundImage: image,
                  radius: 60,
                ),
                TextButton(
                    onPressed: () async {
                      bool isCamera = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: Padding(
                              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                    },
                                    child: Row(children: [
                                      Icon(Icons.camera),
                                      SizedBox(width: 10,),
                                      Text("Camera"),
                                    ],),
                                  ),
                                  SizedBox(width: 8,),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                    child: Row(children: [
                                      Icon(Icons.browse_gallery),
                                      SizedBox(width: 10,),
                                      Text("gallery"),
                                    ]),
                                  ),
                                ],
                              ),
                            ),
                          ));
                      final ImagePicker picker = ImagePicker();
                      if(isCamera) {
                        final XFile? photo = await picker.pickImage(source: ImageSource.camera);

                        if (photo != null) {
                          setState(() {
                            this.photo = photo;
                            this.image = FileImage(File(photo.path));
                          });
                        }

                      }
                      else {
                        final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                      }
                    },
                    child: Text('Change your profile picture')),
                SizedBox(height: 40,),
                Form(
                  key: _formKey,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 60),
                    child: Column(
                      children: [
                        TextFormField(
                          validator: (val) {
                            return (val == null || val.isEmpty) ? "please enter your username" : null;
                          },
                          onChanged: (val){
                            this.displayName = val;
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Display name',

                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Row(
              children: [
                TextButton(
                  onPressed: () async {
                    if(_formKey.currentState!.validate()){
                      dynamic user = await _auth.getCurrentUser();
                      if(user == null) throw Exception("Can't identify user");
                      if(user is LocalUser){
                        try{
                          await user.changeDisplayName(displayName);
                          await user.changePhotoUrl(photo.path);
                          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Home()), (route) => route == null);
                        } catch(e) {
                          print(e.toString());
                        }
                      }
                    }
                },
                  child: Text('Next >', style: TextStyle(color: Colors.blue),),
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 20)
                  ),
                ),
              ],
            ),
          ),
        ]
      ),
    );
  }
}
