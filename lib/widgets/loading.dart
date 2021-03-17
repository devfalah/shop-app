import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitFadingCircle(
        color: Theme.of(context).primaryColor,
        size: 100.0,
        duration: Duration(
          milliseconds: 1200,
        ),
      ),
    );
  }
}
