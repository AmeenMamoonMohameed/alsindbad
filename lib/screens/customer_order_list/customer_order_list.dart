import 'dart:async';

import 'package:akarak/app_properties.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/models/model_order.dart';
import 'package:akarak/models/model_picker.dart';
import 'package:akarak/models/model_sort.dart';
import 'package:akarak/repository/repository.dart';
import 'package:akarak/utils/other.dart';
import 'package:akarak/utils/translate.dart';
import 'package:akarak/widgets/shop_item_list.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../widgets/widget.dart';

class CustomerOrderList extends StatefulWidget {
  const CustomerOrderList({Key? key}) : super(key: key);

  @override
  _CustomerOrderListState createState() => _CustomerOrderListState();
}

class _CustomerOrderListState extends State<CustomerOrderList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ShowCaseWidget(
        builder: Builder(
          builder: (context) => const CustomerOrderListChild(),
        ),
      ),
    );
  }
}

class CustomerOrderListChild extends StatefulWidget {
  const CustomerOrderListChild({Key? key}) : super(key: key);

  @override
  _CustomerOrderListChildState createState() => _CustomerOrderListChildState();
}

class _CustomerOrderListChildState extends State<CustomerOrderListChild> {
  SwiperController swiperController = SwiperController();
  final customerOrderListCubit = CustomerOrderListCubit();
  final _textSearchController = TextEditingController();
  final _scrollController = ScrollController();
  final _endReachedThreshold = 100;

  Timer? _timer;
  SortModel? _sort;
  SortModel? _status;
  bool _isVisibleSearch = false;

  @override
  void initState() {
    super.initState();
    _onRefresh();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _textSearchController.clear();
    // AppBloc.orderListCubit.close();
    customerOrderListCubit.close();
    swiperController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  ///On Refresh List
  Future<void> _onRefresh() async {
    return await customerOrderListCubit.onLoad(
      sort: _sort,
      orderStatus: _status != null && _status?.value != null
          ? OrderStatus.values[_status?.value as int]
          : null,
      searchString: _textSearchController.text,
    );
  }

  ///Handle load more
  void _onScroll() {
    if (_scrollController.position.extentAfter > _endReachedThreshold) return;
    final state = customerOrderListCubit.state;
    if (state is CustomerOrderListSuccess &&
        state.canLoadMore &&
        !state.loadingMore) {
      customerOrderListCubit.onLoadMore(
        sort: _sort,
        orderStatus: _status != null && _status?.value != null
            ? OrderStatus.values[_status?.value as int]
            : null,
        searchString: _textSearchController.text,
      );
    }
  }

  ///On Search
  void _onSearch(String? keyword) {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 1000), () {
      customerOrderListCubit.onLoad(
        sort: _sort,
        orderStatus: _status != null && _status?.value != null
            ? OrderStatus.values[_status?.value as int]
            : null,
        searchString: keyword,
      );
    });
  }

  ///On Sort
  void _onSort() async {
    if (customerOrderListCubit.sortOption.isEmpty) return;
    final result = await showModalBottomSheet<SortModel?>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return AppBottomPicker(
          picker: PickerModel(
            selected: [_sort],
            data: customerOrderListCubit.sortOption,
          ),
        );
      },
    );
    if (result != null) {
      setState(() {
        _sort = result;
      });
      _onRefresh();
    }
  }

  ///On Filter
  void _onFilter() async {
    if (customerOrderListCubit.statusOption.isEmpty) return;
    final result = await showModalBottomSheet<SortModel?>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return AppBottomPicker(
          picker: PickerModel(
            selected: [_status],
            data: customerOrderListCubit.statusOption,
          ),
        );
      },
    );
    if (result != null) {
      setState(() {
        _status = result;
      });
      _onRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => customerOrderListCubit,
        child: BlocBuilder<CustomerOrderListCubit, CustomerOrderListState>(
            builder: (context, state) {
          Widget  content = AppPlaceholder(
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Card(
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: 5,
                        right: AppLanguage.isRTL() ? 10 : 0,
                        left: AppLanguage.isRTL() ? 0 : 10),
                    child: Wrap(
                      children: [
                        Container(
                          height: 15,
                          width: 30,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 5),
                        Container(
                          height: 15,
                          width: 30,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 5),
                        Container(
                          height: 15,
                          width: 30,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 90,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 90,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 90,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 90,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 90,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 90,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 90,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );

          if (state is CustomerOrderListSuccess) {
            content = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  height: 48.0,
                  color: yellow,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        Translate.of(context).translate('awaitingApproval'),
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      Text(
                        AppLanguage.isRTL()
                            ? '${Translate.of(context).translate('items')}: ${state.countAwaitingApproval}'
                            : '${state.countAwaitingApproval} :${Translate.of(context).translate('items')}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Visibility(
                  visible: _isVisibleSearch,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: AppTextInput(
                      hintText: Translate.of(context).translate('search'),
                      controller: _textSearchController,
                      onChanged: _onSearch,
                      onSubmitted: _onSearch,
                      trailing: GestureDetector(
                        dragStartBehavior: DragStartBehavior.down,
                        onTap: () {
                          _textSearchController.clear();
                          _isVisibleSearch = false;
                          setState(() {});
                          _onSearch(null);
                        },
                        child: const Icon(
                          Icons.search_off_outlined,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: _onFilter,
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              width: 1,
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.track_changes_outlined,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                Translate.of(context).translate('filter'),
                                style: Theme.of(context).textTheme.caption,
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: _onSort,
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              width: 1,
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.sort_outlined,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                Translate.of(context).translate('sort'),
                                style: Theme.of(context).textTheme.caption,
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: () {
                          _isVisibleSearch = !_isVisibleSearch;
                          setState(() {});
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              width: 1,
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search_outlined,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                Translate.of(context).translate('search'),
                                style: Theme.of(context).textTheme.caption,
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (state.list.isNotEmpty)
                  Container(
                    height: MediaQuery.of(context).size.height -
                        ((MediaQuery.of(context).size.height * 0.2) +
                            (_isVisibleSearch ? 100 : 48)),
                    color: Theme.of(context).colorScheme.tertiary,
                    child: Scrollbar(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemBuilder: (_, index) => CustomerOrder(
                          state.list[index],
                          isShowCase: index == 0,
                          onOutStockOrder: () {
                            UtilOther.showMessage(
                              context: context,
                              title:
                                  Translate.of(context).translate('_confirm'),
                              message: Translate.of(context).translate(
                                  'confirming_out_of_stock_and_notifying_the_customer'),
                              func: () {
                                Navigator.pop(context);
                                customerOrderListCubit.onOutStockOrder(
                                  itemId: state.list[index].id,
                                  message: "message",
                                );
                              },
                              funcName:
                                  Translate.of(context).translate('confirm'),
                            );
                          },
                          onAcceptanceRefund: () {
                            UtilOther.showMessage(
                              context: context,
                              title:
                                  Translate.of(context).translate('_confirm'),
                              message: Translate.of(context).translate(
                                  'confirm_acceptance_of_the_refund'),
                              func: () {
                                Navigator.pop(context);
                                Navigator.pushNamed(
                                  context,
                                  Routes.checkOutRefund,
                                  arguments: state.list[index].id,
                                ).then((value) {
                                  if (value == true) {
                                    _onRefresh();
                                  }
                                });
                              },
                              funcName:
                                  Translate.of(context).translate('confirm'),
                            );
                          },
                          onRefuseRefund: () {
                            UtilOther.showMessage(
                              context: context,
                              title:
                                  Translate.of(context).translate('_confirm'),
                              message: Translate.of(context)
                                  .translate('confirm_reject_refund'),
                              func: () {
                                Navigator.pop(context);
                                CustomerOrderRepository.confirmRefuseRefund(
                                        orderItemId: state.list[index].id)
                                    .then((value) {
                                  _onRefresh();
                                });
                              },
                              funcName:
                                  Translate.of(context).translate('confirm'),
                            );
                          },
                          onConfirmCustomerOrder: () {
                            UtilOther.showMessage(
                              context: context,
                              title:
                                  Translate.of(context).translate('_confirm'),
                              message: Translate.of(context).translate(
                                  'confirmation_that_the_customer_order_has_been_processed'),
                              func: () {
                                Navigator.pop(context);
                                customerOrderListCubit.onConfirmCustomerOrder(
                                    itemId: state.list[index].id);
                              },
                              funcName:
                                  Translate.of(context).translate('confirm'),
                            );
                          },
                        ),
                        itemCount: state.list.length,
                      ),
                    ),
                  ),
                // const SizedBox(height: 24),
              ],
            );
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                iconTheme: const IconThemeData(color: darkGrey),
                actions: const <Widget>[],
                title: Text(
                  Translate.of(context).translate('customers_orders'),
                  style: const TextStyle(
                      color: darkGrey,
                      fontWeight: FontWeight.w500,
                      fontSize: 18.0),
                ),
              ),
              body: LayoutBuilder(
                builder: (_, constraints) => SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: content),
                ),
              ),
            );
          }

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              iconTheme: const IconThemeData(color: darkGrey),
              actions: const <Widget>[
                // IconButton(
                //   icon: Image.asset(Images.commercialInvoices),
                //   onPressed: () {
                //     Navigator.pushNamed(
                //       context,
                //       Routes.orderDetail,
                //       arguments: widget.arguments,
                //     );
                //   },
                //   // onPressed: () => Navigator.of(context)
                //   //     .push(MaterialPageRoute(builder: (_) => UnpaidPage())),
                // )
              ],
              title: Text(
                Translate.of(context).translate('order_details'),
                style: const TextStyle(
                    color: darkGrey,
                    fontWeight: FontWeight.w500,
                    fontSize: 18.0),
              ),
            ),
            body: LayoutBuilder(
              builder: (_, constraints) => SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: content),
              ),
            ),
          );
        }));
  }
}
