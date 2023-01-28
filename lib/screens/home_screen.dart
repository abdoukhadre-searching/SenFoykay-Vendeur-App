import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:livraison_jouets_app_vendeurs/global/global.dart';
import 'package:livraison_jouets_app_vendeurs/models/menus.dart';
import 'package:livraison_jouets_app_vendeurs/widgets/my_drawer.dart';
import 'package:livraison_jouets_app_vendeurs/widgets/progress_bar.dart';
import 'package:livraison_jouets_app_vendeurs/widgets/seller_info.dart';

import '../upload_screens/menus_upload_screen.dart';
import '../widgets/info_design.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      body: Container(
        decoration: const BoxDecoration(
           gradient: LinearGradient(
            begin: FractionalOffset(2.0, 0.0),
            end: FractionalOffset(5.0, 1.0),
            colors: [
              Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 255, 255, 255),
            ],
          ),
        ),
        child: CustomScrollView(
          scrollDirection: Axis.vertical,
          slivers: [
            //appbar
            SliverAppBar(
              elevation: 1,
              pinned: true,
              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
              foregroundColor: Colors.black,
              expandedHeight: 50,
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: FractionalOffset(-1.0, 0.0),
                    end: FractionalOffset(4.0, -1.0),
                    colors: [
                      Color(0xFFFFFFFF),
                      Color.fromARGB(255, 255, 255, 255),
                    ],
                  ),
                ),
                child: FlexibleSpaceBar(
                  title: Text(
                    'Espace vendeurs',
                    style: GoogleFonts.lato(
                      textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                  centerTitle: false,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: GestureDetector(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                      child: const Icon(Icons.add, color: Colors.white,),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (c) => const MenusUploadScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            // this is where seller info is displayed
            SliverToBoxAdapter(
              child: SellerInfo(),
            ),
            SliverToBoxAdapter(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("sellers")
                    .doc(sharedPreferences!.getString("uid"))
                    .collection("menus")
                    //ordering menus and items by publishing date (descending)
                    .orderBy("publishedDate", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                      // print("snapshot result : $snapshot");
                      if (!snapshot.hasData) {
                        return Center(
                        child: circularProgress(),
                      );
                      } else {
                        return ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            Menus model = Menus.fromJson(
                                snapshot.data!.docs[index].data()! as Map<String, dynamic>
                            );
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InfoDesignWidget(
                                model: model,
                                context: context,
                              ),
                            );
                          },
                          itemCount: snapshot.data!.docs.length,
                        );
                      }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
