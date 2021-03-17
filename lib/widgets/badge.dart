import 'package:flutter/material.dart';

class Badge extends StatelessWidget {
  final String value;
  final Widget child;
  final Color color;

  const Badge({
    @required this.value,
    this.color,
    @required this.child,
  });
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            width: 16,
            height: 16,
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
              // shape: BoxShape.circle,
              borderRadius: BorderRadius.circular(8.0),
              color: color == null ? Theme.of(context).accentColor : color,
            ),
            constraints: BoxConstraints(maxHeight: 30, maxWidth: 30),
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10),
            ),
          ),
        ),
      ],
    );
  }
}
