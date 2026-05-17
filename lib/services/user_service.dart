import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {

  final FirebaseFirestore
      _firestore =
      FirebaseFirestore.instance;

  Stream<QuerySnapshot>
      getUsers() {

    return _firestore
        .collection('users')
        .snapshots();
  }
}