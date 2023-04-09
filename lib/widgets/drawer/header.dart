import 'package:flutter/material.dart';

import '../../configs/routes.dart';

class CustomDrawerHeader extends StatelessWidget {
  final bool isColapsed;

  const CustomDrawerHeader({
    Key? key,
    required this.isColapsed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
      ),
      duration: const Duration(milliseconds: 500),
      height: 60,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // const FlutterLogo(size: 30),
          if (!isColapsed)
            Text(
              "A",
              style: Theme.of(context).textTheme.headline6!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).backgroundColor),
            ),
          if (isColapsed) const SizedBox(width: 10),
          if (isColapsed)
            Expanded(
              flex: 3,
              child: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.headline6!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).backgroundColor),
                  children: <TextSpan>[
                    const TextSpan(
                      text: "akarak",
                    ),
                    TextSpan(
                      text: ".ONLINE",
                      style: Theme.of(context).textTheme.headline6!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ],
                ),
              ),
            ),
          if (isColapsed) const Spacer(),
          if (isColapsed)
            Expanded(
              flex: 1,
              child: IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, Routes.searchHistory);
                },
                icon: const Icon(
                  Icons.search,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
