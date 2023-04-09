import 'package:flutter/material.dart';

enum TagType { status, chip, rate, property }

class AppTag extends StatelessWidget {
  const AppTag(
    this.text, {
    Key? key,
    required this.type,
    this.color,
    this.icon,
    this.onPressed,
  }) : super(key: key);

  final String text;
  final TagType type;
  final Color? color;
  final Widget? icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = Container();
    if (icon != null) {
      if (type == TagType.property) {
        iconWidget = Row(
          children: [icon!, const SizedBox(width: 15)],
        );
      } else {
        iconWidget = Row(
          children: [icon!, const SizedBox(width: 8)],
        );
      }
    }
    switch (type) {
      case TagType.rate:
        return InkWell(
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(4),
              ),
            ),
            child: Text(
              text,
              style: Theme.of(context).textTheme.caption!.copyWith(
                    color: color ?? Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        );

      case TagType.status:
        return InkWell(
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.all(Radius.circular(4)),
            ),
            child: Text(
              text,
              style: Theme.of(context).textTheme.caption!.copyWith(
                  color: color ?? Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        );

      case TagType.chip:
        return InkWell(
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(16),
              ),
              color: Theme.of(context).dividerColor.withOpacity(0.07),
            ),
            child: Row(
              children: <Widget>[
                iconWidget,
                Text(
                  text,
                  style: Theme.of(context).textTheme.caption!.copyWith(
                        color: color ?? Theme.of(context).colorScheme.secondary,
                      ),
                )
              ],
            ),
          ),
        );

      case TagType.property:
        return InkWell(
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(16),
              ),
              color: Color(0xffffffff),
            ),
            child: Row(
              children: <Widget>[
                iconWidget,
                Divider(
                  key: key,
                  color: const Color(0xff000000),
                  thickness: 1,
                ),
                Text(
                  text,
                  style: Theme.of(context).textTheme.caption!.copyWith(
                        color: color ?? const Color(0xff000000),
                      ),
                )
              ],
            ),
          ),
        );
      default:
        return InkWell(
          onTap: onPressed,
          child: Container(),
        );
    }
  }
}
