import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:griddeletion/views/LoginPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
              "Tap to delete",
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: InkWell(
                onTap: (() {
                  FirebaseAuth.instance.signOut().then((value) {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => LoginScreen()));
                  }).onError((error, stackTrace) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Error Signing out Please try again'),
                      duration: Duration(seconds: 1),
                    ));
                  });
                }),
                child: const Icon(
                  Icons.logout,
                  color: Colors.black,
                ))),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: (() async {
              // var length;
              try {
                final length = FirebaseFirestore.instance
                    .collection("Users")
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection("Grid_Sel")
                    .get()
                    .then((value) {
                  
                  FirebaseFirestore.instance
                      .collection("Users")
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection("Grid_Sel")
                      .doc(value.size.toString())
                      .set({"Number": value.size + 1});
                });
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Block Added'),
                  duration: Duration(seconds: 1),
                ));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Error'),
                  duration: Duration(seconds: 1),
                ));
              }
            })),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("Users")
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .collection("Grid_Sel")
                        .snapshots(),
                    builder: ((context, snapshot) {
                      var gridList = snapshot.data?.docs;
                    
                      return snapshot.data?.size == null
                          ? CircularProgressIndicator()
                          : GridView(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10),
                              primary: false,
                              shrinkWrap: true,
                              children: List.generate(
                                  snapshot.data!.size,
                                  (index) => InkWell(
                                        onTap: (() {
                                          FirebaseFirestore.instance
                                              .collection("Users")
                                              .doc(FirebaseAuth
                                                  .instance.currentUser!.uid)
                                              .collection("Grid_Sel")
                                              .where("Number",
                                                  isEqualTo: gridList[index]
                                                      ['Number'])
                                              .get()
                                              .then(
                                            (value) {
                                              value.docs.forEach(
                                                (element) {
                                                  element.reference.delete();
                                                },
                                              );
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content:
                                                      Text('Block deleted'),
                                                  duration:
                                                      Duration(seconds: 1),
                                                ),
                                              );
                                            },
                                          );
                                        }),
                                        child: Container(
                                          height: 30,
                                          width: 30,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              color: Colors.cyan,
                                              border: Border.all(
                                                  color: Colors.black)),
                                          child: Center(
                                              child: Text(
                                            '${gridList![index]['Number']}',
                                            style: TextStyle(
                                                fontSize: 25,
                                                color: Colors.white),
                                          )),
                                        ),
                                      )));
                    }),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
