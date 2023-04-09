import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/utils/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../widgets/app_product_item.dart';
import '../../widgets/app_upload_image.dart';
import 'search_result_list.dart';
import 'search_suggest_list.dart';
import 'package:path/path.dart' as path;

class SearchHistory extends StatefulWidget {
  XFile? image;
  SearchHistory({Key? key, this.image}) : super(key: key);

  @override
  _SearchHistoryState createState() {
    return _SearchHistoryState(image: image);
  }
}

class _SearchHistoryState extends State<SearchHistory> {
  _SearchHistoryState({this.image});

  late SearchHistoryDelegate _delegate;
  final ImagePicker _imagePicker = ImagePicker();
  XFile? image;
  String? _bs4str;
  List<ProductModel> _history = [];

  @override
  void initState() {
    super.initState();
    _delegate = SearchHistoryDelegate();
    _loadHistory();
    if (image != null) {
      image!.readAsBytes().then((value) {
        _bs4str = base64Encode(value);
        Map<String, dynamic> params = {
          "externalId": "externalId",
          "fileName": image!.path.split('/').last,
          "extension": path.extension(image!.path),
          "uploadType": UploadType.product.index,
          "size": value.elementSizeInBytes,
          "data": _bs4str,
        };
        // UtilOther.buildFilterParams(FilterModel(upload: params));
        AppBloc.searchCubit.onSearchByFilter(FilterModel(byImage: params));
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  ///Load history
  void _loadHistory() async {
    List<String>? historyString = Preferences.getStringList(
      Preferences.search,
    );
    if (historyString != null) {
      _history = historyString.map((e) {
        return ProductModel.fromJson(
          jsonDecode(e),
          setting: Application.setting,
        );
      }).toList();
    }
    setState(() {});
  }

  ///onShow search
  void _onSearch() async {
    AppBloc.searchCubit.onClear();
    await showSearch(
      context: context,
      delegate: _delegate,
    );
  }

  void _onClear({ProductModel? item}) async {
    if (item == null) {
      await Preferences.setStringList(Preferences.search, []);
    } else {
      List<String>? historyString = Preferences.getStringList(
        Preferences.search,
      );
      if (historyString != null) {
        historyString.remove(jsonEncode(item.toJson()));
        await Preferences.setStringList(
          Preferences.search,
          historyString,
        );
      }
    }
    _loadHistory();
  }

  ///On navigate product detail
  void _onProductDetail(ProductModel item) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: AnimatedIcon(
              icon: AnimatedIcons.close_menu,
              progress: _delegate.transitionAnimation,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(Translate.of(context).translate('search_title')),
              if (_bs4str != null)
                Container(
                  constraints:
                      const BoxConstraints(minHeight: 30, minWidth: 30),
                  // width: 60,
                  // height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.5),
                    shape: BoxShape.rectangle,
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 40),
                    padding: const EdgeInsets.all(3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.memory(
                          height: 20,
                          width: 20,
                          base64Decode(_bs4str!),
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
                            image = null;
                            _bs4str = null;
                            setState(() {});
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
            ],
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _onSearch,
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadHistory,
            ),
            IconButton(
              icon: const Icon(Icons.camera_enhance),
              onPressed: () async {
                try {
                  image =
                      await _imagePicker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    Uint8List imageBytes = await image!.readAsBytes();
                    _bs4str = base64Encode(imageBytes);
                    Map<String, dynamic> params = {
                      "externalId": "externalId",
                      "fileName": image!.path.split('/').last,
                      "extension": path.extension(image!.path),
                      "uploadType": UploadType.product.index,
                      "size": imageBytes.elementSizeInBytes,
                      "data": _bs4str,
                    };
                    // UtilOther.buildFilterParams(FilterModel(upload: params));
                    AppBloc.searchCubit
                        .onSearchByFilter(FilterModel(byImage: params));
                    setState(() {});
                  }
                } catch (e) {}
              },
            ),
          ],
        ),
        body: BlocBuilder<SearchCubit, SearchState>(
          builder: (context, state) {
            if (_bs4str != null && state is SearchSuccess) {
              if (state.list.isEmpty) {
                return Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Icon(Icons.sentiment_satisfied),
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: Text(
                          Translate.of(context).translate(
                            'can_not_found_data',
                          ),
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                ),
                itemCount: state.list.length,
                itemBuilder: (context, index) {
                  final item = state.list[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: AppProductItem(
                      onPressed: () {
                        _onProductDetail(item);
                      },
                      item: item,
                      type: ProductViewType.small,
                    ),
                  );
                },
              );
            }
            if (_bs4str != null && state is SearchLoading) {
              return const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                  ),
                ),
              );
            }
            return SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            Translate.of(context).translate('search_history'),
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          InkWell(
                            onTap: () {
                              _onClear();
                            },
                            child: Text(
                              Translate.of(context).translate('clear'),
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2!
                                  .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      Wrap(
                        alignment: WrapAlignment.start,
                        spacing: 8,
                        children: _history.map((item) {
                          return InputChip(
                            onPressed: () {
                              _onProductDetail(item);
                            },
                            label: Text(item.name),
                            onDeleted: () {
                              _onClear(item: item);
                            },
                          );
                        }).toList(),
                      ),

                      // SingleChildScrollView()
                      // const ResultList(),
                    ],
                  ),
                ],
              ),
            );

            return Container();
          },
          // ),
        ));
  }
}

class SearchHistoryDelegate extends SearchDelegate<String> {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _image;
  String? _bs4str;

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, query);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    AppBloc.searchCubit.onSearch(query);
    return const SuggestionList();
  }

  @override
  Widget buildResults(BuildContext context) {
    return const ResultList();
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    if (query.isNotEmpty) {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
        IconButton(
          icon: const Icon(Icons.camera_enhance),
          onPressed: () async {
            try {
              _image =
                  await _imagePicker.pickImage(source: ImageSource.gallery);
              if (_image != null) {
                Uint8List imageBytes = await _image!.readAsBytes();
                _bs4str = base64Encode(imageBytes);
                Map<String, dynamic> params = {
                  "externalId": "externalId",
                  "fileName": _image!.path.split('/').last,
                  "extension": path.extension(_image!.path),
                  "uploadType": UploadType.product.index,
                  "size": imageBytes.elementSizeInBytes,
                  "data": _bs4str,
                };
                // UtilOther.buildFilterParams(FilterModel(upload: params));
                AppBloc.searchCubit
                    .onSearchByFilter(FilterModel(byImage: params));
              }
            } catch (e) {}
          },
        ),
      ];
    }
    return [];
  }
}
