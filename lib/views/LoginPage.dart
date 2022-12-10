import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:griddeletion/views/HomePage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseFirestore _firebase = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool onpressed = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    onpressed = false;
  }

  final SnackBar _snackBar = const SnackBar(
    content: Text('Error! Please try again'),
    duration: Duration(seconds: 5),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: Text(
                    "Grid Assesment",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                )),
            const SizedBox(
              height: 100,
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(17)),
                  label: Text("Email"),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(17)),
                  label: const Text("Password"),
                ),
              ),
            ),
            SizedBox(
              height: 40,
            ),
            SizedBox(
              width: 160,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                    elevation: 5,
                    enableFeedback: true,
                    side: BorderSide()),
                onPressed: () async {
                  if (_emailController.text.isEmpty ||
                      _passwordController.text.isEmpty) {
                    print("inside if");
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('All Fields are compulsory'),
                      duration: Duration(seconds: 5),
                    ));
                  } else {
                    if (_passwordController.text.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Password needs to be > 6 character")));
                    } else {
                      try {
                        var lists =
                            await _firebaseAuth.fetchSignInMethodsForEmail(
                                _emailController.text.trim());
                        if (lists.length == 0) {
                          setState(() {
                            onpressed = true;
                          });
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text('Creating New Account'),
                            duration: Duration(seconds: 3),
                          ));
                          await _firebaseAuth
                              .createUserWithEmailAndPassword(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text)
                              .then((value) {
                            FirebaseFirestore.instance
                                .collection("Users")
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .collection("Grid_Sel")
                                .doc(0.toString())
                                .set({"Number": 1});
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) => HomePage()));
                          }).onError((error, stackTrace) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(_snackBar);
                          });
                        } else if (lists.length > 0) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text('Signing in'),
                            duration: Duration(seconds: 5),
                          ));
                          _firebaseAuth
                              .signInWithEmailAndPassword(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text)
                              .then((value) {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) => HomePage()));
                          }).onError((error, stackTrace) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(_snackBar);
                          });
                          setState(() {
                            onpressed = true;
                          });
                        }
                      } on FirebaseAuthException catch (e) {

                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Error ${e.code} please try again'),
                          duration: Duration(seconds: 5),
                        ));
                      }
                    }
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    onpressed == true
                        ? const CircularProgressIndicator()
                        : const Text(
                            "Login",
                            style: TextStyle(color: Colors.black, fontSize: 24),
                          ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
