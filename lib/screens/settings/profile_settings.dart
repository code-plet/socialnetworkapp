import 'dart:typed_data';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/local_user.dart';
import '../../utils/image_picker.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key});

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {

  final _formKey = GlobalKey<FormState>();

  Uint8List? photo;
  _selectImage(BuildContext parentContext) async {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Change your avatar'),
          children: <Widget>[
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Take a photo'),
                onPressed: () async {
                  Navigator.pop(context);
                  Uint8List? file = await pickImage(ImageSource.camera);
                  setState(() {
                    photo = file;
                  });
                }),
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Choose from Gallery'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List? file = await pickImage(ImageSource.gallery);
                  setState(() {
                    photo = file;
                  });
                }),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<LocalUser?>(context);
    String displayName = user?.displayName ?? "";
    String photoUrl = user?.photoURL ?? "";
    String phone = user?.phoneNumber ?? "";
    String email = user?.email ?? "";


    Uint8List? photo;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Container(
          margin: EdgeInsets.symmetric(vertical: 0, horizontal: 45),
          child: Text(
            'Edit Profile',
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.blue[500],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 15,),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.blue),
                    borderRadius: BorderRadius.circular(100)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundImage: photo != null
                        ? MemoryImage(photo)
                        : photoUrl.isNotEmpty
                        ? NetworkImage(
                      user!.photoURL.toString(),
                    )
                        : const AssetImage("assets/images/empty_avatar.png")
                    as ImageProvider<Object>,
                    radius: 60,
                  ),
                ),
              ),
              TextButton(
                  onPressed: () async {
                    _selectImage(context);
                  },
                  child: const Text('Change your profile picture')),
              SizedBox(height: 40),
              Row(
                children: [
                  SizedBox(width: 10,),
                  Text("Name", style: TextStyle(fontSize: 17),),
                  SizedBox(width: 30,),
                  Container(
                    width: 300,
                    child: TextFormField(
                      validator: (val) {
                        return (val == null || val.isEmpty)
                            ? "please enter your username"
                            : null;
                      },
                      initialValue: displayName,
                      onChanged: (val) {
                        displayName = val;
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(borderSide: BorderSide(width: 2)),
                        hintText: 'Display name',
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20,),
              Row(
                children: [
                  SizedBox(width: 10,),
                  Text("Email", style: TextStyle(fontSize: 17),),
                  SizedBox(width: 30,),
                  Container(
                    width: 300,
                    child: TextFormField(
                      validator: (val) {
                        if(val == user?.email || EmailValidator.validate(val!)){
                          return null;
                        }
                        else return "PLease enter email with correct format";
                      },
                      onChanged: (val) {
                        email = val;
                      },
                      initialValue: email,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(borderSide: BorderSide(width: 2)),
                        hintText: 'Display email (optional)',
                      ),
                    ),
                  ),
                ],
              ),
              //SizedBox(height: 20,),
              // Row(
              //   children: [
              //     SizedBox(width: 10,),
              //     Text("Phone", style: TextStyle(fontSize: 17),),
              //     SizedBox(width: 28,),
              //     Container(
              //       width: 300,
              //       child: TextFormField(
              //         validator: (val) {
              //           return null;
              //         },
              //         onChanged: (val) {
              //           phone = val;
              //         },
              //         initialValue: phone,
              //         decoration: const InputDecoration(
              //           border: OutlineInputBorder(borderSide: BorderSide(width: 2)),
              //           hintText: 'Display phone number (optional)',
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              SizedBox(height: 40,),
              ElevatedButton(
                onPressed: () {
                  if(_formKey.currentState!.validate()){
                    try{
                      if(displayName != user?.displayName) user?.changeDisplayName(displayName);
                      if(email != user?.email) user?.changeEmail(email);
                    } catch(e) {
                      throw(e);
                    }
                  }
                },
                  child: Text("Done", style: TextStyle(fontSize: 18, color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  fixedSize: Size(200, 20),
                ),
                
              )
            ],
          ),
        ),
      ),
    );
  }
}
