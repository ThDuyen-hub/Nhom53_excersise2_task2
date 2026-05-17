import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatBubble
    extends StatelessWidget {

  final bool isMe;
  final bool isSeen;

  final String senderName;
  final String message;

  final String type;
  final String? imageUrl;

  final Timestamp
      timestamp;

  const ChatBubble({
    super.key,

    required this.isMe,
    required this.isSeen,

    required this.senderName,
    required this.message,

    required this.timestamp,

    this.type =
        'text',

    this.imageUrl,
  });

  @override
  Widget build(
      BuildContext context) {

    final time =
        DateFormat(
      'HH:mm',
    ).format(
      timestamp.toDate(),
    );

    return Container(
      margin:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 5,
      ),

      child: Column(
        crossAxisAlignment:
            isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,

        children: [

          Row(
            mainAxisAlignment:
                isMe
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,

            children: [

              Container(
                constraints:
                    const BoxConstraints(
                  maxWidth: 280,
                ),

                decoration:
                    BoxDecoration(

                  color:
                      isMe
                          ? Colors.blue
                          : Colors.grey[
                              300],

                  borderRadius:
                      BorderRadius.circular(
                          20),
                ),

                child: Padding(
                  padding:
                      const EdgeInsets.all(
                          8),

                  child:
                      type ==
                              'image'
                          ? GestureDetector(

                              onTap:
                                  () {

                                Navigator.push(
                                  context,

                                  MaterialPageRoute(
                                    builder:
                                        (_) =>
                                            FullScreenImagePage(
                                      imageUrl:
                                          imageUrl!,
                                    ),
                                  ),
                                );
                              },

                              child:
                                  ClipRRect(

                                borderRadius:
                                    BorderRadius.circular(
                                        15),

                                child:
                                    Image.network(

                                  imageUrl!,

                                  width:
                                      220,

                                  height:
                                      220,

                                  fit:
                                      BoxFit.cover,

                                  loadingBuilder:
                                      (
                                    context,
                                    child,
                                    progress,
                                  ) {

                                    if (progress ==
                                        null) {
                                      return child;
                                    }

                                    return const SizedBox(
                                      width:
                                          220,
                                      height:
                                          220,

                                      child:
                                          Center(
                                        child:
                                            CircularProgressIndicator(),
                                      ),
                                    );
                                  },

                                  errorBuilder:
                                      (
                                    context,
                                    error,
                                    stackTrace,
                                  ) {

                                    return const SizedBox(
                                      width:
                                          220,
                                      height:
                                          220,

                                      child:
                                          Center(
                                        child:
                                            Icon(
                                          Icons
                                              .broken_image,
                                          size:
                                              40,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )

                          : Text(
                              message,

                              style:
                                  TextStyle(
                                color:
                                    isMe
                                        ? Colors
                                            .white
                                        : Colors
                                            .black,
                                fontSize:
                                    16,
                              ),
                            ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 4,
          ),

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 8,
            ),

            child: Row(
              mainAxisSize:
                  MainAxisSize.min,

              children: [

                Text(
                  time,

                  style:
                      const TextStyle(
                    fontSize:
                        11,
                    color:
                        Colors.grey,
                  ),
                ),

                if (isMe)
                  Padding(
                    padding:
                        const EdgeInsets.only(
                      left: 5,
                    ),

                    child:
                        Icon(
                      isSeen
                          ? Icons.done_all
                          : Icons.done,

                      size:
                          16,

                      color:
                          isSeen
                              ? Colors.blue
                              : Colors.grey,
                    ),
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// FULL SCREEN IMAGE
class FullScreenImagePage
    extends StatelessWidget {

  final String imageUrl;

  const FullScreenImagePage({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(

      backgroundColor:
          Colors.black,

      appBar: AppBar(
        backgroundColor:
            Colors.black,
      ),

      body: Center(
        child:
            InteractiveViewer(

          minScale:
              0.5,

          maxScale:
              4,

          child:
              Image.network(
            imageUrl,
          ),
        ),
      ),
    );
  }
}