import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../configs/application.dart';

class CustomListTile extends StatelessWidget {
  final bool isCollapsed;
  final Color? color;
  final IconData? icon;
  final String? iconUrl;
  final String title;
  final String? description;
  final IconData? doHaveMoreOptions;
  final int infoCount;
  final VoidCallback? onTap;
  final bool isAppBar;

  const CustomListTile({
    Key? key,
    required this.isCollapsed,
    this.color,
    this.icon,
    this.iconUrl,
    required this.title,
    this.description,
    this.doHaveMoreOptions,
    required this.infoCount,
    this.onTap,
    required this.isAppBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width;
    if (isAppBar) {
      width = isCollapsed ? 300 : 80;
    } else {
      width = double.infinity;
    }
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        width: width,
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    if (iconUrl != null)
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color ?? Colors.amberAccent,
                        ),
                        child: CachedNetworkImage(
                          imageUrl: Application.domain +
                              iconUrl!
                                  .replaceAll("\\", "/")
                                  .replaceAll("TYPE", "full"),
                          color: color ?? Colors.amberAccent,
                          colorBlendMode: BlendMode.color,
                          filterQuality: FilterQuality.high,
                          width: 24,
                          height: 24,
                        ),
                        // child: Icon(
                        //   item!.icon,
                        //   color: Colors.white,
                        //   size: 18,
                        // ),
                      ),
                    if (iconUrl == null)
                      Icon(
                        icon,
                        color: Theme.of(context).dividerColor.withOpacity(.8),
                      ),
                    if (infoCount > 0)
                      Positioned(
                        right: -5,
                        top: -5,
                        child: Container(
                          height: 10,
                          width: 10,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.red,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (isCollapsed) const SizedBox(width: 10),
            if (isCollapsed)
              Expanded(
                flex: 4,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .dividerColor
                                  .withOpacity(.8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                          ),
                          if (description?.isNotEmpty ?? false)
                            Text(
                              description!,
                              textAlign: TextAlign.start,
                              style: Theme.of(context).textTheme.caption,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    if (infoCount > 0)
                      Expanded(
                        flex: 2,
                        child: Container(
                          margin: const EdgeInsets.only(left: 10),
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.purple[200],
                          ),
                          child: Center(
                            child: Text(
                              infoCount.toString(),
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            if (isCollapsed && doHaveMoreOptions != null)
              const SizedBox(
                width: 5,
              ),
            if (isCollapsed && doHaveMoreOptions != null)
              Expanded(
                flex: 1,
                child: doHaveMoreOptions != null
                    ? IconButton(
                        icon: Icon(
                          doHaveMoreOptions,
                          color: Colors.black,
                          size: 12,
                        ),
                        onPressed: () {},
                      )
                    : const Center(),
              ),
          ],
        ),
      ),
    );
  }
}
