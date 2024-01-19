import 'dart:typed_data';

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
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<LocalUser?>(context);
    String displayName = user?.displayName ?? "";
    String photoUrl = user?.photoURL ?? "";
    String phone = user?.phoneNumber ?? "";
    String email = user?.email ?? "";

    final formKey = GlobalKey<FormState>();

    Uint8List? photo;

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
                    backgroundImage: photo != null
                        ? MemoryImage(photo)
                        : photoUrl.isNotEmpty
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
                  onPressed: () async {
                    bool isCamera = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              content: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(true);
                                      },
                                      child: const Row(
                                        children: [
                                          Icon(Icons.camera),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text("Camera"),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                      child: const Row(children: [
                                        Icon(Icons.browse_gallery),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text("gallery"),
                                      ]),
                                    ),
                                  ],
                                ),
                              ),
                            ));

                    Uint8List file = await pickImage(
                        !isCamera ? ImageSource.gallery : ImageSource.camera);
                    setState(() {
                      photo = file;
                    });
                  },
                  child: const Text('Change your profile picture')),
              const SizedBox(height: 40),
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
                            ? "please enter your username"
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
                    "Email",
                    style: TextStyle(fontSize: 17),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      validator: (val) {
                        return null;
                      },
                      onChanged: (val) {
                        email = val;
                      },
                      initialValue: email,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: BorderSide(width: 2)),
                        hintText: 'Display email (optional)',
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
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    if (displayName != user?.displayName) {
                      user?.changeDisplayName(displayName);
                    }
                    if (email != user?.email) user?.changeEmail(email);
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
