import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socialnetworkapp/utils/snackbar.dart';
import '../../models/local_user.dart';
import '../../utils/image_picker.dart';

class ProfileSettings extends StatefulWidget {
  final String userId;
  const ProfileSettings({super.key, required this.userId});

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  var formKey = GlobalKey<FormState>();
  LocalUser? user;
  String displayName = "";
  String phone = "";
  Uint8List? file0;

  getUserInfo() async {
    try {
      final currentUser = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();
      final data = currentUser.data();

      setState(() {
        user = LocalUser.fromSnap(currentUser);
        phone = data?["phoneNumber"];
        displayName = data?["displayName"];
        formKey = GlobalKey<FormState>();
      });
    } catch (e) {
      if (context.mounted) {
        showSnackBar(
          context,
          'Can not get userInfo.',
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  selectImage(BuildContext parentContext) async {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Choose your post image'),
          children: <Widget>[
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Take a photo'),
                onPressed: () async {
                  Navigator.pop(context);
                  Uint8List? file = await pickImage(ImageSource.camera);
                  setState(() {
                    file0 = file;
                  });
                }),
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Choose from Gallery'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List? file = await pickImage(ImageSource.gallery);
                  setState(() {
                    file0 = file;
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
    return Scaffold(
      appBar: AppBar(
        title: Container(
          margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 45),
          child: const Text(
            'Edit Profile',
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.blue[500],
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 15,
              ),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.blue),
                    borderRadius: BorderRadius.circular(100)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundImage: file0 != null
                        ? MemoryImage(file0!)
                        : user?.photoURL != null && user!.photoURL.isNotEmpty
                            ? NetworkImage(
                                user!.photoURL.toString(),
                              )
                            : const AssetImage("assets/images/empty_avatar.png")
                                as ImageProvider<Object>,
                    radius: 50,
                  ),
                ),
              ),
              TextButton(
                  onPressed: () => selectImage(context),
                  child: const Text('Change your profile picture')),
              const SizedBox(height: 40),
              Row(
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  const Text(
                    "Email",
                    style: TextStyle(fontSize: 17),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  SizedBox(
                    width: 300,
                    child: Text(user?.email ?? ""),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  const Text(
                    "Name",
                    style: TextStyle(fontSize: 17),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      validator: (val) {
                        return (val == null || val.isEmpty)
                            ? "Please enter your fullName"
                            : null;
                      },
                      initialValue: displayName,
                      onChanged: (val) {
                        displayName = val;
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: BorderSide(width: 2)),
                        hintText: 'Display name',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  const Text(
                    "Phone",
                    style: TextStyle(fontSize: 17),
                  ),
                  const SizedBox(
                    width: 28,
                  ),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      validator: (val) {
                        if (val?.length != 10) {
                          return "PhoneNumber must contains 10 digit";
                        }
                        return null;
                      },
                      onChanged: (val) {
                        phone = val;
                      },
                      initialValue: phone,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: BorderSide(width: 2)),
                        hintText: 'Display phone number (optional)',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 40,
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    try {
                      bool change = false;

                      if (displayName != user?.displayName) {
                        await user?.changeDisplayName(displayName);
                        change = true;
                      }

                      if (phone != user?.phoneNumber) {
                        await user?.changePhone(phone);
                        change = true;
                      }

                      if (file0 != null) {
                        await user?.changePhotoUrl(file0!);
                        change = true;
                      }

                      if (context.mounted && change) {
                        showSnackBar(
                          context,
                          'Change information successfully',
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        showSnackBar(
                          context,
                          'Something wrong.',
                        );
                      }
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  fixedSize: const Size(200, 20),
                ),
                child: const Text(
                  "Done",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
