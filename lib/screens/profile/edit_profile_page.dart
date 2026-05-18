import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';



class EditProfilePage
    extends StatefulWidget {

  final String currentName;

  const EditProfilePage({
    super.key,
    required this.currentName,
  });

  @override
  State<EditProfilePage>
      createState() =>
          _EditProfilePageState();
}

class _EditProfilePageState
    extends State<
        EditProfilePage> {

  late TextEditingController
      nameController;

  bool isLoading =
      false;

  File? selectedImage;

  String? imageBase64;

  @override
  void initState() {
    super.initState();

    nameController =
        TextEditingController(
      text:
          widget.currentName,
    );
  }

  Future<void> updateProfile() async {

    String newName =
        nameController.text
            .trim();

    if (newName.isEmpty) {
      ScaffoldMessenger.of(
              context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Name cannot be empty",
          ),
        ),
      );
      return;
    }

    try {

      setState(() {
        isLoading = true;
      });

      final currentUser =
          FirebaseAuth
              .instance
              .currentUser;

      if (currentUser ==
          null) return;

      // update firebase auth
      await currentUser
          .updateDisplayName(
        newName,
      );

      // update firestore
      await FirebaseFirestore
          .instance
          .collection('users')
          .doc(currentUser.uid)
          .update({

        'name':
            newName,

        if (imageBase64 !=
            null)
          'photoUrl':
              imageBase64,
      });

      if (mounted) {

        ScaffoldMessenger.of(
                context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "Profile updated successfully",
            ),
          ),
        );

        Navigator.pop(
          context,
        );
      }

    } catch (e) {

      ScaffoldMessenger.of(
              context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );

    } finally {

      if (mounted) {
        setState(() {
          isLoading =
              false;
        });
      }
    }
  }

  Future<void> pickImage() async {

    try {

      final picker =
          ImagePicker();

      final pickedFile =
          await picker.pickImage(
        source:
            ImageSource.gallery,
        imageQuality:
            60,
      );

      if (pickedFile ==
          null) {
        return;
      }

      File image =
          File(
        pickedFile.path,
      );

      List<int> imageBytes =
          await image
              .readAsBytes();

      String base64Image =
          base64Encode(
        imageBytes,
      );

      setState(() {

        selectedImage =
            image;

        imageBase64 =
            base64Image;
      });

    } catch (e) {

      debugPrint(
        "Pick image error: $e",
      );
    }
  }

  @override
  void dispose() {

    nameController
        .dispose();

    super.dispose();
  }

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
        ),
      ),

      body: Padding(
        padding:
            const EdgeInsets
                .all(20),

        child: Column(
          children: [

            const SizedBox(
              height: 20,
            ),

            GestureDetector(
              onTap:
                  pickImage,

              child:
                  CircleAvatar(
                radius: 55,

                backgroundImage:
                    selectedImage !=
                            null
                        ? FileImage(
                            selectedImage!,
                          )
                        : null,

                child:
                    selectedImage ==
                            null
                        ? Text(
                            nameController
                                    .text
                                    .isNotEmpty
                                ? nameController
                                    .text[0]
                                    .toUpperCase()
                                : "U",

                            style:
                                const TextStyle(
                              fontSize:
                                  36,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          )
                        : null,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            const Text(
              "Tap avatar to change photo",
            ),

            const SizedBox(
              height: 30,
            ),

            TextField(
              controller:
                  nameController,

              decoration:
                  InputDecoration(
                labelText:
                    "Name",

                hintText:
                    "Enter your name",

                prefixIcon:
                    const Icon(
                  Icons.person,
                ),

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                          14),
                ),
              ),

              onChanged:
                  (_) {
                setState(() {});
              },
            ),

            const SizedBox(
              height: 30,
            ),

            SizedBox(
              width:
                  double.infinity,

              height: 55,

              child:
                  ElevatedButton(
                onPressed:
                    isLoading
                        ? null
                        : updateProfile,

                child:
                    isLoading
                        ? const CircularProgressIndicator(
                            color:
                                Colors.white,
                          )
                        : const Text(
                            "Save Changes",
                          ),
              ),
            )
          ],
        ),
      ),
    );
  }
}