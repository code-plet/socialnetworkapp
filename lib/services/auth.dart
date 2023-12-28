import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:socialnetworkapp/models/local_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleAuthProvider _googleProvider = GoogleAuthProvider();
  final UserFireStore = FirebaseFirestore.instance.collection('users');

  //Convert Firebase User to native User
  LocalUser? _userFromFirebaseUser(User? user) {
    if (user == null) return null;
    return LocalUser(
        uid: user.uid,
        displayName: user.displayName,
        photoURL: user.photoURL.toString());
  }

  void saveUserData(User user) async {
    try {
      final convertedUser = _userFromFirebaseUser(user);
      await UserFireStore.doc(convertedUser!.uid).set(convertedUser.toJson());
    } catch (e) {
      print(e.toString());
    }
  }

  LocalUser? getCurrentUser() {
    dynamic user = _auth.currentUser;
    if (user is User) {
      return _userFromFirebaseUser(user);
    } else {
      return null;
    }
  }

  User? getFirebaseUser() {
    return _auth.currentUser;
  }

  //Establish auth stream from Firebase Auth
  Stream<LocalUser?> get user {
    return _auth.userChanges().map((User? user) => _userFromFirebaseUser(user));
  }

  // sign in anonymously
  Future signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      if (result.user == null) return null;

      User user = result.user!;
      saveUserData(user);
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // sign in with email and password
  Future signInWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (result.user != null) {
        saveUserData(result.user!);
      }
      return _userFromFirebaseUser(result.user);
    } catch (e) {
      return e.toString();
    }
  }

  // register with email and password
  Future createUserWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return _userFromFirebaseUser(result.user);
    } catch (e) {
      return e.toString();
    }
  }

  //Sign in with Google Account
  Future signInWithGoogle() async {
    try {
      UserCredential result = await _auth.signInWithProvider(_googleProvider);
      if (result.user != null) {
        saveUserData(result.user!);
      }
      return _userFromFirebaseUser(result.user);
    } catch (e) {
      return e.toString();
    }
  }

  // sign out
  Future logOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }
}
