// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// import '../../widgets/chat_bubble.dart';
// import '../../services/chat_service.dart';

// class ChatPage
//     extends StatefulWidget {

//   const ChatPage({
//     super.key,
//   });

//   @override
//   State<ChatPage>
//       createState() =>
//           _ChatPageState();
// }

// class _ChatPageState
//     extends State<
//         ChatPage> {

//   final TextEditingController
//       messageController =
//       TextEditingController();

//   final ChatService
//       chatService =
//       ChatService();

//   final ScrollController
//     scrollController =
//     ScrollController();

//   void scrollDown() {

//     WidgetsBinding.instance
//         .addPostFrameCallback((_) {

//       if (scrollController
//           .hasClients) {

//         scrollController
//             .animateTo(
//           scrollController
//               .position
//               .maxScrollExtent,

//           duration:
//               const Duration(
//             milliseconds: 300,
//           ),

//           curve:
//               Curves.easeOut,
//         );
//       }
//     });
//   }

//   @override
//   Widget build(
//       BuildContext context) {

//     final currentUser =
//         FirebaseAuth
//             .instance
//             .currentUser;

//     return Scaffold(
//       appBar: AppBar(
//         title: Column(
//           crossAxisAlignment:
//               CrossAxisAlignment
//                   .start,
//           children: [

//             const Text(
//               "Global Chat",
//               style: TextStyle(
//                 fontSize: 20,
//               ),
//             ),

//             Text(
//               currentUser
//                       ?.displayName ??
//                   '',
//               style:
//                   const TextStyle(
//                 fontSize: 13,
//               ),
//             ),
//           ],
//         ),

//         actions: [

//           IconButton(
//             onPressed: () async {

//               await FirebaseAuth
//                   .instance
//                   .signOut();
//             },
//             icon:
//                 const Icon(
//               Icons.logout,
//             ),
//           )
//         ],
//       ),

//       body: Column(
//         children: [

//           // message list
//           Expanded(
//             child:
//                 StreamBuilder(
//               stream:
//                   chatService
//                       .getMessages(),

//               builder:
//                   (context,
//                       snapshot) {

//                 if (snapshot
//                         .connectionState ==
//                     ConnectionState
//                         .waiting) {
//                   return const Center(
//                     child:
//                         CircularProgressIndicator(),
//                   );
//                 }

//                 if (snapshot
//                     .hasError) {
//                   return Center(
//                     child: Text(
//                       snapshot.error
//                           .toString(),
//                     ),
//                   );
//                 }

//                 final docs =
//                     snapshot
//                         .data
//                         ?.docs ??
//                     [];

//                 scrollDown();

//                 return ListView.builder(
//                   controller:
//                       scrollController,

//                   padding:
//                       const EdgeInsets.only(
//                     top: 10,
//                     bottom: 10,
//                   ),

//                   itemCount:
//                       docs.length,

//                   itemBuilder:
//                       (context, index) {

//                     final data =
//                         docs[index].data()
//                             as Map<String,
//                                 dynamic>;

//                     bool isMe =
//                         data['senderId'] ==
//                             currentUser
//                                 ?.uid;

//                     return ChatBubble(
//                       isMe: isMe,

//                       senderName:
//                           data[
//                               'senderName'],

//                       message:
//                           data['message'],

//                       timestamp:
//                           data[
//                               'timestamp'],
//                     );
//                   },
//                 );          
//               },
//             ),
//           ),

//           // input
//           Container(
//             padding:
//                 const EdgeInsets.all(
//                     12),

//             decoration:
//                 BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   blurRadius: 10,
//                   color: Colors
//                       .grey
//                       .shade300,
//                 ),
//               ],
//             ),

//             child: Row(
//               children: [

//                 Expanded(
//                   child: TextField(
//                     controller:
//                         messageController,

//                     decoration:
//                         InputDecoration(
//                       hintText:
//                           "Type message...",

//                       filled: true,

//                       fillColor:
//                           Colors.grey
//                               .shade100,

//                       border:
//                           OutlineInputBorder(
//                         borderRadius:
//                             BorderRadius.circular(
//                                 30),

//                         borderSide:
//                             BorderSide.none,
//                       ),

//                       contentPadding:
//                           const EdgeInsets.symmetric(
//                         horizontal: 20,
//                         vertical: 12,
//                       ),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(
//                   width: 10,
//                 ),

//                 CircleAvatar(
//                   radius: 28,
//                   child: IconButton(
//                     onPressed:
//                         () async {

//                       await chatService
//                           .sendMessage(
//                         messageController
//                             .text,
//                       );

//                       messageController
//                           .clear();
//                     },
//                     icon: const Icon(
//                       Icons.send,
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }