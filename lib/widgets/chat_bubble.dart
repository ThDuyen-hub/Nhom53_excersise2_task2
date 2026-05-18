import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatBubble extends StatelessWidget {
  final bool isMe;
  final bool isSeen;

  final String senderName;
  final String message;

  final String type;
  final String? imageUrl;

  final Timestamp timestamp;

  final VoidCallback? onDelete;

  const ChatBubble({
    super.key,
    required this.isMe,
    required this.isSeen,
    required this.senderName,
    required this.message,
    required this.timestamp,
    this.type = 'text',
    this.imageUrl,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final time = DateFormat(
      'HH:mm',
    ).format(
      timestamp.toDate(),
    );

    return GestureDetector(
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          builder: (_) {
            return SafeArea(
              child: Wrap(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    title: const Text(
                      "Delete message",
                    ),
                    onTap: () {
                      Navigator.pop(
                        context,
                      );

                      onDelete?.call();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },

      child: Container(
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
                        type == 'image'
                            ? Colors
                                .transparent
                            : isMe
                                ? Colors.blue
                                : Colors.grey[
                                    300],

                    borderRadius:
                        BorderRadius.circular(
                            20),
                  ),

                  child: Padding(
                    padding:
                        EdgeInsets.all(
                      type == 'image'
                          ? 0
                          : 12,
                    ),

                    child:
                        type == 'image'
                            ? ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(
                                        18),

                                child:
                                    Image.network(
                                  imageUrl ??
                                      '',

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
                                    return Container(
                                      width:
                                          220,
                                      height:
                                          220,
                                      decoration:
                                          BoxDecoration(
                                        color:
                                            Colors.grey
                                                .shade300,
                                        borderRadius:
                                            BorderRadius.circular(
                                                18),
                                      ),
                                      child:
                                          const Icon(
                                        Icons
                                            .broken_image,
                                        size:
                                            50,
                                      ),
                                    );
                                  },
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

                      child: Icon(
                        isSeen
                            ? Icons.done_all
                            : Icons.done,

                        size: 16,

                        color:
                            isSeen
                                ? Colors.blue
                                : Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}