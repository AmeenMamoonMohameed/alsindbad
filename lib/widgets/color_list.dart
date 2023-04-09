import 'package:akarak/app_properties.dart';
import 'package:akarak/configs/config.dart';
import 'package:flutter/material.dart';

class ColorList extends StatefulWidget {
  final List<Color> colorList;

  ColorList(this.colorList);

  @override
  _ColorListState createState() => _ColorListState();
}

class _ColorListState extends State<ColorList> {
  int active = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 75,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Color',
              style: TextStyle(color: Colors.white, shadows: shadow),
            ),
          ),
          Flexible(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.colorList.length,

              /// list of button colors based on colorList
              itemBuilder: (_, index) => InkWell(
                onTap: () {
                  setState(() {
                    active = index;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4.0, vertical: 8.0),

                  ///scale based on active color
                  child: Transform.scale(
                    scale: active == index ? 1.2 : 1,
                    child: ColorOption(widget.colorList[index]),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ColorOption extends StatelessWidget {
  final Color color;
  final double? height;
  final double? width;

  const ColorOption(this.color, {this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment:
          AppLanguage.isRTL() ? Alignment.centerRight : Alignment.centerLeft,
      width: width ?? 24,
      height: height ?? 24,
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          color: color),
    );
  }
}
