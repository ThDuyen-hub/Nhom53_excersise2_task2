import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import '../../services/auth_service.dart';
import '../auth/login_page.dart';
import '../profile/edit_profile_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
          Colors.grey.shade100,

      appBar: AppBar(
        centerTitle: true,

        elevation: 0,

        title: const Text(
          "Profile",
        ),
      ),

      body: StreamBuilder<
          DocumentSnapshot>(
        stream:
            FirebaseFirestore
                .instance
                .collection(
                    'users')
                .doc(
                  currentUser.uid,
                )
                .snapshots(),

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
                  .hasData ||
              !snapshot
                  .data!
                  .exists) {
            return const Center(
              child: Text(
                "User data not found",
              ),
            );
          }

          final user =
              snapshot.data!
                      .data()
                  as Map<
                      String,
                      dynamic>;

          String name =
              user['name'] ??
                  'User';

          String email =
              user['email'] ??
                  '';

          bool isOnline =
              user['isOnline'] ??
                  false;

          Timestamp?
              lastSeen =
              user['lastSeen'];

          return SingleChildScrollView(
            child: Column(
              children: [

                const SizedBox(
                  height: 30,
                ),

                // avatar
                CircleAvatar(
                  radius: 55,

                  backgroundImage:
                      user['photoUrl'] !=
                              null
                          ? MemoryImage(
                              base64Decode(
                                user[
                                    'photoUrl'],
                              ),
                            )
                          : null,

                  backgroundColor:
                      Colors.blue
                          .shade100,

                  child:
                      user['photoUrl'] ==
                              null
                          ? Text(
                              name[0]
                                  .toUpperCase(),

                              style:
                                  const TextStyle(
                                fontSize:
                                    42,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            )
                          : null,
                ),

                const SizedBox(
                  height: 20,
                ),

                // name
                Text(
                  name,

                  style:
                      const TextStyle(
                    fontSize: 26,
                    fontWeight:
                        FontWeight
                            .bold,
                  ),
                ),

                const SizedBox(
                  height: 6,
                ),

                // email
                Text(
                  email,

                  style:
                      TextStyle(
                    color:
                        Colors
                            .grey
                            .shade700,

                    fontSize: 15,
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                // online status
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),

                  decoration:
                      BoxDecoration(
                    color:
                        isOnline
                            ? Colors
                                .green
                                .shade50
                            : Colors
                                .grey
                                .shade200,

                    borderRadius:
                        BorderRadius.circular(
                            30),
                  ),

                  child: Row(
                    mainAxisSize:
                        MainAxisSize
                            .min,

                    children: [
                      Icon(
                        Icons.circle,

                        size: 12,

                        color:
                            isOnline
                                ? Colors
                                    .green
                                : Colors
                                    .grey,
                      ),

                      const SizedBox(
                        width: 8,
                      ),

                      Text(
                        isOnline
                            ? "Online"
                            : "Last seen: ${lastSeen != null ? DateFormat('dd/MM/yyyy - HH:mm').format(lastSeen.toDate()) : 'Unknown'}",

                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight
                                  .w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 30,
                ),

                // info section
                Container(
                  margin:
                      const EdgeInsets
                          .symmetric(
                    horizontal:
                        16,
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
                            .black12,

                        blurRadius:
                            10,
                      ),
                    ],
                  ),

                  child: Column(
                    children: [

                      // name
                      ListTile(
                        leading:
                            const Icon(
                          Icons.person,
                        ),

                        title:
                            const Text(
                          "Name",
                        ),

                        subtitle:
                            Text(
                          name,
                        ),
                      ),

                      const Divider(
                        height: 1,
                      ),

                      // email
                      ListTile(
                        leading:
                            const Icon(
                          Icons.email,
                        ),

                        title:
                            const Text(
                          "Email",
                        ),

                        subtitle:
                            Text(
                          email,
                        ),
                      ),

                      const Divider(
                        height: 1,
                      ),

                      // uid
                      ListTile(
                        leading:
                            const Icon(
                          Icons.badge,
                        ),

                        title:
                            const Text(
                          "User ID",
                        ),

                        subtitle:
                            Text(
                          currentUser
                              .uid,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 24,
                ),

                // edit profile
                Padding(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 16,
                  ),

                  child: SizedBox(
                    width:
                        double.infinity,

                    height: 52,

                    child:
                        ElevatedButton.icon(
                      onPressed: () {

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EditProfilePage(
                              currentName:
                                  name,
                            ),
                          ),
                        );
                      },

                      icon:
                          const Icon(
                        Icons.edit,
                      ),

                      label:
                          const Text(
                        "Edit Profile",
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),
                
                // logout
                Padding(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 16,
                  ),

                  child: SizedBox(
                    width:
                        double.infinity,

                    height: 52,

                    child:
                        ElevatedButton.icon(
                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            Colors.red,
                      ),

                      onPressed:
                          () async {

                        await AuthService()
                            .logout();

                        if (context
                            .mounted) {

                          Navigator.pushAndRemoveUntil(
                            context,

                            MaterialPageRoute(
                              builder: (_) =>
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
                        color:
                            Colors.white,
                      ),

                      label:
                          const Text(
                        "Logout",

                        style:
                            TextStyle(
                          color:
                              Colors
                                  .white,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}