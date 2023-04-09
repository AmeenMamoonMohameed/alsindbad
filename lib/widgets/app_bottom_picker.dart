import 'package:flutter/material.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/utils/utils.dart';
import 'package:akarak/widgets/widget.dart';

class AppBottomPicker extends StatelessWidget {
  final PickerModel picker;
  final bool? hasScroll;

  const AppBottomPicker({
    Key? key,
    required this.picker,
    this.hasScroll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (hasScroll == true) {
      return SafeArea(
          child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
                minHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: DraggableScrollableSheet(
                  initialChildSize: 1,
                  maxChildSize: 1,
                  minChildSize: 0.85,
                  builder: (context, scrollController) => SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.all(8),
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(8),
                                ),
                                color: Theme.of(context).dividerColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Column(
                              children: picker.data.map((item) {
                                Widget? trailing;
                                String title = '';
                                if (item is String) {
                                  title = item;
                                } else {
                                  try {
                                    title = Translate.of(context)
                                        .translate(item.title);
                                  } catch (e) {
                                    title = Translate.of(context)
                                        .translate(item.name);
                                  }
                                }
                                if (picker.selected.contains(item)) {
                                  trailing = Icon(
                                    Icons.check,
                                    color: Theme.of(context).primaryColor,
                                  );
                                }
                                if (item == picker.data.last) {
                                  return AppListTitle(
                                    title: title,
                                    trailing: trailing,
                                    border: false,
                                    onPressed: () {
                                      Navigator.pop(context, item);
                                    },
                                  );
                                }
                                return AppListTitle(
                                  title: Translate.of(context).translate(title),
                                  trailing: trailing,
                                  onPressed: () {
                                    Navigator.pop(context, item);
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ))));
    }
    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: IntrinsicHeight(
          child: Container(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(8),
                    ),
                    color: Theme.of(context).dividerColor,
                  ),
                ),
                Column(
                  children: picker.data.map((item) {
                    Widget? trailing;
                    String title = '';
                    if (item is String) {
                      title = item;
                    } else {
                      try {
                        title = Translate.of(context).translate(item.title);
                      } catch (e) {
                        title = Translate.of(context).translate(item.name);
                      }
                    }
                    if (picker.selected.contains(item)) {
                      trailing = Icon(
                        Icons.check,
                        color: Theme.of(context).primaryColor,
                      );
                    }
                    if (item == picker.data.last) {
                      return AppListTitle(
                        title: title,
                        trailing: trailing,
                        border: false,
                        onPressed: () {
                          Navigator.pop(context, item);
                        },
                      );
                    }
                    return AppListTitle(
                      title: Translate.of(context).translate(title),
                      trailing: trailing,
                      onPressed: () {
                        Navigator.pop(context, item);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
