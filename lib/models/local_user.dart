import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:socialnetworkapp/services/auth.dart';

class LocalUser {
  String uid;
  String? displayName;
  String photoURL;
  String? phoneNumber = "";
  String? email = "";

  final UserFireStore = FirebaseFirestore.instance.collection('users');
  final AuthService _auth = AuthService();

  LocalUser(
      {required this.uid, required this.displayName, required this.photoURL, this.email, this.phoneNumber});

  Future<String?> changeDisplayName(String displayName) async {
    dynamic user = _auth.getFirebaseUser();
    if (user == null) return null;

    if (user is User) {
      try {
        await user.updateDisplayName(displayName);
        await UserFireStore.doc(user.uid).update({"displayName": displayName});
        this.displayName = displayName;
      } catch (e) {
        return e.toString();
      }
      return "Successfully changed userName";
    }
  }

  Future<String?> changePhotoUrl(Uint8List photo) async {
    //not use dart:io https://stackoverflow.com/questions/54861467/unsupported-operation-namespace-while-using-dart-io-on-web
    Reference imgRef = FirebaseStorage.instance.ref().child('images');

    Reference referenceImage =
        imgRef.child(DateTime.now().microsecondsSinceEpoch.toString());
    try {
      await referenceImage.putData(photo);
    } catch (e) {
      print(e.toString());
    }

    String photoUrl = await referenceImage.getDownloadURL();

    dynamic user = _auth.getFirebaseUser();
    if (user == null) return null;

    if (user is User) {
      try {
        await user.updatePhotoURL(photoUrl);
        await UserFireStore.doc(user.uid).update({"photoURL": photoUrl});
      } catch (e) {
        return e.toString();
      }
      return "Successfully changed photoURL";
    }
  }
  
  Future<String?> changeEmail(String email) async{
    
    dynamic user = _auth.getFirebaseUser();
    if(user == null) return null;
    
    if(user is User){
      try{
        await user.updateEmail(email);
        await UserFireStore.doc(user.uid).update({"email": email});
        this.email = email;
      } catch(e) {
        return e.toString();
      }
      return "Successfully changed user email";
    }
  }

  Future<String?> changePhone(String phone) async{

    dynamic user = _auth.getFirebaseUser();
    if(user == null) return null;

    if(user is User){
      try{

        //await user.updatePhoneNumber();
        await UserFireStore.doc(user.uid).update({"email": email});
        this.email = email;
      } catch(e) {
        return e.toString();
      }
      return "Successfully changed user email";
    }
  }

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "displayName": displayName,
        "photoURL": photoURL,
      };

  static LocalUser fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return LocalUser(
        uid: snapshot["uid"],
        displayName: snapshot['displayName'],
        photoURL: snapshot['photoURL']);
  }
}
