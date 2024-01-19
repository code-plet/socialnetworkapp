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

    return Scaffold(
      appBar: AppBar(
        title: const Center(
            child: Text(
          "Create new profile",
          style: TextStyle(color: Colors.white),
        )),
        backgroundColor: Colors.blue[500],
      ),
      body: Column(children: [
        SizedBox(
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
                  onPressed: () => _selectImage(context),
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
        SizedBox(
          height: 16.0,
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Save information",
                style: TextStyle(color: Colors.white, fontSize: 14),
              )
            ],
          ),
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              dynamic user = _auth.getCurrentUser();
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
        ),
      ]),
    );
  }
}
