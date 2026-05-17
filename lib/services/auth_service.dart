import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final FirebaseFirestore
      _firestore =
      FirebaseFirestore.instance;

  User? get currentUser =>
      _auth.currentUser;

  // ================= REGISTER =================
  Future<String> register({
    required String name,
    required String email,
    required String password,
  }) async {

    try {
      UserCredential
          userCredential =
          await _auth
              .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user =
          userCredential.user;

      if (user == null) {
        return "User creation failed";
      }

      // update display name
      await user.updateDisplayName(
        name,
      );

      // save firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set({

        'uid':
            user.uid,

        'name':
            name,

        'email':
            email,

        'isOnline':
            true,

        'lastSeen':
            Timestamp.now(),

        'activeChatRoom':
            null,

        'createdAt':
            Timestamp.now(),
      });

      return "success";

    } on FirebaseAuthException
        catch (e) {

      return e.message ??
          "Register failed";

    } catch (e) {

      return e.toString();
    }
  }

  // ================= LOGIN =================
  Future<String> login({
    required String email,
    required String password,
  }) async {

    try {

      UserCredential credential =
          await _auth
              .signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user =
          credential.user;

      if (user == null) {
        return "Login failed";
      }

      // update online status
      await updateOnlineStatus(
        true,
      );

      return "success";

    } on FirebaseAuthException
        catch (e) {

      return e.message ??
          "Login failed";

    } catch (e) {

      return e.toString();
    }
  }

  // ================= ONLINE STATUS =================
  Future<void>
  updateOnlineStatus(
    bool isOnline,
  ) async {

    final user =
        _auth.currentUser;

    if (user == null) {
      return;
    }

    try {

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set({

        'uid':
            user.uid,

        'name':
            user.displayName ??
                'User',

        'email':
            user.email,

        'isOnline':
            isOnline,

        'lastSeen':
            Timestamp.now(),

      }, SetOptions(
        merge: true,
      ));

    } catch (e) {

      print(
        "update status error: $e",
      );
    }
  }

  // ================= LOGOUT =================
  Future<void> logout()
  async {

    try {

      await updateOnlineStatus(
        false,
      );

      await _auth.signOut();

    } catch (e) {

      print(
        "logout error: $e",
      );
    }
  }
}