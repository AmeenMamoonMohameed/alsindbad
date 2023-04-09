import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/utils/utils.dart';
import 'package:akarak/widgets/widget.dart';

class ResultList extends StatefulWidget {
  const ResultList({
    Key? key,
  }) : super(key: key);

  @override
  _ResultListState createState() {
    return _ResultListState();
  }
}

class _ResultListState extends State<ResultList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  ///On navigate product detail
  void _onProductDetail(ProductModel item) async {
    _onSave(item);
    if (item.createdBy != null &&
        item.createdBy!.userId == AppBloc.userCubit.state?.userId) {
      Navigator.pushNamed(context, Routes.submit, arguments: item);
    } else {
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
  }

  void _onSave(item) async {
    List<String>? historyString = Preferences.getStringList(
      Preferences.search,
    );
    if (historyString != null) {
      if (!historyString.contains(jsonEncode(item.toJson()))) {
        historyString.add(jsonEncode(item.toJson()));
        await Preferences.setStringList(
          Preferences.search,
          historyString,
        );
      }
    } else {
      await Preferences.setStringList(
        Preferences.search,
        [jsonEncode(item.toJson())],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          if (state is SearchSuccess) {
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
          if (state is SearchLoading) {
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
          return Container();
        },
      ),
    );
  }
}
