import 'package:akarak/configs/application.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/utils/translate.dart';
import 'package:flutter/material.dart';

import '../../blocs/app_bloc.dart';
import '../../blocs/init/init_state.dart';
import '../../configs/routes.dart';
import '../widget.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({Key? key}) : super(key: key);

  @override
  State<MainDrawer> createState() => _MainDrawerState();

  void refreshMessagesCount() {
    _MainDrawerState();
  }
}

class _MainDrawerState extends State<MainDrawer> {
  bool _isCollapsed = false;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    List<Widget> listCategories = [];
    int c = 0;
    for (var item in Application.submitSetting.categories) {
      if (item.parentId == null) {
        c++;
        listCategories.add(
          CustomListTile(
            isCollapsed: _isCollapsed,
            iconUrl: item.iconUrl,
            color: item.color,
            title: item.name,
            description: item.description,
            infoCount: 0,
            doHaveMoreOptions: Icons.arrow_forward_ios,
            isAppBar: true,
            onTap: () async {
              if (item.type == CategoryType.main) {
                await Navigator.pushNamed(context, Routes.category,
                    arguments: item.id);
              } else {
                await Navigator.pushNamed(
                  context,
                  Routes.listProduct,
                  arguments: {'categoryId': item.id},
                );
              }
            },
          ),
        );
        if (c > 0) {
          listCategories.add(const SizedBox(height: 8));
          listCategories.add(const Divider(thickness: 1));
        }
      }
    }
    listCategories.add(
      CustomListTile(
        isCollapsed: _isCollapsed,
        icon: Icons.message_rounded,
        title: Translate.of(context).translate('messages'),
        infoCount: Application.newMessagesCount,
        isAppBar: true,
        onTap: () => Navigator.pushNamed(context, Routes.chatList),
      ),
    );

    return SafeArea(
      child: AnimatedContainer(
        curve: Curves.easeInOutCubic,
        duration: const Duration(milliseconds: 500),
        width: _isCollapsed ? 300 : 70,
        margin: _isCollapsed
            ? const EdgeInsets.only(bottom: 0, top: 0)
            : const EdgeInsets.only(bottom: 10, top: 10),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            bottomRight: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
          color: Theme.of(context).backgroundColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomDrawerHeader(isColapsed: _isCollapsed),
            SingleChildScrollView(
              controller: _scrollController,
              child: Container(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: listCategories,

                    // children: [
                    //   CustomDrawerHeader(isColapsed: _isCollapsed),
                    //   const Divider(
                    //     color: Colors.grey,
                    //   ),
                    //   CustomListTile(
                    //     isCollapsed: _isCollapsed,
                    //     icon: Icons.home_outlined,
                    //     title: 'Home',
                    //     infoCount: 0,
                    //   ),
                    //   CustomListTile(
                    //     isCollapsed: _isCollapsed,
                    //     icon: Icons.calendar_today,
                    //     title: 'Calender',
                    //     infoCount: 0,
                    //   ),
                    //   CustomListTile(
                    //     isCollapsed: _isCollapsed,
                    //     icon: Icons.pin_drop,
                    //     title: 'Destinations',
                    //     infoCount: 0,
                    //     doHaveMoreOptions: Icons.arrow_forward_ios,
                    //   ),
                    //   CustomListTile(
                    //     isCollapsed: _isCollapsed,
                    //     icon: Icons.message_rounded,
                    //     title: 'Messages',
                    //     infoCount: 8,
                    //   ),
                    //   CustomListTile(
                    //     isCollapsed: _isCollapsed,
                    //     icon: Icons.cloud,
                    //     title: 'Weather',
                    //     infoCount: 0,
                    //     doHaveMoreOptions: Icons.arrow_forward_ios,
                    //   ),
                    //   CustomListTile(
                    //     isCollapsed: _isCollapsed,
                    //     icon: Icons.airplane_ticket,
                    //     title: 'Flights',
                    //     infoCount: 0,
                    //     doHaveMoreOptions: Icons.arrow_forward_ios,
                    //   ),
                    //   const Divider(color: Colors.grey),
                    //   const Spacer(),
                    //   CustomListTile(
                    //     isCollapsed: _isCollapsed,
                    //     icon: Icons.notifications,
                    //     title: 'Notifications',
                    //     infoCount: 2,
                    //   ),
                    //   CustomListTile(
                    //     isCollapsed: _isCollapsed,
                    //     icon: Icons.settings,
                    //     title: 'Settings',
                    //     infoCount: 0,
                    //   ),
                    //   const SizedBox(height: 10),
                    //   BottomUserInfo(isCollapsed: _isCollapsed),
                    //   Align(
                    //     alignment: _isCollapsed
                    //         ? Alignment.bottomRight
                    //         : Alignment.bottomCenter,
                    //     child: IconButton(
                    //       splashColor: Colors.transparent,
                    //       icon: Icon(
                    //         _isCollapsed
                    //             ? Icons.arrow_back_ios
                    //             : Icons.arrow_forward_ios,
                    //         color: Colors.white,
                    //         size: 16,
                    //       ),
                    //       onPressed: () {
                    //         setState(() {
                    //           _isCollapsed = !_isCollapsed;
                    //         });
                    //       },
                    //     ),
                    //   ),
                    // ],
                  ),
                ),
              ),
            ),
            Align(
              alignment:
                  _isCollapsed ? Alignment.bottomRight : Alignment.bottomCenter,
              child: IconButton(
                splashColor: Colors.transparent,
                icon: Icon(
                  _isCollapsed ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 16,
                ),
                onPressed: () {
                  setState(() {
                    _isCollapsed = !_isCollapsed;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
