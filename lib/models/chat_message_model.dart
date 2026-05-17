  import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {

  final String id;
  final String message;
  final String senderId;
  final String senderName;
  final Timestamp timestamp;

  ChatMessageModel({
    required this.id,
    required this.message,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
  });

  factory ChatMessageModel
      .fromMap(
    String id,
    Map<String, dynamic> data,
  ) {

    return ChatMessageModel(
      id: id,

      message:
          data['message'] ?? '',

      senderId:
          data['senderId'] ?? '',

      senderName:
          data['senderName'] ??
              '',

      timestamp:
          data['timestamp'] ??
              Timestamp.now(),
    );
  }
}