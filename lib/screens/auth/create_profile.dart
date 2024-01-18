import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:socialnetworkapp/layouts/main_layout.dart';
import 'package:socialnetworkapp/models/local_user.dart';
import 'package:socialnetworkapp/services/auth.dart';
import 'package:socialnetworkapp/utils/image_picker.dart';

class CreateProfile extends StatefulWidget {
  const CreateProfile({super.key});

  @override
  State<CreateProfile> createState() => _CreateProfileState();
}

class _CreateProfileState extends State<CreateProfile> {
  final AuthService _auth = AuthService();

  final _formKey = GlobalKey<FormState>();
  Uint8List? photo;

  dynamic image = const AssetImage("assets/images/empty_avatar.png");

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<LocalUser?>(context);
    String displayName = user?.displayName ?? "";
    String photoUrl = user?.photoURL ?? "";

    return Scaffold(
      appBar: AppBar(
        title: const Center(
            child: Text(
          "Create new profile",
          style: TextStyle(color: Colors.white),
        )),
        backgroundColor: Colors.blue[500],
      ),
      body: Stack(children: [
        Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 40,
              ),
              CircleAvatar(
                backgroundImage: photo != null
                    ? MemoryImage(photo!)
                    : photoUrl.isNotEmpty
                        ? NetworkImage(
                            user!.photoURL.toString(),
                          )
                        : const AssetImage("assets/images/empty_avatar.png")
                            as ImageProvider<Object>,
                radius: 60,
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
              const SizedBox(
                height: 40,
              ),
              Form(
                key: _formKey,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 60),
                  child: Column(
                    children: [
                      TextFormField(
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
                  if (_formKey.currentState!.validate()) {
                    dynamic user = await _auth.getCurrentUser();
                    if (user == null) throw Exception("Can't identify user");
                    if (user is LocalUser) {
                      try {
                        await user.changeDisplayName(displayName);
                        user.displayName = displayName;
                        if (photo != null) {
                          await user.changePhotoUrl(photo!);
                          user.photoURL = photoUrl;
                        }
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => const MainLayout()),
                              (route) => route == null);
                        }
                      } catch (e) {
                        print(e.toString());
                      }
                    }
                  }
                },
                style: TextButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 20)),
                child: const Text(
                  'Next >',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
