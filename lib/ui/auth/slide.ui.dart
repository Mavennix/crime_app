import 'package:flutter/material.dart';

class Slide extends StatelessWidget {
  final String text;
  final String image;

  const Slide({Key key, this.text, this.image}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
          flex: 5,
          child: Container(
            child: Image.asset(
              image,
              // fit: BoxFit.contain,
            ),
            // color: Colors.blue,
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width / 25,
            ),
            child: Column(
              children: <Widget>[
                Text(
                  text,
                  style: Theme.of(context)
                      .textTheme
                      .title
                      .copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
