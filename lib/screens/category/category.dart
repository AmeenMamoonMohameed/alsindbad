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

class Category extends StatefulWidget {
  final int? parentId;
  const Category({Key? key, this.parentId}) : super(key: key);

  @override
  _CategoryState createState() {
    return _CategoryState();
  }
}

class _CategoryState extends State<Category> {
  final _categoryCubit = CategoryCubit();
  final _textController = TextEditingController();

  CategoryView? _type;

  @override
  void initState() {
    super.initState();
    _categoryCubit.parentId = widget.parentId;
    _onRefresh();
  }

  @override
  void dispose() {
    _categoryCubit.close();
    _textController.dispose();
    super.dispose();
  }

  ///On refresh list
  Future<void> _onRefresh() async {
    await _categoryCubit.onLoad(_textController.text);
  }

  ///On clear search
  void _onClearTapped() async {
    _textController.text = '';
    _onSearch('');
  }

  ///On change mode view
  void _onChangeModeView() {
    switch (_type) {
      case CategoryView.full:
        setState(() {
          _type = CategoryView.icon;
        });
        break;
      case CategoryView.icon:
        setState(() {
          _type = CategoryView.full;
        });
        break;
      default:
        break;
    }
  }

  ///On navigate list product
  void _onProductList(CategoryModel item) {
    Navigator.pushNamed(context, Routes.listProduct,
        arguments: {'categoryId': item.id});
  }

  ///On Search Category
  void _onSearch(String text) {
    _onRefresh();
  }

  ///Export icon
  IconData _exportIcon(CategoryView type) {
    switch (type) {
      case CategoryView.icon:
        return Icons.view_headline;
      default:
        return Icons.view_agenda;
    }
  }

  ///Build content list
  Widget _buildContent(List<CategoryModel>? categories) {
    ///Success
    if (categories != null) {
      ///Empty
      if (categories.isEmpty) {
        return Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.sentiment_satisfied),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  Translate.of(context).translate(
                    'category_not_found',
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
          itemCount: categories.length,
          separatorBuilder: (context, index) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(),
            );
          },
          itemBuilder: (context, index) {
            final item = categories[index];
            return AppCategory(
              type: Application.submitSetting.categories
                          .singleWhere(
                              (element) => element.id == widget.parentId)
                          .listViewType ==
                      ListViewType.withIcons
                  ? CategoryView.icon
                  : CategoryView.full,
              item: item,
              onPressed: () {
                if (categories[index].type == CategoryType.main) {
                  Navigator.pushNamed(context, Routes.category,
                      arguments: categories[index].id);
                } else if (categories[index].type == CategoryType.sub &&
                    categories[index].hasBrands) {
                  Navigator.pushNamed(context, Routes.brand,
                      arguments: categories[index].id);
                } else {
                  _onProductList(item);
                }
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
        return AppCategory(
            type: Application.submitSetting.categories
                        .singleWhere((element) => element.id == widget.parentId)
                        .listViewType ==
                    ListViewType.withIcons
                ? CategoryView.icon
                : CategoryView.full);
      },
    );
  }

  final scaffoldKey = GlobalKey<ScaffoldState>(debugLabel: "categoryScreen");

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _categoryCubit,
      child: BlocBuilder<CategoryCubit, CategoryState>(
        builder: (context, state) {
          List<CategoryModel>? categories;
          if (state is CategorySuccess) {
            categories = state.list;
          }
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(widget.parentId != null
                  ? Application.submitSetting.categories
                      .singleWhere((item) => item.id == widget.parentId)
                      .name
                  : Translate.of(context).translate('category')),
              actions: <Widget>[
                IconButton(
                  icon: Icon(
                    _exportIcon(Application.submitSetting.categories
                                .singleWhere(
                                    (element) => element.id == widget.parentId)
                                .listViewType ==
                            ListViewType.withIcons
                        ? CategoryView.icon
                        : CategoryView.full),
                  ),
                  // onPressed: () {
                  //   (mainScaffold as Scaffold);
                  //   // Scaffold.of(context).openDrawer();
                  // },
                  onPressed: _onChangeModeView,
                )
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
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
                      child: _buildContent(categories),
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 4),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
