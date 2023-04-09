import 'dart:convert';

import 'package:akarak/widgets/app_list_title.dart';
import 'package:akarak/widgets/app_text_input.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/utils/utils.dart';

import 'models/model.dart';

class FirstTime extends StatefulWidget {
  final bool? hasSearch;

  const FirstTime({
    Key? key,
    this.hasSearch,
  }) : super(key: key);

  @override
  _FirstTimeState createState() {
    return _FirstTimeState();
  }
}

class _FirstTimeState extends State<FirstTime> {
  final _textFirstTimeController = TextEditingController();

  String _keyword = '';
  List<CountryModel>? countries;
  CountryModel? country;

  @override
  void initState() {
    super.initState();
    if (Application.countries.isEmpty) {
      AppBloc.applicationCubit.onBeforeSetup();
    }
    countries = Application.countries;
  }

  @override
  void dispose() {
    _textFirstTimeController.dispose();
    super.dispose();
  }

  ///On Filter Location
  void _onFilter(String text) {
    setState(() {
      _keyword = text;
    });
  }

  ///Build List
  Widget _buildList() {
    if (countries == null || countries!.isEmpty) {
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

    List<CountryModel> data = countries!;

    ///Filter
    if (_keyword.isNotEmpty) {
      data = data.where(((item) {
        return item.name.toUpperCase().contains(_keyword.toUpperCase());
      })).toList();
    }

    ///Build List
    return Column(
      children: <Widget>[
        if (widget.hasSearch != null && widget.hasSearch!)
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppTextInput(
              hintText: Translate.of(context).translate('search'),
              onChanged: _onFilter,
              onSubmitted: _onFilter,
              controller: _textFirstTimeController,
              trailing: GestureDetector(
                dragStartBehavior: DragStartBehavior.down,
                onTap: () {
                  _textFirstTimeController.clear();
                },
                child: const Icon(Icons.clear),
              ),
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemBuilder: (context, index) {
              final item = data[index];
              Widget? leading;
              Widget? trailing;
              if (item.icon != null && item.icon is Widget) {
                // leading = item.icon;
              }
              if (country == item) {
                trailing = Icon(
                  Icons.check,
                  color: Theme.of(context).primaryColor,
                );
              }

              return AppListTitle(
                title: item.name,
                leading: leading,
                trailing: trailing,
                border: index != data.length - 1,
                onPressed: () async {
                  await Future.delayed(const Duration(milliseconds: 500),
                      () async {
                    await Preferences.setString(
                        Preferences.currentCountry, jsonEncode(item.toJson()));
                    Application.currentCountry = item;
                    AppBloc.applicationCubit.onSetup();
                    // setState(() {
                    // });
                  });
                },
              );
            },
            itemCount: data.length,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          // countries.title ?? 'title',
          Translate.of(context).translate('select_country'),
        ),
      ),
      body: SafeArea(
        child: _buildList(),
      ),
    );
  }
}
