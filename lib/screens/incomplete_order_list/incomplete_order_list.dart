import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/utils/utils.dart';
import 'package:akarak/widgets/widget.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../main.dart';

class IncompleteOrderList extends StatefulWidget {
  const IncompleteOrderList({Key? key}) : super(key: key);

  @override
  _IncompleteOrderListState createState() {
    return _IncompleteOrderListState();
  }
}

class _IncompleteOrderListState extends State<IncompleteOrderList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ShowCaseWidget(
        builder: Builder(
          builder: (context) => const IncompleteOrderListChild(),
        ),
      ),
    );
  }
}

class IncompleteOrderListChild extends StatefulWidget {
  const IncompleteOrderListChild({Key? key}) : super(key: key);

  @override
  _IncompleteOrderListChildState createState() {
    return _IncompleteOrderListChildState();
  }
}

class _IncompleteOrderListChildState extends State<IncompleteOrderListChild> {
  final _incompleteOrderList = OrderListCubit();
  final _textSearchController = TextEditingController();
  final _scrollController = ScrollController();
  final _endReachedThreshold = 100;

  Timer? _timer;
  SortModel? _sort;
  SortModel? _status;

  final GlobalKey _slidableItemKey = GlobalKey();
  // GlobalKey _cartIndicatorKey = GlobalKey();
  // GlobalKey _searchKey = GlobalKey();
  // GlobalKey _categoriesKey = GlobalKey();
  // GlobalKey _nameKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _onRefresh();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => ShowCaseWidget.of(context).startShowCase([
              _slidableItemKey,
              // _cartIndicatorKey,
              // _nameKey,
              // _searchKey,
              // _categoriesKey
            ]));
  }

  @override
  void dispose() {
    _incompleteOrderList.close();
    _textSearchController.clear();
    super.dispose();
  }

  ///On Refresh List
  Future<void> _onRefresh() async {
    return await _incompleteOrderList.onLoad(
      sort: _sort,
      searchString: _textSearchController.text,
      orderStatus: OrderStatus.order,
    );
  }

  ///Handle load more
  void _onScroll() {
    if (_scrollController.position.extentAfter > _endReachedThreshold) return;
    final state = _incompleteOrderList.state;
    if (state is OrderListSuccess && state.canLoadMore && !state.loadingMore) {
      _incompleteOrderList.onLoadMore(
        sort: _sort,
        searchString: _textSearchController.text,
        orderStatus: OrderStatus.order,
      );
    }
  }

  ///On Search
  void _onSearch(String? keyword) {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 1500), () {
      _incompleteOrderList.onLoad(
        sort: _sort,
        searchString: keyword,
        orderStatus: OrderStatus.order,
      );
    });
  }

  ///On Check Out
  void _onCheckOut(int id) {
    Navigator.pushNamed(
      context,
      Routes.checkOut,
      arguments: id,
    ).then((value) {
      _onRefresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    // displayShowcase() async {
    //   bool showcaseVisibilityStatus =
    //       Preferences.getBool("showShowcase") ?? true;

    //   if (showcaseVisibilityStatus == null) {
    //     Preferences.setBool("showShowcase", false).then((bool success) {
    //       if (success)
    //         print("Successfull in writing showshoexase");
    //       else
    //         print("some bloody problem occured");
    //     });

    //     return true;
    //   }

    //   return false;
    // }

    // displayShowcase().then((status) {
    //   // if (status) {
    //   ShowCaseWidget.of(context).startShowCase([
    //     _optionsKey,
    //     _cartIndicatorKey,
    //     _nameKey,
    //     _searchKey,
    //     _categoriesKey
    //   ]);
    //   // }
    // });

    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text(Translate.of(context).translate('unpaid_orders'))),
      body: BlocBuilder<OrderListCubit, OrderListState>(
        bloc: _incompleteOrderList,
        builder: (context, state) {
          Widget content = ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) {
              return const AppOrderItem();
            },
            itemCount: 15,
          );
          if (state is OrderListSuccess) {
            if (state.list.isEmpty) {
              content = Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(Icons.sentiment_satisfied),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        Translate.of(context).translate(
                          'data_not_found',
                        ),
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              int count = state.list.length;
              if (state.loadingMore) {
                count = count + 1;
              }

              content = ListView.builder(
                controller: _scrollController,
                itemCount: state.list.length,
                itemBuilder: (context, index) {
                  var item = state.list[index];
                  // var item = blockedUsersCubit.list.isNotEmpty ?  blockedUsersCubit.list[index] : null;
                  return Showcase(
                    key: GlobalKey(),
                    // key: _slidableItemKey,
                    description: Translate.of(context).translate(
                        'to_display_the_options_drag_the_item_from_left_to_right_and_opposite'),
                    // showcaseBackgroundColor: Colors.yellow[100],
                    descTextStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.yellowAccent[900]),
                    child: Slidable(
                      key: ValueKey(item.orderId),
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            flex: 2,
                            onPressed: (BuildContext? buildContext) {
                              // blockedUsersCubit.unblockUser(item.id);
                              UtilOther.showMessage(
                                context: context,
                                title: Translate.of(context)
                                    .translate('cancellation_confirmation'),
                                message: Translate.of(context).translate(
                                    'are_you_sure_to_cancel_the_order'),
                                func: () {
                                  Navigator.of(context).pop();
                                  _incompleteOrderList.onCancel(item.orderId);
                                  setState(() {});
                                },
                                funcName:
                                    Translate.of(context).translate('confirm'),
                              );
                              // setState(() {});
                            },
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.cancel,
                            label: Translate.of(context).translate('cancel'),
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                                width: 1,
                                color: Theme.of(context).colorScheme.tertiary),
                            bottom: BorderSide(
                                width: 1,
                                color: Theme.of(context)
                                    .colorScheme
                                    .tertiaryContainer),
                          ),
                          color: Colors.white,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: AppOrderItem(
                            order: item,
                            onPressed: () {
                              _onCheckOut(item.orderId);
                              // _onDetail(item.orderId);
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  AppTextInput(
                    hintText: Translate.of(context).translate('search'),
                    controller: _textSearchController,
                    onChanged: _onSearch,
                    onSubmitted: _onSearch,
                    trailing: GestureDetector(
                      dragStartBehavior: DragStartBehavior.down,
                      onTap: () {
                        _textSearchController.clear();
                        _onSearch(null);
                      },
                      child: const Icon(Icons.clear),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: content,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
