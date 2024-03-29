import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:socialnetworkapp/models/local_user.dart';
import 'package:socialnetworkapp/services/post.dart';
import 'package:socialnetworkapp/utils/image_picker.dart';
import 'package:socialnetworkapp/utils/snackbar.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  Uint8List? _file;
  bool isLoading = false;
  String content = "";

  _selectImage(BuildContext parentContext) async {
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
                    _file = file;
                  });
                }),
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Choose from Gallery'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List? file = await pickImage(ImageSource.gallery);
                  setState(() {
                    _file = file;
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

  void createNewPost(LocalUser? user) async {
    final String? uid = user?.uid;
    final String? name = user?.displayName;
    final String profilePic = user?.photoURL ?? '';

    if (uid == null || name == null) {
      showSnackBar(
        context,
        'Can not read user information',
      );
      return;
    }

    setState(() {
      isLoading = true;
    });
    // start the loading
    try {
      // upload to storage and db
      String res = await PostService().uploadPost(
        content,
        _file,
        uid,
        name,
        profilePic,
      );
      if (res == "success") {
        setState(() {
          isLoading = false;
        });
        if (context.mounted) {
          showSnackBar(
            context,
            'Posted!',
          );
        }
        clear();
      } else {
        if (context.mounted) {
          showSnackBar(context, res);
        }
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      if (context.mounted) {
        showSnackBar(
          context,
          err.toString(),
        );
      }
    }
  }

  void clear() {
    setState(() {
      _file = null;
      content = "";
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<LocalUser?>(context);
    final profileImg = user?.photoURL != null
        ? NetworkImage(user!.photoURL)
        : const AssetImage('assets/image/empty_avatar.png')
            as ImageProvider<Object>;

    return Column(
      children: <Widget>[
        isLoading
            ? const LinearProgressIndicator()
            : const Padding(padding: EdgeInsets.only(top: 0.0)),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 40,
              width: 40,
              child: CircleAvatar(
                backgroundImage: profileImg,
              ),
            ),
            const SizedBox(width: 20),
            SizedBox(
              width: MediaQuery.of(context).size.width - 60,
              child: TextField(
                onChanged: (value) => {
                  setState(() {
                    content = value;
                  })
                },
                decoration: const InputDecoration(
                    hintText: "Write a caption...", border: InputBorder.none),
                maxLines: 8,
              ),
            ),
          ],
        ),
        const Divider(),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: content.isEmpty && _file == null
                  ? null
                  : () => createNewPost(user),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Text(
                    "Upload post",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: const BorderSide(width: 1.0, color: Colors.blue)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.upload,
                    color: Colors.blue,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Text(
                    "Upload image",
                    style: TextStyle(color: Colors.blue, fontSize: 14),
                  )
                ],
              ),
              onPressed: () => _selectImage(context),
            )
          ],
        ),
        const SizedBox(height: 16),
        _file != null
            ? Center(
                child: SizedBox(
                width: MediaQuery.of(context).size.width - 60,
                child: AspectRatio(
                  aspectRatio: 487 / 451,
                  child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                      fit: BoxFit.fill,
                      alignment: FractionalOffset.topCenter,
                      image: MemoryImage(_file!),
                    )),
                  ),
                ),
              ))
            : Container(),
      ],
    );
  }
}
