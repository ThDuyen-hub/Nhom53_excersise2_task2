import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/chat_service.dart';
import '../../widgets/chat_bubble.dart';

class PrivateChatPage extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  const PrivateChatPage({
    super.key,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<PrivateChatPage> createState() =>
      _PrivateChatPageState();
}

class _PrivateChatPageState
    extends State<PrivateChatPage> {
  final TextEditingController
      messageController =
      TextEditingController();

  final ScrollController
      scrollController =
      ScrollController();

  final ChatService
      chatService =
      ChatService();

  User? currentUser;

  bool isMarkingRead =
      false;

  @override
  void initState() {
    super.initState();

    currentUser =
        FirebaseAuth
            .instance
            .currentUser;

    setActiveChatRoom();

    WidgetsBinding.instance
        .addPostFrameCallback(
      (_) {
        markAsRead();
      },
    );
  }

  // ========================
  // ACTIVE CHAT ROOM
  // ========================

  Future<void>
  setActiveChatRoom()
  async {
    if (currentUser ==
        null) return;

    String roomId =
        chatService
            .getChatRoomId(
      currentUser!.uid,
      widget.receiverId,
    );

    await FirebaseFirestore
        .instance
        .collection(
            'users')
        .doc(
            currentUser!.uid)
        .update({
      'activeChatRoom':
          roomId,
    });
  }

  Future<void>
  clearActiveChatRoom()
  async {
    if (currentUser ==
        null) return;

    await FirebaseFirestore
        .instance
        .collection(
            'users')
        .doc(
            currentUser!.uid)
        .update({
      'activeChatRoom':
          null,
    });
  }

  // ========================
  // MARK READ
  // ========================

  Future<void> markAsRead()
  async {
    if (currentUser ==
            null ||
        isMarkingRead) {
      return;
    }

    try {
      isMarkingRead =
          true;

      String roomId =
          chatService
              .getChatRoomId(
        currentUser!.uid,
        widget.receiverId,
      );

      final messages =
          await FirebaseFirestore
              .instance
              .collection(
                  'chat_rooms')
              .doc(roomId)
              .collection(
                  'messages')
              .where(
                'receiverId',
                isEqualTo:
                    currentUser!
                        .uid,
              )
              .where(
                'isSeen',
                isEqualTo:
                    false,
              )
              .get();

      for (var doc
          in messages.docs) {
        await doc.reference
            .update({
          'isSeen': true,
        });
      }

      // reset unread
      await FirebaseFirestore
          .instance
          .collection(
              'chat_rooms')
          .doc(roomId)
          .set({
        'unreadCounts': {
          currentUser!.uid:
              0,
        }
      },
              SetOptions(
                  merge:
                      true));
    } catch (e) {
      debugPrint(
        'markAsRead error: $e',
      );
    } finally {
      isMarkingRead =
          false;
    }
  }

  // ========================
  // AUTO SCROLL
  // ========================

  void scrollDown() {
    WidgetsBinding.instance
        .addPostFrameCallback(
      (_) {
        if (scrollController
            .hasClients) {
          scrollController
              .animateTo(
            scrollController
                .position
                .maxScrollExtent,
            duration:
                const Duration(
              milliseconds:
                  300,
            ),
            curve:
                Curves.easeOut,
          );
        }
      },
    );
  }

  // ========================
  // SEND TEXT
  // ========================

  Future<void>
  sendMessage() async {
    if (messageController
        .text
        .trim()
        .isEmpty) {
      return;
    }

    await chatService
        .sendMessage(
      receiverId:
          widget.receiverId,
      message:
          messageController
              .text,
    );

    messageController
        .clear();
  }

  // ========================
  // SEND IMAGE
  // ========================

  Future<void>
  pickImage() async {
    try {
      final picker =
          ImagePicker();

      final pickedFile =
          await picker
              .pickImage(
        source:
            ImageSource
                .gallery,
        imageQuality:
            70,
      );

      if (pickedFile ==
          null) {
        return;
      }

      File image =
          File(
        pickedFile.path,
      );

      await chatService
          .sendImageMessage(
        receiverId:
            widget
                .receiverId,
        imageFile:
            image,
      );
    } catch (e) {
      debugPrint(
        "pick image error: $e",
      );
    }
  }

  @override
  void dispose() {
    clearActiveChatRoom();

    messageController
        .dispose();

    scrollController
        .dispose();

    super.dispose();
  }

  @override
  Widget build(
      BuildContext context) {
    if (currentUser ==
        null) {
      return const Scaffold(
        body: Center(
          child: Text(
            "User not logged in",
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          const Color(
              0xffF5F7FA),

      // ====================
      // APPBAR
      // ====================

      appBar: AppBar(
        elevation: 1,
        backgroundColor:
            Colors.white,
        foregroundColor:
            Colors.black,

        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore
              .instance
              .collection('users')
              .doc(widget.receiverId)
              .snapshots(),

          builder: (context, snapshot) {

            String? photoUrl;

            bool isOnline = false;

            if (snapshot.hasData &&
                snapshot.data!.exists) {

              final userData =
                  snapshot.data!.data()
                      as Map<String, dynamic>;

              photoUrl =
                  userData['photoUrl'];

              isOnline =
                  userData['isOnline'] ??
                      false;
            }

            return Row(
              children: [
                CircleAvatar(
                  radius: 22,

                  backgroundImage:
                      photoUrl != null
                          ? NetworkImage(
                              photoUrl,
                            )
                          : null,

                  backgroundColor:
                      Colors.deepPurple
                          .shade100,

                  child: photoUrl ==
                          null
                      ? Text(
                          widget
                              .receiverName[0]
                              .toUpperCase(),
                          style:
                              const TextStyle(
                            color: Colors
                                .deepPurple,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        )
                      : null,
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [

                      Text(
                        widget
                            .receiverName,
                        overflow:
                            TextOverflow
                                .ellipsis,

                        style:
                            const TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),

                      Text(
                        isOnline
                            ? "Online"
                            : "Offline",

                        style:
                            TextStyle(
                          fontSize: 12,
                          color: isOnline
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),

      // ====================
      // BODY
      // ====================

      body: Column(
        children: [
          Expanded(
            child:
                StreamBuilder<
                    QuerySnapshot>(
              stream:
                  chatService
                      .getMessages(
                currentUser!
                    .uid,
                widget
                    .receiverId,
              ),

              builder:
                  (context,
                      snapshot) {
                if (snapshot
                        .connectionState ==
                    ConnectionState
                        .waiting) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                final docs =
                    snapshot
                            .data
                            ?.docs ??
                        [];

                markAsRead();

                scrollDown();

                return ListView.builder(
                  controller:
                      scrollController,
                  padding:
                      const EdgeInsets
                          .all(10),

                  itemCount:
                      docs.length,

                  itemBuilder:
                      (context,
                          index) {
                    final data =
                        docs[index]
                                .data()
                            as Map<
                                String,
                                dynamic>;

                    bool isMe =
                        data[
                                'senderId'] ==
                            currentUser!
                                .uid;

                    return ChatBubble(
                      isMe: isMe,

                      isSeen:
                          data['isSeen'] ??
                              false,

                      senderName:
                          data['senderName'] ??
                              'User',

                      message:
                          data['message'] ??
                              '',

                      imageUrl:
                          data['imageUrl'],

                      type:
                          data['type'] ??
                              'text',

                      timestamp:
                          data['timestamp'] ??
                              Timestamp.now(),

                      onDelete: () async {
                        await docs[index]
                            .reference
                            .delete();
                      },
                    );
                  },
                );
              },
            ),
          ),

          // ====================
          // INPUT AREA
          // ====================

          SafeArea(
            child:
                Container(
              padding:
                  const EdgeInsets
                      .all(12),

              decoration:
                  BoxDecoration(
                color:
                    Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors
                        .black12,
                    blurRadius:
                        10,
                  ),
                ],
              ),

              child: Row(
                children: [
                  // IMAGE BUTTON
                  CircleAvatar(
                    backgroundColor:
                        Colors
                            .deepPurple
                            .shade50,

                    child:
                        IconButton(
                      onPressed:
                          pickImage,
                      icon:
                          const Icon(
                        Icons.image,
                        color: Colors
                            .deepPurple,
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  Expanded(
                    child:
                        TextField(
                      controller:
                          messageController,

                      textInputAction:
                          TextInputAction
                              .send,

                      onSubmitted:
                          (_) =>
                              sendMessage(),

                      decoration:
                          InputDecoration(
                        hintText:
                            "Type message...",

                        filled:
                            true,

                        fillColor:
                            Colors.grey
                                .shade100,

                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  30),

                          borderSide:
                              BorderSide.none,
                        ),

                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal:
                              20,
                          vertical:
                              14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  CircleAvatar(
                    radius: 26,
                    backgroundColor:
                        Colors
                            .deepPurple,

                    child:
                        IconButton(
                      onPressed:
                          sendMessage,
                      icon:
                          const Icon(
                        Icons.send,
                        color: Colors
                            .white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}