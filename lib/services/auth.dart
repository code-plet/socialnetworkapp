import 'package:firebase_auth/firebase_auth.dart';
import 'package:socialnetworkapp/models/local_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Convert Firebase User to native User
  LocalUser? _userFromFirebaseUser(User? user) {
    if (user == null) return null;
    return LocalUser(uid: user.uid);
  }

  //Establish auth stream from Firebase Auth
  Stream<LocalUser?> get user {
    return _auth
        .authStateChanges()
        .map((User? user) => _userFromFirebaseUser(user));
  }

  // sign in anonymously
  Future signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      if (result.user == null) return null;

      User? user = result.user;
      return _userFromFirebaseUser(user!);
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

  // sign out
  Future logOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }
}
