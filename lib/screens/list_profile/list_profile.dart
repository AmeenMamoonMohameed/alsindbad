import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/app_bloc.dart';
import '../../blocs/bloc.dart';
import '../../blocs/profile_list/profile_list_state.dart';
import '../../configs/application.dart';
import '../../configs/routes.dart';
import '../../models/model.dart';
import '../../utils/translate.dart';
import '../../widgets/widget.dart';
import '../../widgets/widget.dart';

class ListProfile extends StatefulWidget {
  final UserType userType;
  const ListProfile({Key? key, required this.userType}) : super(key: key);

  @override
  _ListProfileState createState() {
    return _ListProfileState();
  }
}

class _ListProfileState extends State<ListProfile> {
  final _scrollController = ScrollController();
  final _endReachedThreshold = 500;
  final _textPickerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    AppBloc.profileListCubit.userType = widget.userType;
    _onRefresh();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textPickerController.dispose();
    super.dispose();
  }

  ///Handle load more
  void _onScroll() {
    if (_scrollController.position.extentAfter > _endReachedThreshold) return;
    final state = AppBloc.profileListCubit.state;
    if (state is ProfileListSuccess &&
        state.canLoadMore &&
        !state.loadingMore) {
      AppBloc.profileListCubit.onLoadMore();
    }
  }

  ///On refresh
  Future<void> _onRefresh() async {
    await AppBloc.profileListCubit.onLoad();
  }

  ///On Search
  Future<void> _onSearch(String text) async {
    setState(() {
      AppBloc.profileListCubit.keyword = text;
    });
    _onRefresh();
  }

  ///On navigate product detail
  Future<void> _onProfile(UserModel item) async {
    Navigator.pushNamed(context, Routes.profile, arguments: item.userId);
  }

  final scaffoldKey = GlobalKey<ScaffoldState>(debugLabel: "listProfileScreen");

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileListCubit, ProfileListState>(
      builder: (context, state) {
        ///Loading
        Widget content = RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView.builder(
            padding: const EdgeInsets.only(left: 16, top: 16, bottom: 28),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: AppUserInfo(
                    type: widget.userType == UserType.company
                        ? UserViewType.company
                        : UserViewType.company),
              );
            },
            itemCount: 8,
          ),
        );

        ///Success
        if (state is ProfileListSuccess) {
          int count = state.list.length;
          if (state.loadingMore) {
            count = count + 1;
          }
          content = Column(children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16),
              child: AppTextInput(
                hintText: Translate.of(context).translate('search'),
                onChanged: _onSearch,
                onSubmitted: _onSearch,
                controller: _textPickerController,
                trailing: GestureDetector(
                  dragStartBehavior: DragStartBehavior.down,
                  onTap: () {
                    _textPickerController.clear();
                  },
                  child: const Icon(Icons.clear),
                ),
              ),
            ),
            Expanded(
                child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: _scrollController,
                padding: const EdgeInsets.only(
                  left: 16,
                  top: 16,
                  bottom: 28,
                ),
                itemCount: count,
                itemBuilder: (context, index) {
                  ///Loading loadMore item
                  if (index == state.list.length) {
                    return Padding(
                        padding: const EdgeInsets.only(
                            bottom: 16, right: 8, left: 8),
                        child: AppUserInfo(
                            type: widget.userType == UserType.company
                                ? UserViewType.company
                                : UserViewType.company));
                  }

                  final item = state.list[index];
                  return Padding(
                    padding:
                        const EdgeInsets.only(bottom: 8, right: 8, left: 8),
                    child: AppUserInfo(
                      user: UserModel.fromJson({
                        'id': item.userId,
                        'userName': item.userName,
                        'profilePictureDataUrl': item.profilePictureDataUrl,
                        'accountName': item.accountName,
                        'fullName': item.fullName,
                        'countryCode': item.countryCode,
                        'phoneNumber': item.phoneNumber,
                      }),
                      type: widget.userType == UserType.company
                          ? UserViewType.company
                          : UserViewType.company,
                      onPressed: () async {
                        await _onProfile(item);
                      },
                    ),
                  );
                },
              ),
            ))
          ]);

          ///Empty
          if (state.list.isEmpty) {
            content = Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(Icons.sentiment_satisfied),
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      Translate.of(context).translate('list_is_empty'),
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ),
                ],
              ),
            );
          }
        }
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => scaffoldKey.currentState?.openDrawer(),
            ),
            centerTitle: true,
            title: Text(Translate.of(context).translate(
                widget.userType == UserType.company
                    ? 'companies_list'
                    : 'offices_list')),
            actions: const <Widget>[
              // icon
            ],
          ),
          body: SafeArea(
            child: content,
          ),
        );
      },
    );
  }
}
