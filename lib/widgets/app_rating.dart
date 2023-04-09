import 'package:flutter/material.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/utils/utils.dart';
import 'package:akarak/widgets/app_placeholder.dart';

class AppRating extends StatelessWidget {
  final RateModel? rate;

  const AppRating({
    Key? key,
    this.rate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (rate == null) {
      return AppPlaceholder(
        child: Row(
          children: <Widget>[
            Column(
              children: <Widget>[
                Text(
                  "0.0",
                  style: Theme.of(context)
                      .textTheme
                      .headline2!
                      .copyWith(color: Theme.of(context).primaryColor),
                ),
                Text(
                  "${Translate.of(context).translate('out_of')} 0",
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 60,
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [1, 2, 3, 4, 5].map((item) {
                            return const Icon(
                              Icons.star,
                              size: 12,
                            );
                          }).toList(),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          margin: const EdgeInsets.only(left: 8),
                          height: 4,
                          decoration: BoxDecoration(
                            color: Theme.of(context).dividerColor,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(4),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        width: 60,
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [1, 2, 3, 4].map((item) {
                            return const Icon(
                              Icons.star,
                              size: 12,
                            );
                          }).toList(),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          margin: const EdgeInsets.only(left: 8),
                          height: 4,
                          decoration: BoxDecoration(
                            color: Theme.of(context).dividerColor,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(4),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        width: 60,
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [1, 2, 3].map((item) {
                            return const Icon(
                              Icons.star,
                              size: 12,
                            );
                          }).toList(),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          margin: const EdgeInsets.only(left: 8),
                          height: 4,
                          decoration: BoxDecoration(
                            color: Theme.of(context).dividerColor,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(4),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        width: 60,
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [1, 2].map((item) {
                            return const Icon(
                              Icons.star,
                              size: 12,
                            );
                          }).toList(),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          margin: const EdgeInsets.only(left: 8),
                          height: 4,
                          decoration: BoxDecoration(
                            color: Theme.of(context).dividerColor,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(4),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        width: 60,
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [1].map((item) {
                            return const Icon(
                              Icons.star,
                              size: 12,
                            );
                          }).toList(),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          margin: const EdgeInsets.only(left: 8),
                          height: 4,
                          decoration: BoxDecoration(
                            color: Theme.of(context).dividerColor,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(4),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        "Loading",
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      );
    }

    return Row(
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "${rate!.avg}",
              style: Theme.of(context)
                  .textTheme
                  .headline2!
                  .copyWith(color: Theme.of(context).primaryColor),
            ),
            Text(
              "${Translate.of(context).translate('out_of')} 5",
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 60,
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [1, 2, 3, 4, 5].map((item) {
                        return const Icon(
                          Icons.star,
                          size: 12,
                          color: Colors.green,
                        );
                      }).toList(),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      margin: const EdgeInsets.only(left: 8),
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).dividerColor,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(4),
                        ),
                      ),
                      child: rate!.five > 0
                          ? FractionallySizedBox(
                              widthFactor: rate!.five,
                              child: Container(
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(4),
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                    ),
                  )
                ],
              ),
              Row(
                children: <Widget>[
                  Container(
                    width: 60,
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [1, 2, 3, 4].map((item) {
                        return Icon(Icons.star,
                            size: 12, color: Colors.green.withOpacity(0.5));
                      }).toList(),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      margin: const EdgeInsets.only(left: 8),
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).dividerColor,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(4),
                        ),
                      ),
                      child: rate!.four > 0
                          ? FractionallySizedBox(
                              widthFactor: rate!.four,
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.5),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(4),
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                    ),
                  )
                ],
              ),
              Row(
                children: <Widget>[
                  Container(
                    width: 60,
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [1, 2, 3].map((item) {
                        return const Icon(
                          Icons.star,
                          size: 12,
                          color: Colors.yellow,
                        );
                      }).toList(),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      margin: const EdgeInsets.only(left: 8),
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).dividerColor,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(4),
                        ),
                      ),
                      child: rate!.three > 0
                          ? FractionallySizedBox(
                              widthFactor: rate!.three,
                              child: Container(
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: Colors.yellow,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(4),
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                    ),
                  )
                ],
              ),
              Row(
                children: <Widget>[
                  Container(
                    width: 60,
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [1, 2].map((item) {
                        return const Icon(
                          Icons.star,
                          size: 12,
                          color: Colors.orange,
                        );
                      }).toList(),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      margin: const EdgeInsets.only(left: 8),
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).dividerColor,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(4),
                        ),
                      ),
                      child: rate!.two > 0
                          ? FractionallySizedBox(
                              widthFactor: rate!.two,
                              child: Container(
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(4),
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                    ),
                  )
                ],
              ),
              Row(
                children: <Widget>[
                  Container(
                    width: 60,
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [1].map((item) {
                        return const Icon(
                          Icons.star,
                          size: 12,
                          color: Colors.red,
                        );
                      }).toList(),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      margin: const EdgeInsets.only(left: 8),
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).dividerColor,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(4),
                        ),
                      ),
                      child: rate!.one > 0
                          ? FractionallySizedBox(
                              widthFactor: rate!.one,
                              child: Container(
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(4),
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    "${rate!.total} ${Translate.of(context).translate('reviews')}",
                    style: Theme.of(context)
                        .textTheme
                        .subtitle2!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}
