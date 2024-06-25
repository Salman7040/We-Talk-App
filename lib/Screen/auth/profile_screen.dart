import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gallery_picker/gallery_picker.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:we_talk/Helper/dialogs.dart';
import 'package:we_talk/Screen/auth/login_screen.dart';
import 'package:we_talk/api/apis.dart';
import 'package:we_talk/main.dart';
import 'package:we_talk/models/chat_user.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser myChatUser;
  const ProfileScreen({super.key, required this.myChatUser});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;
  @override
  Widget build(BuildContext context) {
    final isKeybord = MediaQuery.of(context).viewInsets.bottom != 0;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("Profile Screen"),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          //for logout btn
          child: FloatingActionButton.extended(
            onPressed: () async {
              Dialogs.showProgressBar(context);

              APIs.updateActiveStaus(false);
              await APIs.auth.signOut().then((value) async {
                await GoogleSignIn().signOut().then((onValue) {
                  //for hiding progresss bar
                  Navigator.pop(context);

                  //for moving to the home screem
                  Navigator.pop(context);

                  APIs.auth = FirebaseAuth.instance;
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()));
                });
              });
            },
            backgroundColor: Colors.redAccent,
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            label: const Text(
              "Logout",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15),
            ),
          ),
        ),
        body: Form(
          key: _formKey,
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: mq.height * 0.03,
                ),
                if (!isKeybord)
                  Stack(
                    children: [
                      _image != null
                          ? ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(mq.height * 0.100),
                              child: Image.file(
                                File(_image!),
                                height: mq.height * 0.2,
                                width: mq.height * 0.2,
                                fit: BoxFit.cover,
                              ),
                            )
                          : ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(mq.height * 0.100),
                              child: CachedNetworkImage(
                                height: mq.height * 0.2,
                                width: mq.height * 0.2,
                                fit: BoxFit.cover,
                                imageUrl: widget.myChatUser.image,
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                            ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: MaterialButton(
                          onPressed: () {
                            _ShowBottomSheet();
                          },
                          elevation: 1,
                          shape: const CircleBorder(),
                          color: Colors.white,
                          child: const Icon(
                            Icons.edit,
                            color: Colors.blueAccent,
                          ),
                        ),
                      )
                    ],
                  ),
                SizedBox(
                  height: mq.height * 0.02,
                ),
                Text(
                  widget.myChatUser.email,
                  style: const TextStyle(
                      fontSize: 20,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  height: mq.height * 0.03,
                ),
                //user name 
                SizedBox(
                  width: mq.width * 0.85,
                  child: TextFormField(
                    inputFormatters: [LengthLimitingTextInputFormatter(20)],
                    onSaved: (val) => APIs.me.name = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Required Field',
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        label: const Text('Name'),
                        hintText: 'eg. We Talk'),
                    initialValue: widget.myChatUser.name,
                  ),
                ),
                SizedBox(
                  height: mq.height * 0.02,
                ),
                SizedBox(
                  width: mq.width * 0.85,
                  child: TextFormField(
                    inputFormatters: [LengthLimitingTextInputFormatter(30)],
                    onSaved: (val) => APIs.me.about = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Required Field',
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.info_outline),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        label: const Text('About'),
                        hintText: 'eg. We Talk'),
                    initialValue: widget.myChatUser.about,
                  ),
                ),
                SizedBox(
                  height: mq.height * 0.1,
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    //on press update validate and save the data to the database
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      APIs.updateProfileData().then((val) =>
                          Dialogs.showSnackBar(
                              context,
                              "Profile Updated Successfully...",
                              Colors.greenAccent));
                    }
                  },
                  label: const Text(
                    "Update",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 20),
                  ),
                  icon: const Icon(
                    Icons.edit,
                    size: 25,
                    color: Colors.white,
                  ),
                  style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      backgroundColor: Colors.blueAccent,
                      minimumSize: Size(mq.width * .5, mq.height * .06)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _ShowBottomSheet() {
    showModalBottomSheet(
        backgroundColor: Colors.white,
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        )),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding:
                EdgeInsets.only(top: mq.height * .02, bottom: mq.height * .04),
            children: [
              const Text(
                "Pick Profile Pictrue",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: mq.height * .02,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: () async {
                        //TODO:for pickup image from the gallery
                        final ImagePicker picker = ImagePicker();
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.gallery);

                        //cropped and compressed image store in firebase store
                        if (image != null) {
                          CroppedFile? corppedImage = await ImageCropper()
                              .cropImage(
                                  sourcePath: image.path,
                                  aspectRatio:
                                      CropAspectRatio(ratioX: 1, ratioY: 1),
                                  compressQuality: 70);
                          setState(() {
                            _image = corppedImage?.path;
                          });
                          await APIs.updateProfilePicture(File(_image!));
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(mq.width * .3, mq.height * .14),
                      ),
                      child: Image.asset("images/gallery.png")),
                  ElevatedButton(
                      onPressed: () async {
                        //TODO:for pickup image from the camera
                        final ImagePicker picker = ImagePicker();
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.camera);
                        if (image != null) {
                          // FlutterImageCompress.compressAndGetFile(image.path, targetPath);
                          CroppedFile? corppedImage = await ImageCropper()
                              .cropImage(
                                  sourcePath: image.path,
                                  aspectRatio:
                                      CropAspectRatio(ratioX: 1, ratioY: 1),
                                  compressQuality: 70);
                          setState(() {
                            _image = corppedImage?.path;
                          });
                          await APIs.updateProfilePicture(File(_image!));
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(mq.width * .3, mq.height * .14),
                      ),
                      child: Image.asset("images/camera2.png")),
                ],
              )
            ],
          );
        });
  }
}
