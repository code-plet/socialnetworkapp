import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:socialnetworkapp/services/auth.dart';

class LocalUser{

  String uid;
  String? displayName;
  String photoURL;

  final AuthService _auth = AuthService();

  LocalUser({required this.uid, required this.displayName, required this.photoURL});

  Future<String?> changeDisplayName(String displayName) async {
   dynamic user = _auth.getFirebaseUser();
   if(user == null) return null;

   if(user is User){
     try{
       await user.updateDisplayName(displayName);
       this.displayName = displayName;
     } catch(e) {
       return e.toString();
     }
     return "Successfully changed userName";
   }
  }

  Future<String?> changePhotoUrl(String photoPath) async {

    Reference refRoot = FirebaseStorage.instance.ref();
    Reference imagesDirRef = refRoot.child('images');

    Reference referenceImage = imagesDirRef.child(DateTime.now().microsecondsSinceEpoch.toString());
    try{
      await referenceImage.putFile(File(photoPath));
    } catch(e){
      print(e.toString());
    }

    String photoUrl = await referenceImage.getDownloadURL();

    dynamic user = _auth.getFirebaseUser();
    if(user == null) return null;

    if(user is User){
      try{
        await user.updatePhotoURL(photoUrl);
        this.photoURL = photoUrl;
      } catch(e) {
        return e.toString();
      }
      return "Successfully changed photoURL";
    }
  }
}