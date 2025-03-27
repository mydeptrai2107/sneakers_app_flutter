import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:ecommerce_app/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class GeneralUtils with ChangeNotifier {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  String? name = '';
  String? email = '';
  String? id = '';

  UserModel model = UserModel();
  bool load = false;
  File? image;
  XFile? pickedfile;
  var newurl = '';
  final storage = FirebaseStorage.instance;
  final picker = ImagePicker();

  void showsuccessflushbar(String subject, context) {
    Flushbar(
      message: subject,
      titleColor: Colors.white,
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.FLOATING,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.elasticOut,
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 4),
      icon: const Icon(
        Icons.check,
        color: Colors.greenAccent,
      ),
    ).show(context);
  }

  void showerrorflushbar(String subject, context) {
    Flushbar(
      message: subject,
      titleColor: Colors.white,

      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.elasticOut,
      backgroundColor: Colors.red,
      //   isDismissible: false,
      duration: const Duration(seconds: 4),
      icon: const Icon(
        Icons.error,
        color: Colors.greenAccent,
      ),
    ).show(context);
  }

  void showloading(value) {
    load = value;
    notifyListeners();
  }

  Future<void> getgalleryimage() async {
    pickedfile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 40);
    if (pickedfile != null) {
      image = File(pickedfile!.path);
      notifyListeners();
    } else {
      const Text('No Image found');
      notifyListeners();
    }
  }

  void uploadprofileimage() async {
    final pickedfile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedfile != null) {
      image = File(pickedfile.path);

      notifyListeners();
    } else {
      const Text('No Image found');
    }
  }

  Future getcameraimage() async {
    final pickedfile = await picker.pickImage(source: ImageSource.camera);

    if (pickedfile != null) {
      image = File(pickedfile.path);

      notifyListeners();
    } else {
      const Text('No Image found');
    }
  }

  Future<String?> uploadImageToCloudinary(File imageValue) async {
    const String cloudName = "dgfmiwien";
    const String apiKey = "BvZZdKGI6pq4C8QrALmkZWt2MnY";
    const String uploadPreset = "sneakers";

    try {
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(imageValue.path),
        "upload_preset": uploadPreset,
        "api_key": apiKey,
      });

      Response response = await Dio().post(
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
        data: formData,
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data["secure_url"];
      }
    } catch (_) {}

    return null;
  }

  Future uploadimage() async {
    if (image != null) {
      newurl = await uploadImageToCloudinary(image!) ?? '';

      notifyListeners();
    } else {
      debugPrint('NO image found');
    }
  }

  Future uploadtoFirestore() async {
    final db = FirebaseFirestore.instance
        .collection('User Data')
        .doc(FirebaseAuth.instance.currentUser!.uid);
    await db.update({'image': newurl});

    notifyListeners();
  }

  Future<dynamic> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    name = userCredential.user!.displayName;
    email = userCredential.user?.email;
    id = userCredential.user?.uid;
    FirebaseAuth.instance.authStateChanges();
  }
}
