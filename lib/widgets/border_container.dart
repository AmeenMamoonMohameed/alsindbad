import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BorderContainer extends StatefulWidget {
  final int value;

  const BorderContainer({Key? key, required this.value}) : super(key: key);

  @override
  _BorderContainerState createState() => _BorderContainerState();
}

class _BorderContainerState extends State<BorderContainer> {
  bool isTapped = false;

  @override
  Widget build(BuildContext context) {
    var innerBorder = Border.all(
        width: 1.0,
        color: isTapped
            ? Colors.grey.withOpacity(0)
            : Colors.grey.withOpacity(0.3));

    var outerBorder = Border.all(
        width: 3.0, color: isTapped ? Colors.grey : Colors.grey.withOpacity(0));

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            border: outerBorder, borderRadius: BorderRadius.circular(16)),
        child: GestureDetector(
          onTapDown: (TapDownDetails details) => setState(() {
            isTapped = true;
          }),
          onTapUp: (TapUpDetails details) => setState(() {
            isTapped = false;
          }),
          child: Container(
              decoration: BoxDecoration(
                  border: innerBorder, borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    Text('${widget.value}'),
                    Text('Another item in container number: ${widget.value}')
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
