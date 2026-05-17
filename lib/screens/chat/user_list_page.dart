import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart'
    as timeago;

import '../../services/auth_service.dart';
import '../../services/chat_service.dart';
import '../../services/user_service.dart';
import '../auth/login_page.dart';
import 'private_chat_page.dart';

class UserListPage
    extends StatefulWidget {
  const UserListPage({
    super.key,
  });

  @override
  State<UserListPage>
      createState() =>
          _UserListPageState();
}

class _UserListPageState
    extends State<
        UserListPage> {
  final TextEditingController
      searchController =
      TextEditingController();

  String searchText = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(
      BuildContext context) {
    final currentUser =
        FirebaseAuth
            .instance
            .currentUser;

    if (currentUser == null) {
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

        title: const Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .start,
          children: [
            Text(
              "Chats",
              style: TextStyle(
                fontWeight:
                    FontWeight
                        .bold,
                fontSize: 24,
              ),
            ),
            Text(
              "Your conversations",
              style: TextStyle(
                fontSize: 12,
                color:
                    Colors.grey,
              ),
            ),
          ],
        ),

        actions: [
          IconButton(
            onPressed:
                () async {
              await AuthService()
                  .logout();

              if (context
                  .mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) =>
                            const LoginPage(),
                  ),
                  (route) =>
                      false,
                );
              }
            },
            icon:
                const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),

      body: Column(
        children: [

          // SEARCH BAR
          Padding(
            padding:
                const EdgeInsets
                    .all(16),
            child: TextField(
              controller:
                  searchController,

              onChanged:
                  (value) {
                setState(() {
                  searchText =
                      value
                          .toLowerCase();
                });
              },

              decoration:
                  InputDecoration(
                hintText:
                    "Search user...",

                prefixIcon:
                    const Icon(
                  Icons.search,
                ),

                filled: true,

                fillColor:
                    Colors.white,

                contentPadding:
                    const EdgeInsets
                        .symmetric(
                  vertical: 0,
                ),

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                  borderSide:
                      BorderSide
                          .none,
                ),
              ),
            ),
          ),

          Expanded(
            child:
                StreamBuilder(
              stream:
                  ChatService()
                      .getChatRooms(
                currentUser.uid,
              ),

              builder:
                  (context,
                      roomSnapshot) {

                if (roomSnapshot
                        .connectionState ==
                    ConnectionState
                        .waiting) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                final rooms =
                    roomSnapshot
                            .data
                            ?.docs ??
                        [];

                return StreamBuilder(
                  stream:
                      UserService()
                          .getUsers(),

                  builder:
                      (context,
                          userSnapshot) {

                    if (userSnapshot
                            .connectionState ==
                        ConnectionState
                            .waiting) {
                      return const Center(
                        child:
                            CircularProgressIndicator(),
                      );
                    }

                    final users =
                        userSnapshot
                                .data
                                ?.docs ??
                            [];

                    // SORT USER
                    users.sort(
                        (a, b) {
                      Map<String,
                              dynamic>
                          aData =
                          a.data()
                              as Map<
                                  String,
                                  dynamic>;

                      Map<String,
                              dynamic>
                          bData =
                          b.data()
                              as Map<
                                  String,
                                  dynamic>;

                      Timestamp
                          aTime =
                          Timestamp(
                              0,
                              0);

                      Timestamp
                          bTime =
                          Timestamp(
                              0,
                              0);

                      for (var room
                          in rooms) {

                        final roomData =
                            room.data()
                                as Map<
                                    String,
                                    dynamic>;

                        List
                            usersInRoom =
                            roomData[
                                    'users'] ??
                                [];

                        bool isA =
                            usersInRoom.contains(
                                    aData[
                                        'uid']) &&
                                usersInRoom.contains(
                                    currentUser
                                        .uid);

                        bool isB =
                            usersInRoom.contains(
                                    bData[
                                        'uid']) &&
                                usersInRoom.contains(
                                    currentUser
                                        .uid);

                        if (isA &&
                            roomData[
                                    'lastTimestamp'] !=
                                null) {
                          aTime =
                              roomData[
                                  'lastTimestamp'];
                        }

                        if (isB &&
                            roomData[
                                    'lastTimestamp'] !=
                                null) {
                          bTime =
                              roomData[
                                  'lastTimestamp'];
                        }
                      }

                      return bTime
                          .compareTo(
                              aTime);
                    });

                    return ListView.builder(
                      itemCount:
                          users.length,

                      itemBuilder:
                          (context,
                              index) {

                        final user =
                            users[index]
                                    .data()
                                as Map<
                                    String,
                                    dynamic>;

                        // hide self
                        if (user[
                                'uid'] ==
                            currentUser
                                .uid) {
                          return const SizedBox();
                        }

                        // SEARCH
                        String name =
                            (user['name'] ??
                                    '')
                                .toLowerCase();

                        if (searchText
                                .isNotEmpty &&
                            !name.contains(
                                searchText)) {
                          return const SizedBox();
                        }

                        String
                            lastMessage =
                            "Start chatting";

                        String
                            time =
                            "";

                        int unreadCount =
                            0;

                        for (var room
                            in rooms) {

                          final roomData =
                              room.data()
                                  as Map<
                                      String,
                                      dynamic>;

                          List
                              usersInRoom =
                              roomData[
                                      'users'] ??
                                  [];

                          bool
                              isThisChat =
                              usersInRoom.contains(
                                      currentUser.uid) &&
                                  usersInRoom.contains(
                                      user[
                                          'uid']);

                          if (isThisChat) {

                            lastMessage =
                                roomData[
                                        'lastMessage'] ??
                                    '';

                            Map<String,
                                    dynamic>
                                unreadMap =
                                {};

                            if (roomData[
                                    'unreadCounts'] !=
                                null) {

                              unreadMap =
                                  Map<String,
                                      dynamic>.from(
                                roomData[
                                    'unreadCounts'],
                              );
                            }

                            unreadCount =
                                unreadMap[
                                        currentUser.uid] ??
                                    0;

                            if (roomData[
                                    'lastTimestamp'] !=
                                null) {

                              time =
                                  DateFormat(
                                'HH:mm',
                              ).format(
                                roomData[
                                        'lastTimestamp']
                                    .toDate(),
                              );
                            }

                            break;
                          }
                        }

                        return Container(
                          margin:
                              const EdgeInsets.symmetric(
                            horizontal:
                                14,
                            vertical: 5,
                          ),

                          decoration:
                              BoxDecoration(
                            color:
                                Colors.white,

                            borderRadius:
                                BorderRadius.circular(
                                    18),

                            boxShadow: [
                              BoxShadow(
                                color: Colors
                                    .black
                                    .withOpacity(
                                        0.05),

                                blurRadius:
                                    8,

                                offset:
                                    const Offset(
                                        0, 2),
                              ),
                            ],
                          ),

                          child:
                              ListTile(

                            contentPadding:
                                const EdgeInsets.symmetric(
                              horizontal:
                                  16,
                              vertical:
                                  10,
                            ),

                            onTap:
                                () {
                              Navigator.push(
                                context,

                                MaterialPageRoute(
                                  builder:
                                      (_) =>
                                          PrivateChatPage(
                                    receiverId:
                                        user[
                                            'uid'],

                                    receiverName:
                                        user[
                                            'name'],
                                  ),
                                ),
                              );
                            },

                            // AVATAR
                            leading:
                                Stack(
                              children: [

                                CircleAvatar(
                                  radius:
                                      30,

                                  backgroundColor:
                                      Colors
                                          .deepPurple
                                          .shade100,

                                  child:
                                      Text(
                                    user['name'][0]
                                        .toUpperCase(),

                                    style:
                                        const TextStyle(
                                      fontSize:
                                          22,

                                      fontWeight:
                                          FontWeight.bold,

                                      color:
                                          Colors.deepPurple,
                                    ),
                                  ),
                                ),

                                Positioned(
                                  right:
                                      0,
                                  bottom:
                                      0,

                                  child:
                                      Container(
                                    width:
                                        16,
                                    height:
                                        16,

                                    decoration:
                                        BoxDecoration(
                                      color:
                                          user['isOnline'] ==
                                                  true
                                              ? Colors.green
                                              : Colors.grey,

                                      shape:
                                          BoxShape.circle,

                                      border:
                                          Border.all(
                                        color:
                                            Colors.white,
                                        width:
                                            2,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),

                            title:
                                Text(
                              user['name'] ??
                                  'User',

                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                                fontSize:
                                    16,
                              ),
                            ),

                            subtitle:
                                Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [

                                const SizedBox(
                                    height:
                                        4),

                                Text(
                                  lastMessage,

                                  maxLines:
                                      1,

                                  overflow:
                                      TextOverflow
                                          .ellipsis,

                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.black87,
                                  ),
                                ),

                                const SizedBox(
                                  height:
                                      5,
                                ),

                                Text(
                                  user['isOnline'] ==
                                          true
                                      ? "Online"
                                      : user['lastSeen'] !=
                                              null
                                          ? "Last seen ${timeago.format(
                                              user['lastSeen']
                                                  .toDate(),
                                            )}"
                                          : "Offline",

                                  style:
                                      TextStyle(
                                    fontSize:
                                        12,

                                    color:
                                        user['isOnline'] ==
                                                true
                                            ? Colors.green
                                            : Colors.grey,
                                  ),
                                ),
                              ],
                            ),

                            trailing:
                                Column(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .center,

                              children: [

                                Text(
                                  time,

                                  style:
                                      const TextStyle(
                                    fontSize:
                                        12,
                                    color:
                                        Colors.grey,
                                  ),
                                ),

                                const SizedBox(
                                  height:
                                      8,
                                ),

                                if (unreadCount >
                                    0)

                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(
                                      horizontal:
                                          10,
                                      vertical:
                                          5,
                                    ),

                                    decoration:
                                        BoxDecoration(
                                      color:
                                          Colors.red,

                                      borderRadius:
                                          BorderRadius.circular(
                                              20),
                                    ),

                                    child:
                                        Text(
                                      unreadCount >
                                              99
                                          ? "99+"
                                          : unreadCount
                                              .toString(),

                                      style:
                                          const TextStyle(
                                        color:
                                            Colors.white,

                                        fontSize:
                                            12,

                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}