import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:livraison_jouets_app_vendeurs/authentication/register.dart';
import 'package:livraison_jouets_app_vendeurs/global/global.dart';
import 'package:livraison_jouets_app_vendeurs/screens/home_screen.dart';
import 'package:livraison_jouets_app_vendeurs/widgets/custom_text_field.dart';
import 'package:livraison_jouets_app_vendeurs/widgets/error_dialog.dart';
import 'package:livraison_jouets_app_vendeurs/widgets/loading_dialog.dart';

import '../widgets/header_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final double _headerHeight = 250;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

//form validation for login
  formValidation() {
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      //login
      loginNow();
    } else {
      showDialog(
        context: context,
        builder: (c) {
          return ErrorDialog(
            message: "Veuiller taper votre email et mot de passe",
          );
        },
      );
    }
  }

//login function
  loginNow() async {
    showDialog(
      context: context,
      builder: (c) {
        return LoadingDialog(
          message: "Verification des informations",
        );
      },
    );

    User? currentUser;
    await firebaseAuth
        .signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    )
        .then(
      (auth) {
        currentUser = auth.user!;
      },
    ).catchError((error) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (c) {
          return ErrorDialog(
            message: error.message.toString(),
          );
        },
      );
    });
    if (currentUser != null) {
      readDataAndSetDataLocally(currentUser!);
    }
  }

//read data from firestore and save it locally
  Future readDataAndSetDataLocally(User currentUser) async {
    await FirebaseFirestore.instance
        .collection("sellers")
        .doc(currentUser.uid)
        .get()
        .then(
      (snapshot) async {
        //check if the user is seller
        if (snapshot.exists) {
          if (snapshot.data()!["status"] == "approved") {
            await sharedPreferences!.setString("uid", currentUser.uid);
            await sharedPreferences!
                .setString("email", snapshot.data()!["sellerEmail"]);
            await sharedPreferences!
                .setString("name", snapshot.data()!["sellerName"]);
            await sharedPreferences!
                .setString("photoUrl", snapshot.data()!["sellerAvatarUrl"]);
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (c) => const HomeScreen(),
              ),
            );
          } else {
            firebaseAuth.signOut();
            Navigator.pop(context);

            Fluttertoast.showToast(msg: "Votre compte a ete bloqué");
          }
        }
        //if user is not a seller
        else {
          firebaseAuth.signOut();
          Navigator.pop(context);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (c) => const LoginScreen(),
            ),
          );
          showDialog(
            context: context,
            builder: (c) {
              return ErrorDialog(
                message: "Aucune information trouvée",
              );
            },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(
                height: _headerHeight,
                child: HeaderWidget(
                  _headerHeight,
                  true,
                  Icons.toys_rounded,
                ), //let's create a common header widget
              ),
              const SizedBox(height: 50),
              Center(
                child: Text(
                  'Vendeurs 🛒 SenFoykay',
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Connecter via votre compte',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30.0),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      data: Icons.email,
                      controller: emailController,
                      hintText: "Email",
                      isObsecre: false,
                    ),
                    CustomTextField(
                      data: Icons.lock,
                      controller: passwordController,
                      hintText: "Mot de passe",
                      isObsecre: true,
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () {
                          // Navigator.push( context, MaterialPageRoute( builder: (context) => ForgotPasswordPage()), );
                        },
                        child: const Text(
                          "Mot de passe oublié  ?",
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black26,
                              offset: Offset(0, 4),
                              blurRadius: 5.0)
                        ],
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          stops: [0.0, 1.0],
                          colors: [
                            Colors.blue,
                            Color.fromARGB(255, 0, 89, 255),
                          ],
                        ),
                        color: Colors.deepPurple.shade300,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: ElevatedButton(
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          minimumSize:
                              MaterialStateProperty.all(const Size(50, 50)),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.transparent),
                          shadowColor:
                              MaterialStateProperty.all(Colors.transparent),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
                          child: Text(
                            'Connecter'.toUpperCase(),
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        onPressed: () {
                          formValidation();
                        },
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(text: "Pas encore de compte ? "),
                            TextSpan(
                              text: 'Creer un ',
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const RegisterScreen()));
                                },
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
