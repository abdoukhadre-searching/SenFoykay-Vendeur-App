import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:livraison_jouets_app_vendeurs/authentication/login.dart';
import 'package:livraison_jouets_app_vendeurs/screens/history_screen.dart';
import 'package:livraison_jouets_app_vendeurs/screens/home_screen.dart';
import 'package:livraison_jouets_app_vendeurs/screens/new_orders_screen.dart';

import '../global/global.dart';

class MyDrawer extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  MyDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
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
            //header drawer
            Container(
              padding: const EdgeInsets.only(top: 25, bottom: 10),
              child: Column(
                children: [
                  Material(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(80),
                    ),
                    elevation: 10,
                    child: Padding(
                      padding: const EdgeInsets.all(1),
                      child: SizedBox(
                        height: 120,
                        width: 120,
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            // boxShadow: [
                            //   BoxShadow(
                            //     color: Colors.amber.withOpacity(0.4),
                            //     offset: const Offset(-1, 10),
                            //     blurRadius: 10,
                            //   )
                            // ],
                          ),
                          child: CircleAvatar(
                            //we get the profile image from sharedPreferences (global.dart)
                            backgroundImage: NetworkImage(
                              sharedPreferences!.getString("photoUrl")!,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  //we get the user name from sharedPreferences (global.dart)
                  Text(
                    "Boutique: ${sharedPreferences!.getString("name")!}",
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            //body drawer
            Container(
              padding: const EdgeInsets.only(top: 1),
              child: Column(
                children: [
                  const Divider(
                    height: 10,
                    color: Colors.white,
                    thickness: 2,
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.home,
                      color: Colors.black,
                      size: 30,
                    ),
                    title: Text(
                      'Acceuil',
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (c) => const HomeScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(
                    height: 10,
                    color: Colors.white,
                    thickness: 2,
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.reorder,
                      color: Colors.black,
                      size: 30,
                    ),
                    title: Text(
                      'Nouvelle commandes',
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (c) => NewOrdersScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(
                    height: 10,
                    color: Colors.white,
                    thickness: 2,
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.local_shipping,
                      color: Colors.black,
                      size: 30,
                    ),
                    title: Text(
                      'Historique commandes',
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (c) => HistoryScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(
                    height: 10,
                    color: Colors.white,
                    thickness: 2,
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.exit_to_app,
                      color: Colors.black,
                      size: 30,
                    ),
                    title: Text(
                      'Déconnexion',
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () {
                      firebaseAuth.signOut().then((value) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) => const LoginScreen(),
                          ),
                        );
                        _controller.clear();
                      });
                    },
                  ),
                  const Divider(
                    height: 10,
                    color: Colors.white,
                    thickness: 2,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
