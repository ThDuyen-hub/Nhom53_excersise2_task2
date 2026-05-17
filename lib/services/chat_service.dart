import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class ChatService {

  final FirebaseFirestore
      _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // generate room id
  String getChatRoomId(
    String user1,
    String user2,
  ) {

    List<String> ids = [
      user1,
      user2,
    ];

    ids.sort();

    return ids.join("_");
  }

  // send private message
  Future<void> sendMessage({
    required String receiverId,
    required String message,
  }) async {

    final currentUser =
        _auth.currentUser;

    if (currentUser == null ||
        message.trim().isEmpty) {
      return;
    }

    String roomId =
        getChatRoomId(
      currentUser.uid,
      receiverId,
    );

    // save message
    await _firestore
        .collection(
            'chat_rooms')
        .doc(roomId)
        .collection(
            'messages')
        .add({

      'message':
          message.trim(),

      'senderId':
          currentUser.uid,

      'receiverId':
          receiverId,

      'senderName':
          currentUser
                  .displayName ??
              'User',

      'timestamp':
          Timestamp.now(),

        'isSeen': false,
    });

    // get old unread
    final roomDoc =
        await _firestore
            .collection(
                'chat_rooms')
            .doc(roomId)
            .get();

    Map<String, dynamic>
        unreadCounts = {};

    if (roomDoc.exists &&
        roomDoc.data()?[
                'unreadCounts'] !=
            null) {

      unreadCounts =
          Map<String, dynamic>
              .from(
        roomDoc.data()![
            'unreadCounts'],
      );
    }
    
    // check receiver opening chat?
    final receiverDoc =
        await _firestore
            .collection('users')
            .doc(receiverId)
            .get();

    String? activeRoom =
        receiverDoc
            .data()?[
                'activeChatRoom'];

    bool isOpeningChat =
        activeRoom ==
            roomId;

    // receiver đang mở chat
    if (isOpeningChat) {

      unreadCounts[
          receiverId] = 0;

    } else {

      unreadCounts[
          receiverId] =
          (unreadCounts[
                  receiverId] ??
              0) +
          1;
    }

    // sender always 0
    unreadCounts[
        currentUser.uid] = 0;

    await _firestore
        .collection(
            'chat_rooms')
        .doc(roomId)
        .set({

      'users': [
        currentUser.uid,
        receiverId,
      ],

      'lastMessage':
          message.trim(),

      'lastTimestamp':
          Timestamp.now(),

      'unreadCounts':
          unreadCounts,

    }, SetOptions(
      merge: true,
    ));
  }

  Future<void> sendImageMessage({
    required String receiverId,
    required File imageFile,
    }) async {

    final currentUser =
        _auth.currentUser;

    if (currentUser ==
        null) return;

    String roomId =
        getChatRoomId(
        currentUser.uid,
        receiverId,
    );

    try {

        // unique file name
        String fileName =
            DateTime.now()
                .millisecondsSinceEpoch
                .toString();

        // upload image
        Reference ref =
            FirebaseStorage
                .instance
                .ref()
                .child(
                'chat_images',
                )
                .child(
                roomId,
                )
                .child(
                '$fileName.jpg',
                );

        UploadTask uploadTask =
            ref.putFile(
        imageFile,
        );

        TaskSnapshot snapshot =
            await uploadTask;

        // get image url
        String imageUrl =
            await snapshot
                .ref
                .getDownloadURL();

        // save message
        await _firestore
            .collection(
                'chat_rooms')
            .doc(roomId)
            .collection(
                'messages')
            .add({

        'type':
            'image',

        'imageUrl':
            imageUrl,

        'message':
            '',

        'senderId':
            currentUser.uid,

        'receiverId':
            receiverId,

        'senderName':
            currentUser
                    .displayName ??
                'User',

        'timestamp':
            Timestamp.now(),

        'isSeen':
            false,
        });

        // unread logic
        final roomDoc =
            await _firestore
                .collection(
                    'chat_rooms')
                .doc(roomId)
                .get();

        Map<String, dynamic>
            unreadCounts = {};

        if (roomDoc.exists &&
            roomDoc.data()?[
                    'unreadCounts'] !=
                null) {

        unreadCounts =
            Map<String,
                dynamic>.from(
            roomDoc.data()![
                'unreadCounts'],
        );
        }

        // check receiver active room
        final receiverDoc =
            await _firestore
                .collection(
                    'users')
                .doc(receiverId)
                .get();

        String? activeRoom =
            receiverDoc
                .data()?[
                    'activeChatRoom'];

        bool isOpeningChat =
            activeRoom ==
                roomId;

        if (isOpeningChat) {

        unreadCounts[
            receiverId] = 0;

        } else {

        unreadCounts[
            receiverId] =
            (unreadCounts[
                    receiverId] ??
                0) +
            1;
        }

        unreadCounts[
            currentUser.uid] = 0;

        // update room
        await _firestore
            .collection(
                'chat_rooms')
            .doc(roomId)
            .set({

        'users': [
            currentUser.uid,
            receiverId,
        ],

        'lastMessage':
            '📷 Photo',

        'lastTimestamp':
            Timestamp.now(),

        'unreadCounts':
            unreadCounts,

        }, SetOptions(
        merge: true,
        ));

    } catch (e) {

        print(
        'send image error: $e',
        );
    }
    }

  // realtime messages
  Stream<QuerySnapshot>
      getMessages(
    String userId,
    String otherUserId,
  ) {

    String roomId =
        getChatRoomId(
      userId,
      otherUserId,
    );

    return _firestore
        .collection(
            'chat_rooms')
        .doc(roomId)
        .collection(
            'messages')
        .orderBy(
          'timestamp',
          descending: false,
        )
        .snapshots();
  }

  Stream<QuerySnapshot>
      getChatRooms(
    String currentUserId,
  ) {

    return _firestore
        .collection(
            'chat_rooms')
        .where(
          'users',
          arrayContains:
              currentUserId,
        )
        .orderBy(
          'lastTimestamp',
          descending: true,
        )
        .snapshots();
  }
}