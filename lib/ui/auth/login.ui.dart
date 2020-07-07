import 'package:crime_app/core/data/welcome.data.dart';
import 'package:crime_app/ui/app/crime_map.ui.dart';
import 'package:crime_app/ui/auth/slide.ui.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginUi extends StatefulWidget {
  @override
  _LoginUiState createState() => _LoginUiState();
}

class _LoginUiState extends State<LoginUi> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<String> signInWithGoogle() async {
    final GoogleSignInAccount googleSignInAccount =
        await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final AuthResult authResult = await _auth.signInWithCredential(credential);
    final FirebaseUser user = authResult.user;

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    return 'signInWithGoogle succeeded: $user';
  }

  void signOutGoogle() async {
    await _googleSignIn.signOut();

    print("User Sign Out");
  }

  // Welcome Screen
  List<Widget> slides = welcomeItems
      .map((item) => Container(
              child: Slide(
            text: item.title,
            image: item.image,
          )))
      .toList();

  List<Widget> indicator() => List<Widget>.generate(
      slides.length,
      (index) => Container(
            margin: EdgeInsets.symmetric(horizontal: 3.0),
            height: 6.0,
            width: 6.0,
            decoration: BoxDecoration(
                color: currentPage.round() == index
                    ? Color(0XFF26263D)
                    : Color(0XFF26263D).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10.0)),
          ));

  double currentPage = 0.0;
  final _pageViewController = new PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
              flex: 4,
              child: Container(
                decoration: BoxDecoration(
                    // gradient: LinearGradient(
                    //     colors: [primary, Colors.white],
                    //     begin: Alignment.topCenter,
                    //     end: Alignment.bottomCenter),
                    ),
                child: PageView.builder(
                  physics: BouncingScrollPhysics(),
                  controller: _pageViewController,
                  itemCount: slides.length,
                  itemBuilder: (BuildContext context, int index) {
                    _pageViewController.addListener(() {
                      setState(() {
                        currentPage = _pageViewController.page;
                      });
                    });
                    return slides[index];
                  },
                ),
              )),
              Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: indicator(),
                    ),
                  ),
          Expanded(
              flex: 1,
              child: Center(
                child: Container(
                    child: SizedBox(
                  width: double.infinity,
                  child: RaisedButton(
                    padding: EdgeInsets.all(20.0),
                    color: Color(0xFF26263D),
                    textColor: Colors.white,
                    onPressed: () {
                      signInWithGoogle()
                          .whenComplete(() => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return CrimeMap();
                                  },
                                ),
                              ));
                    },
                    child: Text('Get Started'),
                  ),
                )),
              ))
          // Container(
          //   child: RaisedButton(
          //     onPressed: () {
          //       signOutGoogle();
          //     },
          //     child: Text('data'),
          //   ),
          // )
        ],
      ),
    ));
  }
}
