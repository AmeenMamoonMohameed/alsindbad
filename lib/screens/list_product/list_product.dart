import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_svprogresshud/flutter_svprogresshud.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/utils/utils.dart';
import 'package:akarak/widgets/widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import '../../models/model_feature.dart';
import '../../models/model_location.dart';
import '../../widgets/widget.dart';

class ListProduct extends StatefulWidget {
  final int? categoryId;
  final int? brandId;
  final int? locationId;
  final int? featureId;

  const ListProduct(
      {Key? key,
      this.categoryId,
      this.brandId,
      this.locationId,
      this.featureId})
      : super(key: key);

  @override
  _ListProductState createState() {
    return _ListProductState();
  }
}

class _ListProductState extends State<ListProduct> {
  final _listCubit = ListCubit();
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
  PageType _pageType = PageType.list;
  ProductViewType _listMode = Application.setting.listMode;

  bool _isRefreshing = true;
  FilterModel _filter = FilterModel.fromDefault();
  Timer? timer;
  final _textSearchStringController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();
  XFile? _image;
  Uint8List? _bytes;
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    if (widget.categoryId != null) {
      _filter.subCategory = Application.submitSetting.categories
          .singleWhere((item) => item.id == widget.categoryId!);
    }
    if (widget.brandId != null) {
      _filter.subCategory = Application.submitSetting.categories.singleWhere(
          (item) =>
              item.brands != null &&
              item.brands!.any((element) => element.id == widget.brandId));
      _filter.brand = _filter.subCategory?.brands!
          .singleWhere((item) => item.id == widget.brandId);
    }
    if (widget.featureId != null) {
      _filter.features!.add(widget.featureId!);
    }
    if (widget.locationId != null) {
      _filter.locationId = widget.locationId;
    }
    _wishlistSubscription = AppBloc.wishListCubit.stream.listen((state) {
      if (state is WishListSuccess && state.updateID != null) {
        _listCubit.onUpdate(state.updateID!);
      }
    });
    _reviewSubscription = AppBloc.reviewCubit.stream.listen((state) {
      if (state is ReviewByIdSuccess && state.productId != null) {
        _listCubit.onUpdate(state.productId!);
      }
    });
    _onRefresh();
  }

  @override
  void dispose() {
    _wishlistSubscription.cancel();
    _reviewSubscription.cancel();
    _swipeController.dispose();
    _scrollController.dispose();
    _mapController?.dispose();
    _listCubit.close();
    _textSearchStringController.dispose();
    super.dispose();
  }

  ///Handle load more
  void _onScroll() {
    if (_scrollController.position.extentAfter > _endReachedThreshold) return;
    final state = _listCubit.state;
    if (state is ListSuccess && state.canLoadMore && !state.loadingMore) {
      _listCubit.onLoadMore(_filter);
    }
  }

  ///On Refresh List
  Future<void> _onRefresh() async {
    _isRefreshing = true;
    await _listCubit.onLoad(_filter).then((value) {
      _isRefreshing = false;
    });
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
    final result = await showModalBottomSheet<CurrencyModel?>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return AppBottomPicker(
          picker: PickerModel(
            selected: [Application.currentCurrency],
            data: Application.submitSetting.currencies,
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
  List<Widget> _buildCategories() {
    if (_filter.subCategory == null) {
      return [];
    }

    List<Widget> list = [];

    final listLabels = Application.submitSetting.categories
        .where((e) => e.parentId == _filter.subCategory!.id);
    list.addAll(listLabels.map((item) {
      final selected = _filter.category == item;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: SizedBox(
          height: 32,
          child: FilterChip(
            backgroundColor: Theme.of(context).dividerColor,
            selectedColor: Theme.of(context).dividerColor.withOpacity(0.3),
            selected: selected,
            label: Text(item.name),
            onSelected: (check) {
              if (check) {
                _filter.category = item;
              } else {
                _filter.category = null;
              }
              setState(() {});
              UtilOther.hiddenKeyboard(context);
              _onRefresh();
            },
          ),
        ),
      );
    }).toList());

    return list;
  }

  ///Build Content Page Style
  Widget _buildContent() {
    return BlocBuilder<ListCubit, ListState>(
      builder: (context, state) {
        /// List Style
        if (_pageType == PageType.list) {
          Widget contentList = _isRefreshing
              ? ListView.builder(
                  padding: const EdgeInsets.only(top: 8),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildItem(type: _listMode),
                    );
                  },
                  itemCount: 8,
                )
              : Container();
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
          if (state is ListSuccess) {
            List list = List.from(state.list);
            if (state.loadingMore) {
              list.add(null);
            }
            contentList = RefreshIndicator(
              triggerMode: RefreshIndicatorTriggerMode.anywhere,
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
        if (state is ListSuccess) {
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
    IconData iconAction = Icons.map;
    if (_pageType == PageType.map) {
      iconAction = Icons.view_compact;
    }
    List<Widget> categories = [
      Container(
        width: MediaQuery.of(context).size.width * 0.5,
        height: 40,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).dividerColor.withOpacity(.07),
            borderRadius: const BorderRadius.all(
              Radius.circular(8),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(1),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: AppTextInput(
                        color: Theme.of(context).dividerColor.withOpacity(.07),
                        hintText: Translate.of(context).translate('search'),
                        controller: _textSearchStringController,
                        textInputAction: TextInputAction.done,
                        onChanged: (text) {
                          _filter.searchString = text;
                          timer?.cancel();
                          timer = Timer(const Duration(milliseconds: 500),
                              () async {
                            _onRefresh();
                          });
                          setState(() {});
                        },
                        trailing: _filter.searchString != null &&
                                _filter.searchString!.isNotEmpty
                            ? GestureDetector(
                                dragStartBehavior: DragStartBehavior.down,
                                onTap: () {
                                  _textSearchStringController.clear();
                                  _filter.searchString = null;
                                  _onRefresh();
                                  setState(() {});
                                },
                                child:
                                    const Icon(Icons.clear, color: Colors.red),
                              )
                            : null),
                  ),
                  IconButton(
                    onPressed: () async {
                      try {
                        await _imagePicker
                            .pickImage(source: ImageSource.gallery)
                            .then((value) async {
                          if (value != null) {
                            _image = value;
                            _bytes = await value.readAsBytes();
                            // _isRefreshing = true;
                            final bs4str = base64Encode(_bytes!);
                            Map<String, dynamic> params = {
                              "externalId": "externalId",
                              "fileName": _image!.path.split('/').last,
                              "extension": path.extension(_image!.path),
                              "uploadType": UploadType.product.index,
                              "size": _bytes!.elementSizeInBytes,
                              "data": bs4str,
                            };
                            _filter.byImage = params;

                            _onRefresh();
                            setState(() {});
                          }
                        });
                      } catch (e) {}
                    },
                    icon: const Icon(
                      Icons.camera_enhance,
                      color: Colors.black,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      )
    ];

    if (_image != null) {
      categories.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 40),
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor.withOpacity(0.07),
              borderRadius: const BorderRadius.all(
                Radius.circular(8),
              ),
            ),
            padding: const EdgeInsets.all(3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.memory(
                  height: 20,
                  width: 20,
                  _bytes!,
                  fit: BoxFit.fill,
                ),
                // const Icon(
                //   Icons.photo,
                //   size: 20,
                // ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    Translate.of(context).translate('image'),
                    style: Theme.of(context).textTheme.caption,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  color: Colors.red,
                  onPressed: () {
                    _image = null;
                    _bytes = null;
                    _filter.byImage = null;
                    setState(() {});
                    _onRefresh();
                  },
                  icon: const Icon(
                    Icons.close,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    categories.addAll(_buildCategories());

    return BlocProvider(
      create: (context) => _listCubit,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Application.scaffoldKey.currentState?.openDrawer(),
          ),
          centerTitle: true,
          title: Text(Translate.of(context).translate('listing')),
          actions: <Widget>[
            BlocBuilder<ListCubit, ListState>(
              builder: (context, state) {
                return Visibility(
                  visible: state is ListSuccess,
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  // spacing: 8,
                  // runSpacing: 8,
                  children: categories),
            ),
            Expanded(
              child: _buildContent(),
            )
          ],
        ),
      ),
    );
  }
}
