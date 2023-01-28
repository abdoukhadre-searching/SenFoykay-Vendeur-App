import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:livraison_jouets_app_vendeurs/global/global.dart';
import 'package:livraison_jouets_app_vendeurs/screens/home_screen.dart';
import 'package:livraison_jouets_app_vendeurs/widgets/progress_bar.dart';
import 'package:firebase_storage/firebase_storage.dart' as storageRef;

import '../widgets/error_dialog.dart';

class MenusUploadScreen extends StatefulWidget {
  const MenusUploadScreen({Key? key}) : super(key: key);

  @override
  _MenusUploadScreenState createState() => _MenusUploadScreenState();
}

class _MenusUploadScreenState extends State<MenusUploadScreen> {
  XFile? imageXFile;
  final ImagePicker _picker = ImagePicker();

  TextEditingController shortInfoController = TextEditingController();
  TextEditingController titleController = TextEditingController();

  bool uploading = false;

  //unique id for menus
  String uniqueIdName = DateTime.now().millisecondsSinceEpoch.toString();

  defaultScreen() {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              color: Color.fromARGB(255, 3, 88, 216)
            // gradient: LinearGradient(
            //   begin: FractionalOffset(2.0, 0.0),
            //   end: FractionalOffset(5.0, 1.0),
            //   colors: [
            //     Color(0xFFFFFFFF),
            //     Color.fromARGB(255, 3, 88, 216)
            //   ],
            // ),
          ),
        ),
        title: Text(
          "Nouvelle categorie".toUpperCase(),
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(
            Icons.home,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (c) => const HomeScreen(),
              ),
            );
          },
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: FractionalOffset(-2.0, 0.0),
            end: FractionalOffset(4.0, -1.0),
            colors: [
              Color(0xFFFFFFFF),
              Color.fromARGB(255, 255, 255, 255),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.toys,
                color: Colors.black,
                size: 150,
              ),
              ElevatedButton(
                onPressed: () {
                  takeImage(context);
                },
                child: const Text(
                  "Ajouter une categorie de jouets",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(const Color.fromARGB(255, 3, 88, 216)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  takeImage(mcontext) {
    return showDialog(
        context: mcontext,
        builder: (c) {
          return SimpleDialog(
            title: const Text(
              "Une Image illustrant la categotie",
              style:
                  TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
            children:  [
              SimpleDialogOption(
                child:  Text(
                  "Prendre une photo",
                  style: TextStyle(color: Colors.grey),
                ),
                onPressed: captureImageWithCamera,
              ),
              SimpleDialogOption(
                child:  Text(
                  "Selectionner depuis la galerie",
                  style: TextStyle(color: Colors.grey),
                ),
                onPressed: pickImageFromGallery,
              ),
              SimpleDialogOption(
                child:  Center(
                  child: Text(
                    "Annuler",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }

//capture with camera
  captureImageWithCamera() async {
    Navigator.pop(context);
    imageXFile = await _picker.pickImage(
      source: ImageSource.camera,
      maxHeight: 720,
      maxWidth: 1280,
    );

    setState(() {
      imageXFile;
    });
  }

//select image from gallery
  pickImageFromGallery() async {
    Navigator.pop(context);
    imageXFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 720,
      maxWidth: 1280,
    );
    setState(() {
      imageXFile;
    });
  }

  menusUploadFormScreen() {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color:  Color.fromARGB(255, 3, 88, 216)
            // gradient: LinearGradient(
            //   begin: FractionalOffset(-2.0, 0.0),
            //   end: FractionalOffset(5.0, -1.0),
            //   colors: [
            //     Color(0xFFFFFFFF),
            //     Color.fromARGB(255, 255, 255, 255),
            //   ],
            // ),
          ),
        ),
        title: Text(
          "Formulaire categorie jouet",
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            clearMenuUploadFrom();
          },
        ),
        actions: [
          ElevatedButton(
            onPressed:
                //we check if uploading is null (otherwise if user clicks more than 1 time it will upload more than 1 time)
                uploading ? null : () => validateUploadForm(),
            child: Text(
              "Ajouter".toUpperCase(),
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                Colors.green,
              ),
              // fixedSize: MaterialStateProperty.all<Size?>(),
              shape: MaterialStateProperty.all<CircleBorder>(
                const CircleBorder(),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: FractionalOffset(-2.0, 0.0),
            end: FractionalOffset(5.0, -1.0),
            colors: [
              Color(0xFFFFFFFF),
              Color.fromARGB(255, 255, 255, 255),
            ],
          ),
        ),
        child: ListView(
          children: [
            uploading == true ? linearProgress() : const Text(""),
            SizedBox(
              height: 220,
              width: MediaQuery.of(context).size.width * 0.8,
              child: Center(
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: FileImage(
                          File(imageXFile!.path),
                        ),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(-1, 10),
                          blurRadius: 10,
                        )
                      ],
                      gradient: const LinearGradient(
                        begin: FractionalOffset(-2.0, 0.0),
                        end: FractionalOffset(5.0, -1.0),
                        colors: [
                          Color(0xFFFFFFFF),
                          Color(0xFFFAC898),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            const Divider(
              color: Colors.white,
              thickness: 2,
            ),
            ListTile(
              leading: const Icon(
                Icons.perm_device_information,
                color: Colors.black,
              ),
              title: SizedBox(
                width: 250,
                child: TextField(
                  controller: shortInfoController,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                      hintText: "Informmation de cette categorie ",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none),
                ),
              ),
            ),
            const Divider(
              color: Colors.white,
              thickness: 2,
            ),
            ListTile(
              leading: const Icon(
                Icons.title,
                color: Colors.black,
              ),
              title: SizedBox(
                width: 250,
                child: TextField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                      hintText: "Nom categorie",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none),
                ),
              ),
            ),
            const Divider(
              color: Colors.white,
              thickness: 2,
            ),
          ],
        ),
      ),
    );
  }

//clearing textfields
  clearMenuUploadFrom() {
    setState(() {
      shortInfoController.clear();
      titleController.clear();
      imageXFile = null;
    });
  }

  validateUploadForm() async {
    if (imageXFile != null) {
      if (shortInfoController.text.isNotEmpty &&
          titleController.text.isNotEmpty) {
        // if its true set uploading to true and start process indicator
        setState(() {
          uploading = true;
        });

        //upload image
        String downloadUrl = await uploadImage(File(imageXFile!.path));

        //save info to firestore

        saveInfo(downloadUrl);
      } else {
        showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: "Entrer le titre et la description ",
            );
          },
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (c) {
          return ErrorDialog(
            message: "Veuillez choisr une image.",
          );
        },
      );
    }
  }

//uploading image
  uploadImage(mImageFile) async {
    //we are creating seperate folder in firebase
    storageRef.Reference reference =
        storageRef.FirebaseStorage.instance.ref().child("menus");

    storageRef.UploadTask uploadTask =
        reference.child("$uniqueIdName.jpg").putFile(mImageFile);

    storageRef.TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});

    String downloadingUrl = await taskSnapshot.ref.getDownloadURL();

    return downloadingUrl;
  }

//saving menu information to firebase
  saveInfo(String downloadUrl) {
    final ref = FirebaseFirestore.instance
        //under sellers collection
        .collection("sellers")
        //for every unique seller
        .doc(sharedPreferences!.getString("uid"))
        //menus
        .collection("menus");

//information pass to firebase
    ref.doc(uniqueIdName).set(
      {
        "menuID": uniqueIdName,
        "sellerUID": sharedPreferences!.getString("uid"),
        "menuInfo": shortInfoController.text.toString(),
        "menuTitle": titleController.text.toString(),
        "publishedDate": DateTime.now(),
        "status": "available",
        "thumbnailUrl": downloadUrl,
      },
    );

    clearMenuUploadFrom();

    setState(() {
      uniqueIdName = DateTime.now().millisecondsSinceEpoch.toString();
      uploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return imageXFile == null ? defaultScreen() : menusUploadFormScreen();
  }
}
