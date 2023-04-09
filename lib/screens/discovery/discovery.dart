import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_svprogresshud/flutter_svprogresshud.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/utils/utils.dart';
import 'package:akarak/widgets/widget.dart';
import 'package:vibration/vibration.dart';
import '../../models/model_feature.dart';
import '../../notificationservice_.dart';
import '../../widgets/widget.dart';

class Discovery extends StatefulWidget {
  final int? categoryId;
  final int? locationId;
  final int? featureId;

  const Discovery({Key? key, this.categoryId, this.locationId, this.featureId})
      : super(key: key);

  @override
  _DiscoveryState createState() {
    return _DiscoveryState();
  }
}

class _DiscoveryState extends State<Discovery> {
  // AppBloc.discoveryCubit
  // final _discoveryCubit = DiscoveryCubit();
  final _swipeController = SwiperController();
  final _scrollController = ScrollController();
  final _endReachedThreshold = 100;
  final _polylinePoints = PolylinePoints();
  final Map<PolylineId, Polyline> _polyLines = {};
  final List<LatLng> _polylineCoordinates = [];

  late StreamSubscription _wishlistSubscription;
  late StreamSubscription _reviewSubscription;

  GoogleMapController? _mapController;
  ProductModel? _currentItem;
  MapType _mapType = MapType.normal;
  PageType _pageType = PageType.map;
  ProductViewType _listMode = Application.setting.listMode;

  FilterModel _filter = FilterModel.fromDefault();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    if (widget.categoryId != null) {
      _filter.subCategory = Application.submitSetting.categories
          .singleWhere((item) => item.id == widget.categoryId!);
    }
    if (widget.featureId != null) {
      _filter.features?.add(widget.featureId!);
    }
    if (widget.locationId != null) {
      _filter.locationId = widget.locationId;
    }
    _wishlistSubscription = AppBloc.wishListCubit.stream.listen((state) {
      if (state is WishListSuccess && state.updateID != null) {
        AppBloc.discoveryCubit.onUpdate(state.updateID!);
      }
    });
    _reviewSubscription = AppBloc.reviewCubit.stream.listen((state) {
      if (state is ReviewByIdSuccess && state.productId != null) {
        AppBloc.discoveryCubit.onUpdate(state.productId!);
      }
    });
    // _onRefresh();
  }

  @override
  void dispose() {
    _wishlistSubscription.cancel();
    _reviewSubscription.cancel();
    _swipeController.dispose();
    _scrollController.dispose();
    _mapController?.dispose();
    // AppBloc.discoveryCubit.close();
    super.dispose();
  }

  ///Handle load more
  void _onScroll() {
    if (_scrollController.position.extentAfter > _endReachedThreshold) return;
    final state = AppBloc.discoveryCubit.state;
    if (state is DiscoverySuccess && state.canLoadMore && !state.loadingMore) {
      AppBloc.discoveryCubit.onLoadMore(_filter);
    }
  }

  ///On Refresh List
  Future<void> _onRefresh() async {
    await AppBloc.discoveryCubit.onLoad(_filter);
  }

  ///On Change Sort
  void _onChangeSort() async {
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
      setState(() {
        _filter.sortOptions = result;
      });
      _onRefresh();
    }
  }

  ///On Change Currency
  void _onChangeCurrency() async {
    final list = [
      CurrencyModel(
          id: 0,
          code: "",
          name: "default",
          isDefault: false,
          exchange: 0,
          countries: [])
    ];
    list.addAll(Application.submitSetting.currencies);
    // final list = Application.submitSetting.currencies;
    // list.add(CurrencyModel(
    //     id: 0,
    //     code: "",
    //     name: "name",
    //     isDefault: false,
    //     exchange: 0,
    //     countries: []));
    final result = await showModalBottomSheet<CurrencyModel?>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return AppBottomPicker(
          picker: PickerModel(
            selected: [Application.currentCurrency],
            data: list,
          ),
        );
      },
    );
    if (result != null) {
      setState(() {
        Application.currentCurrency = result;
      });
      _onRefresh();
    }
  }

  ///On Change View
  void _onChangeView() {
    ///Icon for MapType
    if (_pageType == PageType.map) {
      switch (_mapType) {
        case MapType.normal:
          _mapType = MapType.hybrid;
          break;
        case MapType.hybrid:
          _mapType = MapType.normal;
          break;
        default:
          _mapType = MapType.normal;
          break;
      }
    }

    switch (_listMode) {
      case ProductViewType.grid:
        _listMode = ProductViewType.list;
        break;
      case ProductViewType.list:
        _listMode = ProductViewType.block;
        break;
      case ProductViewType.block:
        _listMode = ProductViewType.grid;
        break;
      default:
        return;
    }
    setState(() {
      _listMode = _listMode;
      _mapType = _mapType;
    });
  }

  ///On change filter
  void _onChangeFilter() async {
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

  ///On change page
  void _onChangePageStyle() {
    switch (_pageType) {
      case PageType.list:
        setState(() {
          _pageType = PageType.map;
        });
        return;
      case PageType.map:
        setState(() {
          _pageType = PageType.list;
        });
        return;
    }
  }

  ///On tap marker map location
  void _onSelectLocation(int index) {
    _swipeController.move(index);
  }

  ///Handle Index change list map view
  void _onIndexChange(ProductModel item) {
    setState(() {
      _currentItem = item;
      _polyLines.clear();
    });

    ///Camera animated
    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            item.coordinate!.latitude,
            item.coordinate!.longitude,
          ),
          zoom: 15.0,
        ),
      ),
    );
  }

  ///On navigate product detail
  void _onProductDetail(ProductModel item) {
    if (item.category?.hasMap ?? false) {
      Navigator.pushNamed(
        context,
        Routes.productDetail,
        arguments: {"id": item.id, "categoryId": item.category?.id},
      );
    } else {
      Navigator.pushNamed(
        context,
        Routes.productScreen,
        arguments: {"id": item.id, "categoryId": item.category?.id},
      );
    }
  }

  ///On load direction
  void _onLoadDirection() async {
    final currentLocation = AppBloc.locationCubit.state;

    if (currentLocation != null && _currentItem != null) {
      SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.light);
      SVProgressHUD.show();
      final result = await _polylinePoints.getRouteBetweenCoordinates(
        Platform.isIOS ? Application.googleAPIIos : Application.googleAPI,
        PointLatLng(currentLocation.latitude, currentLocation.longitude),
        PointLatLng(
          _currentItem!.coordinate!.latitude,
          _currentItem!.coordinate!.longitude,
        ),
      );
      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          _polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
      } else {
        AppBloc.messageCubit.onShow('cannot_direction');
      }
      const id = PolylineId("poly1");
      if (!mounted) return;
      final polyline = Polyline(
        polylineId: id,
        color: Theme.of(context).primaryColor,
        points: _polylineCoordinates,
        width: 2,
      );
      setState(() {
        _polyLines[id] = polyline;
      });
      SVProgressHUD.dismiss();
    }
  }

  ///On focus current location
  void _onCurrentLocation() {
    final currentLocation = AppBloc.locationCubit.state;
    if (currentLocation != null) {
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              currentLocation.latitude,
              currentLocation.longitude,
            ),
            zoom: 15,
          ),
        ),
      );
    }
  }

  ///Export Icon for Mode View
  IconData _exportIconView() {
    ///Icon for MapType
    if (_pageType == PageType.map) {
      switch (_mapType) {
        case MapType.normal:
          return Icons.satellite;
        case MapType.hybrid:
          return Icons.map;
        default:
          return Icons.help;
      }
    }

    ///Icon for ListView Mode
    switch (_listMode) {
      case ProductViewType.list:
        return Icons.view_list;
      case ProductViewType.grid:
        return Icons.view_quilt;
      case ProductViewType.block:
        return Icons.view_array;
      default:
        return Icons.help;
    }
  }

  ///_build Item
  Widget _buildItem({
    ProductModel? item,
    required ProductViewType type,
  }) {
    switch (type) {
      case ProductViewType.list:
        if (item != null) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppProductItem(
              onPressed: () {
                _onProductDetail(item);
              },
              item: item,
              type: _listMode,
            ),
          );
        }
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AppProductItem(
            type: _listMode,
          ),
        );
      default:
        if (item != null) {
          return AppProductItem(
            onPressed: () {
              _onProductDetail(item);
            },
            item: item,
            type: _listMode,
          );
        }
        return AppProductItem(
          type: _listMode,
        );
    }
  }

  ///Build Content Page Style
  Widget _buildContent() {
    return BlocBuilder<DiscoveryCubit, DiscoveryState>(
      builder: (context, state) {
        /// List Style
        if (_pageType == PageType.list) {
          Widget contentList = ListView.builder(
            padding: const EdgeInsets.only(top: 8),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildItem(type: _listMode),
              );
            },
            itemCount: 8,
          );
          if (_listMode == ProductViewType.grid) {
            final size = MediaQuery.of(context).size;
            final left = MediaQuery.of(context).padding.left;
            final right = MediaQuery.of(context).padding.right;
            const itemHeight = 220;
            final itemWidth = (size.width - 48 - left - right) / 2;
            final ratio = itemWidth / itemHeight;
            contentList = GridView.count(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              crossAxisCount: 2,
              childAspectRatio: ratio,
              children: List.generate(8, (index) => index).map((item) {
                return _buildItem(type: _listMode);
              }).toList(),
            );
          }

          ///Build List
          if (state is DiscoverySuccess) {
            List list = List.from(state.list);
            if (state.loadingMore) {
              list.add(null);
            }
            contentList = RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(top: 8),
                itemBuilder: (context, index) {
                  final item = list[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildItem(item: item, type: _listMode),
                  );
                },
                itemCount: list.length,
              ),
            );
            if (_listMode == ProductViewType.grid) {
              final size = MediaQuery.of(context).size;
              final left = MediaQuery.of(context).padding.left;
              final right = MediaQuery.of(context).padding.right;
              const itemHeight = 220;
              final itemWidth = (size.width - 48 - left - right) / 2;
              final ratio = itemWidth / itemHeight;
              contentList = RefreshIndicator(
                onRefresh: _onRefresh,
                child: GridView.count(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  crossAxisCount: 2,
                  childAspectRatio: ratio,
                  children: list.map((item) {
                    return _buildItem(item: item, type: _listMode);
                  }).toList(),
                ),
              );
            }

            ///Build List empty
            if (state.list.isEmpty) {
              contentList = Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(Icons.sentiment_satisfied),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
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

          /// List
          return SafeArea(child: contentList);
        }

        ///Build Map
        if (state is DiscoverySuccess) {
          ///Default value map
          CameraPosition initPosition = const CameraPosition(
            target: LatLng(
              40.697403,
              -74.1201063,
            ),
            zoom: 14.4746,
          );
          Map<MarkerId, Marker> markers = {};

          ///Not build swipe and action when empty
          Widget list = Container();

          ///Build swipe if list not empty
          if (state.list.isNotEmpty) {
            initPosition = CameraPosition(
              target: LatLng(
                state.list[0].coordinate!.latitude,
                state.list[0].coordinate!.longitude,
              ),
              zoom: 14.4746,
            );

            ///Setup list marker map from list
            for (var item in state.list) {
              final markerId = MarkerId(item.id.toString());
              final marker = Marker(
                markerId: markerId,
                position: LatLng(
                  item.coordinate!.latitude,
                  item.coordinate!.longitude,
                ),
                infoWindow: InfoWindow(title: item.name),
                onTap: () {
                  _onSelectLocation(state.list.indexOf(item));
                },
              );
              markers[markerId] = marker;
            }

            ///build list map
            list = SafeArea(
              bottom: false,
              top: false,
              child: Container(
                height: 210,
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FloatingActionButton(
                            heroTag: 'directions',
                            mini: true,
                            onPressed: _onLoadDirection,
                            backgroundColor: Theme.of(context).cardColor,
                            child: Icon(
                              Icons.directions,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          FloatingActionButton(
                            heroTag: 'location',
                            mini: true,
                            onPressed: _onCurrentLocation,
                            backgroundColor: Theme.of(context).cardColor,
                            child: Icon(
                              Icons.location_on,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Swiper(
                        itemBuilder: (context, index) {
                          final ProductModel item = state.list[index];
                          bool selected = _currentItem == item;
                          if (index == 0 && _currentItem == null) {
                            selected = true;
                          }
                          return Container(
                            padding: const EdgeInsets.only(top: 4, bottom: 4),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).backgroundColor,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(8),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: selected
                                        ? Theme.of(context).primaryColor
                                        : Theme.of(context).dividerColor,
                                    blurRadius: 4,
                                    spreadRadius: 1.0,
                                    offset: const Offset(1.5, 1.5),
                                  )
                                ],
                              ),
                              child: AppProductItem(
                                onPressed: () {
                                  _onProductDetail(item);
                                },
                                item: item,
                                type: ProductViewType.list,
                              ),
                            ),
                          );
                        },
                        controller: _swipeController,
                        onIndexChanged: (index) {
                          final item = state.list[index];
                          _onIndexChange(item);
                        },
                        itemCount: state.list.length,
                        viewportFraction: 0.8,
                        scale: 0.9,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          ///build Map
          return Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              GoogleMap(
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                mapType: _mapType,
                initialCameraPosition: initPosition,
                markers: Set<Marker>.of(markers.values),
                polylines: Set<Polyline>.of(_polyLines.values),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
              ),
              list
            ],
          );
        }

        return Container();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // super.build(context);
    IconData iconAction = Icons.map;
    if (_pageType == PageType.map) {
      iconAction = Icons.view_compact;
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(Translate.of(context).translate('listing')),
        actions: <Widget>[
          BlocBuilder<DiscoveryCubit, DiscoveryState>(
            builder: (context, state) {
              return Visibility(
                visible: state is DiscoverySuccess,
                child: IconButton(
                  icon: Icon(iconAction),
                  onPressed: _onChangePageStyle,
                ),
              );
            },
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          AppNavBar(
            currentSort: _filter.sortOptions,
            onChangeSort: _onChangeSort,
            onChangeCurrency: _onChangeCurrency,
            iconModeView: _exportIconView(),
            onChangeView: _onChangeView,
            onFilter: _onChangeFilter,
            hasMap: _filter.subCategory?.hasMap ?? false,
          ),
          Expanded(
            child: _buildContent(),
          )
        ],
      ),
    );
  }
}
