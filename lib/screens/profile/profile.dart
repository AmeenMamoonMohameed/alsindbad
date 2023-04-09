import 'dart:async';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/repository/repository.dart';
import 'package:akarak/screens/profile/profile_header.dart';
import 'package:akarak/screens/profile/profile_tab.dart';
import 'package:akarak/utils/utils.dart';
import 'package:akarak/widgets/widget.dart';
import 'package:share/share.dart';
import 'package:vibration/vibration.dart';

import '../../notificationservice_.dart';
import '../../widgets/widget.dart';

class Profile extends StatefulWidget {
  final String userId;
  const Profile({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfileState createState() {
    return _ProfileState();
  }
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  late StreamSubscription _submitSubscription;
  late StreamSubscription _reviewSubscription;
  final _profileCubit = ProfileCubit();
  final _scrollController = ScrollController();
  final _textSearchController = TextEditingController();
  final _endReachedThreshold = 100;
  // final String Link = 'https://flutterfiretests.page.link/MEGs';

  bool _isOwner = false;
  FilterModel _filter = FilterModel.fromDefault();
  TabController? _tabController;
  int _indexTab = 0;
  UserModel? user;

  @override
  void initState() {
    super.initState();
    _isOwner = widget.userId == AppBloc.userCubit.state?.userId;
    _tabController = TabController(length: _isOwner ? 3 : 2, vsync: this);
    _scrollController.addListener(_onScroll);
    _submitSubscription = AppBloc.submitCubit.stream.listen((state) {
      if (state is Submitted) {
        _onRefresh();
      }
    });
    _reviewSubscription = AppBloc.reviewCubit.stream.listen((state) {
      if (state is ReviewByIdSuccess && state.productId != null) {
        _onRefresh();
      }
    });
    _onRefresh();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _submitSubscription.cancel();
    _reviewSubscription.cancel();
    _profileCubit.close();
    _scrollController.dispose();
    _textSearchController.dispose();
    super.dispose();
  }

  ///On Refresh
  Future<void> _onRefresh() async {
    _profileCubit.onLoad(
      filter: _filter,
      searchString: _textSearchController.text,
      userID: widget.userId,
      indexTab: _indexTab,
    );
  }

  ///Handle load more
  void _onScroll() {
    if (_scrollController.position.extentAfter > _endReachedThreshold) return;
    final state = _profileCubit.state;
    if (state is ProfileSuccess && state.canLoadMore && !state.loadingMore) {
      _profileCubit.onLoadMore(
        filter: _filter,
        keyword: _textSearchController.text,
        userID: widget.userId,
        indexTab: _indexTab,
      );
    }
  }

  ///On Change Tab
  void _onTap(int index) {
    setState(() {
      _indexTab = index;
    });
    _onRefresh();
  }

  ///On Search
  void _onSearch(String text) {
    _profileCubit.onSearch(
      filter: _filter,
      keyword: _textSearchController.text,
      userID: widget.userId,
      indexTab: _indexTab,
    );
  }

  ///On Preview Profile
  void _onProfile(UserModel user) {
    Navigator.pushNamed(context, Routes.profile, arguments: user.userId);
  }

  ///On Scan QR
  // void _onQRCode() async {
  //   final result = await Navigator.pushNamed(
  //     context,
  //     Routes.profileQRCode,
  //     arguments: widget.user,
  //   );
  //   if (result != null && result is UserModel) {
  //     await Future.delayed(const Duration(milliseconds: 500));
  //     _onProfile(result);
  //   }
  // }

  ///On change filter
  void _onFilter() async {
    final result = await Navigator.pushNamed(
      context,
      Routes.filter,
      arguments: _filter.clone(),
    );
    if (result != null && result is FilterModel) {
      setState(() {
        _filter = result;
      });
      _onRefresh();
    }
  }

  ///On Change Sort
  void _onSort() async {
    final result = await showModalBottomSheet<SortModel?>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return AppBottomPicker(
          picker: PickerModel(
            selected: [_filter.sortOptions],
            data: Application.setting.sortOptions,
          ),
        );
      },
    );
    if (result != null) {
      _filter.sortOptions = result;
      _onRefresh();
    }
  }

  ///Action Item
  void _onSheetAction(ProductModel item) async {
    final result = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        Widget orderItem = Container();
        Widget editItem = Container();
        Widget removeItem = Container();
        // if (item.orderUse) {
        //   orderItem = AppListTitle(
        //     title: Translate.of(context).translate("order"),
        //     leading: const Icon(Icons.pending_actions_outlined),
        //     onPressed: () {
        //       Navigator.pop(context, "order");
        //     },
        //   );
        // }
        if (_isOwner) {
          editItem = AppListTitle(
            title: Translate.of(context).translate("edit"),
            leading: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.pop(context, "edit");
            },
          );
          removeItem = AppListTitle(
            title: Translate.of(context).translate("remove"),
            leading: const Icon(Icons.delete_outline),
            onPressed: () {
              Navigator.pop(context, "remove");
            },
          );
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
                      children: [
                        orderItem,
                        editItem,
                        removeItem,
                        AppListTitle(
                          title: Translate.of(context).translate("share"),
                          leading: const Icon(Icons.share_outlined),
                          onPressed: () {
                            Navigator.pop(context, "share");
                          },
                          border: false,
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (!mounted) return;

    switch (result) {
      // case "order":
      //   Navigator.pushNamed(
      //     context,
      //     Routes.order,
      //     arguments: item.id,
      //   );
      //   break;
      case "remove":
        _onRemove(item);
        break;
      case "share":
        _onShare(item);
        break;
      case "edit":
        _onEdit(item);
        break;
      default:
        break;
    }
  }

  ///On Remove
  void _onRemove(ProductModel item) async {
    await ListRepository.removeProduct(item.id);
    _onRefresh();
  }

  ///On Share
  Future<void> _onShare(ProductModel item) async {
    Share.share(
      await UtilOther.createDynamicLink(
          "${Application.dynamicLink}/product/${item.category!.id}/${item.id}",
          false),
      // 'Check out my item ${item.link}',
      subject: 'ArmaSoft',
    );
  }

  ///On Edit
  void _onEdit(ProductModel item) {
    Navigator.pushNamed(
      context,
      Routes.submit,
      arguments: item,
    );
  }

  Future<void> _onAction(CommentModel item, BuildContext context) async {
    final result = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        Widget orderItem = Container();
        // if (item.orderUse) {
        //   orderItem = AppListTitle(
        //     title: Translate.of(context).translate("order"),
        //     leading: const Icon(Icons.pending_actions_outlined),
        //     onPressed: () {
        //       Navigator.pop(context, "order");
        //     },
        //   );
        // }
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
                      children: [
                        orderItem,
                        if (AppBloc.userCubit.state!.userId == widget.userId &&
                            item.reviewType == ReviewType.review &&
                            (item.replaies != null &&
                                !item.replaies!.any((element) =>
                                    element.createdBy.userId ==
                                    AppBloc.userCubit.state!.userId)))
                          AppListTitle(
                            title: Translate.of(context).translate("replay"),
                            leading: const Icon(Icons.share_outlined),
                            onPressed: () {
                              Navigator.pop(context, "replay");
                            },
                            border: false,
                          ),
                        if (AppBloc.userCubit.state!.userId ==
                            item.createdBy.userId)
                          AppListTitle(
                            title: Translate.of(context).translate("edit"),
                            leading: const Icon(Icons.share_outlined),
                            onPressed: () {
                              Navigator.pop(context, "edit");
                            },
                            border: false,
                          ),
                        if (AppBloc.userCubit.state!.userId ==
                            item.createdBy.userId)
                          AppListTitle(
                            title: Translate.of(context).translate("remove"),
                            leading: const Icon(Icons.delete_outline),
                            onPressed: () {
                              Navigator.pop(context, "remove");
                            },
                          ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    if (result == 'replay') {
      await Navigator.pushNamed(
        context,
        Routes.feedback,
        arguments: {
          'productId': item.productId,
          'review': item,
          'type': 'replay'
        },
      );
    }

    if (result == 'edit') {
      if (AppBloc.userCubit.state == null) {
        final result = await Navigator.pushNamed(
          context,
          Routes.signIn,
          arguments: Routes.feedback,
        );
        if (result != Routes.feedback) {
          return;
        }
      }
      await Navigator.pushNamed(
        context,
        Routes.feedback,
        arguments: {
          'productId': item.productId,
          'review': item,
          'type': 'edit'
        },
      );
    }
    if (result == 'remove') {
      await AppBloc.reviewCubit.onRemove(
          productId: item.productId, id: item.id, type: item.reviewType);
      await _onRefresh();
    }
  }

  ///On navigate product detail
  void _onProductDetail(ProductModel item) {
    if (item.createdBy != null &&
        item.createdBy!.userId == AppBloc.userCubit.state?.userId) {
      Navigator.pushNamed(context, Routes.submit, arguments: item);
    } else {
      Navigator.pushNamed(
        context,
        Routes.productDetail,
        arguments: {"id": item.id, "categoryId": item.category?.id},
      );
    }
  }

  ///On navigate submit form
  void _onSubmit() {
    Navigator.pushNamed(context, Routes.submit);
  }

  ///Build Content
  Widget _buildContent({
    List<ProductModel>? listProduct,
    List<ProductModel>? listProductPending,
    List<CommentModel>? listComment,
    required bool loadingMore,
  }) {
    ///Loading List Product
    Widget content = SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: AppProductItem(type: ProductViewType.small),
          );
        },
        childCount: 15,
      ),
    );

    ///Loading List Review
    if (_indexTab == 2) {
      content = SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: AppCommentItem(),
            );
          },
          childCount: 15,
        ),
      );
    }

    ///Build List Product
    if (listProduct != null && _indexTab == 0) {
      List list = List.from(listProduct);

      ///Empty List
      content = SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(Icons.sentiment_satisfied),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Text(
                    Translate.of(context).translate('list_is_empty'),
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      if (loadingMore) {
        list.add(null);
      }
      if (list.isNotEmpty) {
        content = SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item = list[index];

              ///Listing
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: AppProductItem(
                  item: item,
                  type: AppBloc.userCubit.state?.userId == user?.userId
                      ? ProductViewType.smallWithViews
                      : ProductViewType.small,
                  trailing: IconButton(
                    icon: const Icon(Icons.more_vert_outlined),
                    onPressed: () {
                      _onSheetAction(item);
                    },
                  ),
                  onPressed: () {
                    _onProductDetail(item);
                  },
                ),
              );
            },
            childCount: list.length,
          ),
        );
      }
    }

    ///Build List Product Pending
    if (widget.userId == AppBloc.userCubit.state!.userId &&
        listProductPending != null &&
        _indexTab == 1) {
      List list = List.from(listProductPending);

      ///Empty List
      content = SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(Icons.sentiment_satisfied),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Text(
                    Translate.of(context).translate('list_is_empty'),
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      if (loadingMore) {
        list.add(null);
      }
      if (list.isNotEmpty) {
        content = SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item = list[index];

              ///Listing
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onTertiary,
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                  ),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.only(
                        left: AppLanguage.isRTL() ? 10 : 0,
                        right: AppLanguage.isRTL() ? 0 : 10),
                    title: AppProductItem(
                      item: item,
                      type: ProductViewType.pending,
                      onPressed: () {
                        _onProductDetail(item);
                      },
                    ),
                    children: <Widget>[
                      Text(
                        item!.statusNote ?? '',
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .caption!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                // AppProductItem(
                //   item: item,
                //   type: ProductViewType.pending,
                //   onPressed: () {
                //     _onProductDetail(item);
                //   },
                // ),
              );
            },
            childCount: list.length,
          ),
        );
      }
    }

    ///Build List Comment
    if (((widget.userId != AppBloc.userCubit.state!.userId && _indexTab == 1) ||
            _indexTab == 2) &&
        listComment != null) {
      List list = List.from(listComment);

      ///Empty List
      content = SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(Icons.sentiment_satisfied),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Text(
                    Translate.of(context).translate('list_is_empty'),
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      if (loadingMore) {
        list.add(null);
      }
      if (list.isNotEmpty) {
        content = SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item = list[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: AppCommentItem(
                  item: item,
                  onPressUser: () {
                    _onProfile(item.createdBy);
                  },
                  // onAction: ,
                  showProductName: true,
                ),
              );
            },
            childCount: list.length,
          ),
        );
      }
    }

    return content;
  }

  ///On report product
  void _onReport(
    BuildContext context_,
  ) async {
    if (!AppBloc.userCubit.state!.phoneNumberConfirmed) {
      UtilOther.showMessage(
        context: context,
        title: Translate.of(context).translate('confirm_phone_number'),
        message: Translate.of(context)
            .translate('the_phone_number_must_be_confirmed_first'),
        func: () {
          Navigator.of(context).pop();
          Navigator.pushNamed(
            context,
            Routes.otp,
            arguments: {
              "userId": AppBloc.userCubit.state!.userId,
              "routeName": null
            },
          );
        },
        funcName: Translate.of(context).translate('confirm'),
      );
      return;
    }
    String? errorTitle;
    String? errorDescription;
    await showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String? title;
        String? description;
        return AlertDialog(
          title: Text(
            Translate.of(context).translate('report'),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  Translate.of(context)
                      .translate('specify_the_main_reason_for_reporting'),
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                const SizedBox(height: 8),
                AppTextInput(
                  maxLines: 2,
                  errorText: errorTitle,
                  hintText: errorTitle ??
                      Translate.of(context).translate('report_title'),
                  controller: TextEditingController(),
                  textInputAction: TextInputAction.done,
                  onChanged: (text) {
                    setState(() {
                      title = text;
                      errorTitle =
                          UtilValidator.validate(text, allowEmpty: false);
                    });
                  },
                ),
                const SizedBox(height: 8),
                AppTextInput(
                  maxLines: 10,
                  errorText: errorDescription,
                  hintText: errorDescription ??
                      Translate.of(context).translate('report_description'),
                  controller: TextEditingController(),
                  textInputAction: TextInputAction.done,
                  onChanged: (text) {
                    setState(() {
                      description = text;
                      errorDescription =
                          UtilValidator.validate(text, allowEmpty: false);
                    });
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            AppButton(
              Translate.of(context).translate('cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
              type: ButtonType.text,
            ),
            AppButton(
              Translate.of(context).translate('confirm'),
              onPressed: () async {
                errorTitle =
                    UtilValidator.validate(title ?? "", allowEmpty: false);
                errorDescription = UtilValidator.validate(description ?? "",
                    allowEmpty: false);
                setState(() {});
                if (errorTitle == null && errorDescription == null) {
                  Navigator.pop(context, description);
                  final result = await ChatRepository.sendReport(ReportModel(
                      reportedId: widget.userId,
                      name: title!,
                      description: description!,
                      type: ReportType.profile));
                  if (result == true) {
                    AppBloc.messageCubit.onShow(Translate.of(context_)
                        .translate('the_message_has_been_sent'));
                  } else {
                    AppBloc.messageCubit.onShow(Translate.of(context_)
                        .translate(
                            'an_error_occurred,_the_message_was_not_sent'));
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  final scaffoldKey = GlobalKey<ScaffoldState>(debugLabel: "profileScreen");

  @override
  Widget build(BuildContext context) {
    List<Widget> action = [];

    return BlocProvider(
      create: (context) => _profileCubit,
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, profile) {
          List<ProductModel>? listProduct;
          List<ProductModel>? listProductPending;
          List<CommentModel>? listComment;
          bool showFilter = (_indexTab == 0 || (_indexTab == 1 && _isOwner));
          List<Widget> tabs = [
            Tab(text: Translate.of(context).translate('listing')),
            Tab(text: Translate.of(context).translate('review')),
          ];

          bool loadingMore = false;
          if (profile is ProfileSuccess) {
            user = profile.user;
            listProduct = profile.listProduct;
            listProductPending = profile.listProductPending;
            listComment = profile.listComment;
            loadingMore = profile.loadingMore;
          }
          action = [
            if (_isOwner)
              AppButton(
                Translate.of(context).translate('add'),
                onPressed: _onSubmit,
                type: ButtonType.text,
              ),
            if (!_isOwner)
              IconButton(
                color: Theme.of(context).errorColor,
                icon: const Icon(Icons.flag_outlined),
                onPressed: () {
                  _onReport(context);
                },
              ),
          ];
          if (AppBloc.userCubit.state?.userId == widget.userId) {
            tabs = [
              Tab(text: Translate.of(context).translate('listing')),
              Tab(text: Translate.of(context).translate('pending')),
              Tab(text: Translate.of(context).translate('review')),
            ];
          }

          return Scaffold(
            key: scaffoldKey,
            body: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: <Widget>[
                SliverAppBar(
                  centerTitle: true,
                  title: Text(
                    Translate.of(context).translate('profile'),
                  ),
                  actions: action,
                  pinned: true,
                ),
                SliverPersistentHeader(
                  delegate: ProfileHeader(
                    height: 100,
                    user: user,
                    showQR: _isOwner,
                    // onQRCode: _onQRCode,
                  ),
                  floating: false,
                  pinned: false,
                ),
                SliverPersistentHeader(
                  delegate: ProfileTab(
                    height: 160,
                    showFilter: showFilter,
                    tabs: tabs,
                    showPending: _isOwner,
                    tabController: _tabController,
                    onTap: _onTap,
                    textSearchController: _textSearchController,
                    onSearch: _onSearch,
                    onFilter: _onFilter,
                    onSort: _onSort,
                  ),
                  pinned: true,
                  floating: false,
                ),
                CupertinoSliverRefreshControl(
                  onRefresh: _onRefresh,
                ),
                SliverSafeArea(
                  top: false,
                  sliver: SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    sliver: _buildContent(
                      listProduct: listProduct,
                      listProductPending: listProductPending,
                      listComment: listComment,
                      loadingMore: loadingMore,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
