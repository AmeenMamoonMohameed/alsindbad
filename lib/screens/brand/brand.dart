import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/utils/utils.dart';
import 'package:akarak/widgets/widget.dart';
import 'package:vibration/vibration.dart';

import '../../app.dart';
import '../../notificationservice_.dart';
import '../../widgets/widget.dart';

class Brand extends StatefulWidget {
  final int? categoryId;
  const Brand({Key? key, this.categoryId}) : super(key: key);

  @override
  _BrandState createState() {
    return _BrandState();
  }
}

class _BrandState extends State<Brand> {
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _onRefresh();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  ///On refresh list
  Future<void> _onRefresh() async {}

  ///On clear search
  void _onClearTapped() async {
    _textController.text = '';
    _onSearch('');
  }

  ///On navigate list product
  void _onProductList(BrandModel item) {
    Navigator.pushNamed(
      context,
      Routes.listProduct,
      arguments: {'brandId':item.id},
    );
  }

  ///On Search Brand
  void _onSearch(String text) {
    _onRefresh();
  }

  ///Build content list
  Widget _buildContentt(List<BrandModel>? brands) {
    if (brands != null && brands.isNotEmpty) {
      return GridView.count(
          crossAxisCount: 4,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 8.0,
          children: List.generate(brands.length, (index) {
            final item = brands[index];

            return InkWell(
              onTap: () {
                _onProductList(item);
              },
              child: CachedNetworkImage(
                imageUrl: (item.image == null || item.image!.isEmpty)
                    ? ""
                    : Application.domain +
                        item.image!
                            .replaceAll("\\", "/")
                            .replaceAll("TYPE", "thumb"),
                imageBuilder: (context, imageProvider) {
                  return Container(
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(8),
                      ),
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const <Widget>[
                        // Row(
                        //   children: <Widget>[
                        //     item!.status.isNotEmpty
                        //         ? Padding(
                        //             padding: const EdgeInsets.all(4),
                        //             child: AppTag(
                        //               item!.status,
                        //               type: TagType.status,
                        //             ),
                        //           )
                        //         : Container()
                        //   ],
                        // ),
                      ],
                    ),
                  );
                },
                placeholder: (context, url) {
                  return AppPlaceholder(
                    child: Container(
                      height: 120,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        ),
                        color: Colors.white,
                      ),
                    ),
                  );
                },
                errorWidget: (context, url, error) {
                  return AppPlaceholder(
                    child: Container(
                      height: 120,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        ),
                      ),
                      child: const Icon(Icons.error),
                    ),
                  );
                },
              ),
              // const SizedBox(height: 8),
              // Text(
              //   item?.category?.title ?? '',
              //   overflow: TextOverflow.ellipsis,
              //   style: Theme.of(context)
              //       .textTheme
              //       .caption!
              //       .copyWith(fontWeight: FontWeight.bold),
              // ),
              // const SizedBox(height: 4),
              // Text(
              //   item!.title,
              //   maxLines: 1,
              //   overflow: TextOverflow.ellipsis,
              //   style: Theme.of(context)
              //       .textTheme
              //       .subtitle2!
              //       .copyWith(fontWeight: FontWeight.bold),
              // ),
              // const SizedBox(height: 8),
              // Text(
              //   getPrice(),
              //   maxLines: 1,
              //   overflow: TextOverflow.ellipsis,
              //   style: Theme.of(context)
              //       .textTheme
              //       .subtitle2!
              //       .copyWith(fontWeight: FontWeight.bold),
              // ),
            );
          }));
    }
    return Container();
  }

  ///Build content list
  Widget _buildContent(List<BrandModel>? brands) {
    ///Success
    if (brands != null) {
      ///Empty
      if (brands.isEmpty) {
        return Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.sentiment_satisfied),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  Translate.of(context).translate(
                    'brand_not_found',
                  ),
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView.separated(
          itemCount: brands.length,
          separatorBuilder: (context, index) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(),
            );
          },
          itemBuilder: (context, index) {
            final item = brands[index];
            return AppBrand(
              type: BrandView.full,
              item: item,
              onPressed: () {
                _onProductList(item);
              },
            );
          },
        ),
      );
    }

    ///Loading
    return ListView.separated(
      itemCount: List.generate(8, (index) => index).length,
      separatorBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Divider(),
        );
      },
      itemBuilder: (context, index) {
        return const AppBrand(type: BrandView.full);
      },
    );
  }

  final scaffoldKey = GlobalKey<ScaffoldState>(debugLabel: "brandScreen");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.categoryId != null
            ? Application.submitSetting.categories
                .singleWhere((element) => element.id == widget.categoryId)
                .name
            : Translate.of(context).translate('brand')),
        actions: const <Widget>[],
      ),
      body: Column(
        children: <Widget>[
          const SizedBox(height: 16),
          AppTextInput(
            hintText: Translate.of(context).translate('search'),
            controller: _textController,
            trailing: GestureDetector(
              dragStartBehavior: DragStartBehavior.down,
              onTap: _onClearTapped,
              child: const Icon(Icons.clear),
            ),
            onSubmitted: _onSearch,
            onChanged: _onSearch,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: _buildContentt(Application.submitSetting.categories
                  .singleWhere((element) => element.id == widget.categoryId)
                  .brands),
            ),
          ),
        ],
      ),
    );
  }
}
