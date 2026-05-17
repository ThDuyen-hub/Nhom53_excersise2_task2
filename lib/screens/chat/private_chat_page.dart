import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/chat_service.dart';
import '../../widgets/chat_bubble.dart';

class PrivateChatPage
    extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  const PrivateChatPage({
    super.key,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<PrivateChatPage>
      createState() =>
          _PrivateChatPageState();
}

class _PrivateChatPageState
    extends State<
        PrivateChatPage> {
  final TextEditingController
      messageController =
      TextEditingController();

  final ScrollController
      scrollController =
      ScrollController();

  final ChatService
      chatService =
      ChatService();

  bool isMarkingRead =
      false;

  User? currentUser;

  @override
  void initState() {
    super.initState();

    currentUser =
        FirebaseAuth
            .instance
            .currentUser;

    setActiveChatRoom();
    markAsRead();
  }

  // SET ACTIVE ROOM
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

  // CLEAR ACTIVE ROOM
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

  // MARK READ
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

  // AUTO SCROLL
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

  // SEND MESSAGE
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

  // PICK IMAGE
  Future<void>
  pickImage() async {
    final picker =
        ImagePicker();

    final pickedFile =
        await picker
            .pickImage(
      source:
          ImageSource
              .gallery,
    );

    if (pickedFile ==
        null) return;

    File image =
        File(
      pickedFile.path,
    );

    await chatService
        .sendImageMessage(
      receiverId:
          widget.receiverId,
      imageFile: image,
    );
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

      appBar: AppBar(
        elevation: 0,
        backgroundColor:
            Colors.white,
        foregroundColor:
            Colors.black,

        title: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor:
                  Colors
                      .deepPurple
                      .shade100,
              child: Text(
                widget
                    .receiverName[
                        0]
                    .toUpperCase(),
                style:
                    const TextStyle(
                  color: Colors
                      .deepPurple,
                  fontWeight:
                      FontWeight
                          .bold,
                ),
              ),
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
                      fontSize:
                          17,
                      fontWeight:
                          FontWeight
                              .bold,
                    ),
                  ),

                  const Text(
                    "Chatting...",
                    style:
                        TextStyle(
                      fontSize:
                          12,
                      color: Colors
                          .grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      body: Column(
        children: [

          // MESSAGE LIST
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

                if (!snapshot
                    .hasData) {
                  return const Center(
                    child: Text(
                      "No messages",
                    ),
                  );
                }

                final docs =
                    snapshot
                        .data!
                        .docs;

                markAsRead();
                scrollDown();

                return ListView.builder(
                  controller:
                      scrollController,

                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal:
                        10,
                    vertical:
                        12,
                  ),

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
                          data[
                                  'isSeen'] ??
                              false,
                      senderName:
                          data[
                                  'senderName'] ??
                              'User',
                      message:
                          data[
                                  'message'] ??
                              '',
                      imageUrl:
                          data[
                              'imageUrl'],
                      type:
                          data[
                              'type'] ??
                              'text',
                      timestamp:
                          data[
                                  'timestamp'] ??
                              Timestamp
                                  .now(),
                    );
                  },
                );
              },
            ),
          ),

          // INPUT
          SafeArea(
            child:
                Container(
              padding:
                  const EdgeInsets
                      .fromLTRB(
                12,
                10,
                12,
                10,
              ),

              decoration:
                  BoxDecoration(
                color:
                    Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors
                        .black
                        .withOpacity(
                            0.05),
                    blurRadius:
                        10,
                    offset:
                        const Offset(
                            0, -2),
                  ),
                ],
              ),

              child: Row(
                children: [

                  // IMAGE BUTTON
                  Container(
                    decoration:
                        BoxDecoration(
                      color: Colors
                          .deepPurple
                          .shade50,
                      shape: BoxShape
                          .circle,
                    ),

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
                        Container(
                      decoration:
                          BoxDecoration(
                        color: Colors
                            .grey
                            .shade100,
                        borderRadius:
                            BorderRadius.circular(
                                30),
                      ),

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
                            const InputDecoration(
                          hintText:
                              "Type message...",
                          border:
                              InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(
                            horizontal:
                                20,
                            vertical:
                                14,
                          ),
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
          ),
        ],
      ),
    );
  }
}