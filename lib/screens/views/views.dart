import 'dart:convert';
import 'dart:math';

import 'package:akarak/constants/constants.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/utils/utils.dart';
import 'package:akarak/widgets/widget.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../../widgets/widget.dart';

class Views extends StatefulWidget {
  const Views({Key? key}) : super(key: key);

  @override
  _ViewsState createState() {
    return _ViewsState();
  }
}

class _ViewsState extends State<Views> {
  String? _durationType;
  bool _isFirst = true;
  double _pointerWeek = 1;
  late List<ChartData> _listProductViews = [];
  late List<ChartData> _listProfileViews = [];
  late TrackballBehavior _trackballBehavior;
  late ZoomPanBehavior _zoomPanBehavior;
  bool allowLine = true;
  bool allowArea = false;
  bool allowSpline = false;
  bool allowColumn = false;
  bool allowScatter = false;
  bool allowStepLine = false;

  @override
  void initState() {
    _trackballBehavior = TrackballBehavior(
        enable: true,
        tooltipAlignment: ChartAlignment.near,
        tooltipDisplayMode: TrackballDisplayMode.groupAllPoints);
    _zoomPanBehavior = ZoomPanBehavior(
      // Enables pinch zooming
      enableDoubleTapZooming: true,
      enablePinching: true,
      enableSelectionZooming: true,
      selectionRectBorderColor: Colors.red,
      selectionRectBorderWidth: 1,
      selectionRectColor: Colors.amber,
      zoomMode: ZoomMode.xy,
      enablePanning: true,
    );
    _onRefresh();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  ///Select Section
  Future<void> _onSelectDuration() async {
    final result = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) => AppBottomPicker(
        picker: PickerModel(
          selected: [_durationType],
          data: [
            Translate.of(context).translate('by_days'),
            Translate.of(context).translate('by_hours'),
          ],
        ),
      ),
    );
    if (result != null) {
      if (_durationType != result) {
        _listProfileViews = [];
        _listProductViews = [];
      }
      setState(() {
        _listProfileViews = [];
        _listProductViews = [];
        _durationType = result;
      });
      _onRefresh();
    }
  }

  Future<String> getFuture() async {
    return 'loading';
  }

  Widget getLoadMoreProductViewsBuilder(
      BuildContext context, ChartSwipeDirection direction) {
    if (direction == ChartSwipeDirection.end) {
      _onScrollProductsViews();

      return FutureBuilder<String>(
        future: getFuture(),

        /// Adding data by updateDataSource method
        builder: (BuildContext futureContext, AsyncSnapshot<String> snapShot) {
          return snapShot.connectionState != ConnectionState.done
              ? const CircularProgressIndicator()
              : SizedBox.fromSize(size: Size.zero);
        },
      );
    } else {
      return SizedBox.fromSize(size: Size.zero);
    }
  }

  Widget getLoadMoreProfileViewsBuilder(
      BuildContext context, ChartSwipeDirection direction) {
    if (direction == ChartSwipeDirection.end) {
      _onScrollProfileViews();

      return FutureBuilder<String>(
        future: getFuture(),

        /// Adding data by updateDataSource method
        builder: (BuildContext futureContext, AsyncSnapshot<String> snapShot) {
          return snapShot.connectionState != ConnectionState.done
              ? const CircularProgressIndicator()
              : SizedBox.fromSize(size: Size.zero);
        },
      );
    } else {
      return SizedBox.fromSize(size: Size.zero);
    }
  }

  ///Handle load more
  Future<void> _onScrollProfileViews() async {
    await AppBloc.viewsCubit.onLoadMoreProfileViews(
        byDays: _durationType == null ||
            _durationType == Translate.of(context).translate('by_days'));
  }

  ///Handle load more
  Future<void> _onScrollProductsViews() async {
    await AppBloc.viewsCubit.onLoadMoreProductsViews(
        byDays: _durationType == null ||
            _durationType == Translate.of(context).translate('by_days'));
  }

  ///On refresh
  Future<void> _onRefresh() async {
    await AppBloc.viewsCubit.onLoad();
    bool byDays = _durationType == null ||
        _durationType == Translate.of(context).translate('by_days');
    await AppBloc.viewsCubit.onLoad(byDays: byDays);
  }

  @override
  Widget build(BuildContext context) {
    ///Loading
    Widget chartTypes = ListView.builder(
      scrollDirection: Axis.horizontal,
      // padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      itemBuilder: (context, index) {
        return const Padding(
          // padding: EdgeInsets.symmetric(horizontal: 8),
          padding: EdgeInsets.symmetric(horizontal: 1),
          child: AppCategory(
            type: CategoryView.cardLarge,
          ),
        );
      },
      itemCount: 6,
    );

    chartTypes = ListView.builder(
      scrollDirection: Axis.horizontal,
      // padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      itemBuilder: (context, index) {
        return Padding(
            // padding: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: index == 0
                ? Row(children: [
                    Checkbox(
                      value: allowLine,
                      onChanged: (value) {
                        setState(() {
                          allowLine = value!;
                        });
                      },
                    ),
                    Text(Translate.of(context).translate('allow_line')),
                  ])
                : index == 1
                    ? Row(children: [
                        Checkbox(
                          value: allowArea,
                          onChanged: (value) {
                            setState(() {
                              allowArea = value!;
                            });
                          },
                        ),
                        Text(Translate.of(context).translate('allow_area')),
                      ])
                    : index == 2
                        ? Row(children: [
                            Checkbox(
                              value: allowSpline,
                              onChanged: (value) {
                                setState(() {
                                  allowSpline = value!;
                                });
                              },
                            ),
                            Text(Translate.of(context)
                                .translate('allow_spline')),
                          ])
                        : index == 3
                            ? Row(children: [
                                Checkbox(
                                  value: allowColumn,
                                  onChanged: (value) {
                                    setState(() {
                                      allowColumn = value!;
                                    });
                                  },
                                ),
                                Text(Translate.of(context)
                                    .translate('allow_column')),
                              ])
                            : index == 4
                                ? Row(children: [
                                    Checkbox(
                                      value: allowScatter,
                                      onChanged: (value) {
                                        setState(() {
                                          allowScatter = value!;
                                        });
                                      },
                                    ),
                                    Text(Translate.of(context)
                                        .translate('allow_scatter')),
                                  ])
                                : Row(children: [
                                    Checkbox(
                                      value: allowStepLine,
                                      onChanged: (value) {
                                        setState(() {
                                          allowStepLine = value!;
                                        });
                                      },
                                    ),
                                    Text(Translate.of(context)
                                        .translate('allow_step_line')),
                                  ]));
      },
      itemCount: 6,
    );

    Widget chartTypesCard = Card(
      // color: Colors.grey.withOpacity(0.1),
      child: Padding(
        padding:
            const EdgeInsets.only(right: 10, left: 10, bottom: 10, top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  Text(
                    Translate.of(context).translate(
                      'chart_type',
                    ),
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
            Container(
              // color: Colors.grey.withOpacity(0.2),
              height: 30,
              padding: const EdgeInsets.only(top: 4),
              child: chartTypes,
            ),
          ],
        ),
      ),
    );
    if (_isFirst) {
      _durationType = Translate.of(context).translate('by_days');
      _isFirst = false;
    }
    return BlocBuilder<ViewsCubit, ViewsState>(builder: (context, state) {
      if (state is ViewsSuccess) {
        if (state.type == ViewsStateType.productViews) {
          _listProductViews.addAll(state.list
              .map((e) =>
                  ChartData(e.dayOfYear, int.parse(e.totlalViews.toString())))
              .toList());
        } else {
          _listProfileViews.addAll(state.list
              .map((e) =>
                  ChartData(e.dayOfYear, int.parse(e.totlalViews.toString())))
              .toList());
        }
      }

      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Application.scaffoldKey.currentState?.openDrawer(),
          ),
          centerTitle: false,
          title: Text(
            Translate.of(context).translate('views'),
          ),
          actions: const [],
        ),
        body: SingleChildScrollView(
          // child: ConstrainedBox(
          // constraints: BoxConstraints(
          // minHeight: MediaQuery.of(context).size.height,
          // ),
          // child: IntrinsicHeight(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                const SizedBox(height: 16),
                chartTypesCard,
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 20, right: 8, left: 8, bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 8, right: 20, left: 20, bottom: 8),
                          child: Text(
                            state is ViewsSuccess
                                ? ((state.totalViews?.totalProductsViews ?? 0) +
                                        (state.totalViews?.totalProfileViews ??
                                            0))
                                    .toString()
                                : '0',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 0, right: 20, left: 20, bottom: 4),
                          child: Text(
                            Translate.of(context).translate('all_views'),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 0, right: 20, left: 20, bottom: 16),
                          child: Text(
                            Translate.of(context).translate(
                                'the_total_views_of_your_account_and_ads_since_the_creation_of_the_account'),
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ),
                        const Divider(height: 1),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.only(
                              right: 16, left: 16, bottom: 16),
                          child: IntrinsicHeight(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(),
                                Column(
                                  children: [
                                    Text(
                                      state is ViewsSuccess
                                          ? (state.totalViews
                                                  ?.totalProductsViews
                                                  .toString() ??
                                              '0')
                                          : '0',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      Translate.of(context).translate('ads'),
                                      style:
                                          Theme.of(context).textTheme.caption,
                                    ),
                                  ],
                                ),
                                VerticalDivider(
                                    width: 1,
                                    color: Theme.of(context).dividerColor),
                                Column(
                                  children: [
                                    Text(
                                      state is ViewsSuccess
                                          ? (state.totalViews?.totalProfileViews
                                                  .toString() ??
                                              '0')
                                          : '0',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      Translate.of(context)
                                          .translate('account'),
                                      style:
                                          Theme.of(context).textTheme.caption,
                                    ),
                                  ],
                                ),
                                const SizedBox()
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                AppPickerItem(
                  // leading: _icon?.icon ?? icon,
                  title: _durationType ?? "",
                  value: _durationType,
                  onPressed: () async {
                    await _onSelectDuration();
                  },
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 20, right: 8, left: 8, bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 8, right: 20, left: 20, bottom: 8),
                          child: Text(
                            state is ViewsSuccess
                                ? (state.totalViews?.totalProductsViews
                                        .toString() ??
                                    '0')
                                : '0',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 0, right: 20, left: 20, bottom: 4),
                          child: Text(
                            Translate.of(context).translate('ad_views'),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 0, right: 20, left: 20, bottom: 16),
                          child: Text(
                            Translate.of(context).translate(
                                'your_ad_views_in_the_last_30_weeks'),
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 300,
                          width: 370,
                          child: SfCartesianChart(
                              loadMoreIndicatorBuilder: (BuildContext context,
                                      ChartSwipeDirection direction) =>
                                  getLoadMoreProductViewsBuilder(
                                      context, direction),
                              primaryXAxis: CategoryAxis(),
                              zoomPanBehavior: _zoomPanBehavior,
                              series: <ChartSeries<ChartData, String>>[
                                if (allowLine)
                                  LineSeries<ChartData, String>(
                                    dataSource: _listProductViews,
                                    xValueMapper: (ChartData data, _) => data.x,
                                    yValueMapper: (ChartData data, _) => data.y,
                                  ),
                                if (allowArea)
                                  AreaSeries<ChartData, String>(
                                    dataSource: _listProductViews,
                                    xValueMapper: (ChartData data, _) => data.x,
                                    yValueMapper: (ChartData data, _) => data.y,
                                  ),
                                if (allowSpline)
                                  SplineSeries<ChartData, String>(
                                    dataSource: _listProductViews,
                                    xValueMapper: (ChartData data, _) => data.x,
                                    yValueMapper: (ChartData data, _) => data.y,
                                  ),
                                if (allowColumn)
                                  ColumnSeries<ChartData, String>(
                                    dataSource: _listProductViews,
                                    xValueMapper: (ChartData data, _) => data.x,
                                    yValueMapper: (ChartData data, _) => data.y,
                                  ),
                                if (allowScatter)
                                  ScatterSeries<ChartData, String>(
                                    dataSource: _listProductViews,
                                    xValueMapper: (ChartData data, _) => data.x,
                                    yValueMapper: (ChartData data, _) => data.y,
                                  ),
                                if (allowStepLine)
                                  StepLineSeries<ChartData, String>(
                                    dataSource: _listProductViews,
                                    xValueMapper: (ChartData data, _) => data.x,
                                    yValueMapper: (ChartData data, _) => data.y,
                                  ),
                              ]),
                        ),
                        // Container(
                        //   alignment: Alignment.center,
                        //   constraints: const BoxConstraints(minHeight: 80),
                        //   child: SfLinearGauge(
                        //     minimum: 1,
                        //     maximum: 30,
                        //     showLabels: true,
                        //     showAxisTrack: true,
                        //     showTicks: true,
                        //     isAxisInversed: true,
                        //     markerPointers: [
                        //       LinearShapePointer(
                        //           value: _pointerWeek,
                        //           shapeType:
                        //               LinearShapePointerType.invertedTriangle,
                        //           position: LinearElementPosition.cross,
                        //           onChanged: (value) {
                        //             setState(() {
                        //               _pointerWeek = value;
                        //             });
                        //           },
                        //           color: _pointerWeek < 10
                        //               ? Colors.green
                        //               : _pointerWeek < 20
                        //                   ? Colors.orange
                        //                   : Colors.red),
                        //       LinearWidgetPointer(
                        //         value: _pointerWeek,
                        //         onChanged: (value) {
                        //           setState(() {
                        //             _pointerWeek = value;
                        //           });
                        //         },
                        //         position: LinearElementPosition.outside,
                        //         child: SizedBox(
                        //           width: 55,
                        //           height: 45,
                        //           child: Center(
                        //             child: Text(
                        //               _pointerWeek.toStringAsFixed(0),
                        //               style: TextStyle(
                        //                   fontWeight: FontWeight.w500,
                        //                   fontSize: 20,
                        //                   color: _pointerWeek < 40
                        //                       ? Colors.green
                        //                       : _pointerWeek < 80
                        //                           ? Colors.orange
                        //                           : Colors.red),
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //     ],
                        //     // ranges: [
                        //     //   LinearGaugeRange(
                        //     //     startValue: 0,
                        //     //     endValue: getTotalOutcoming().toDouble(),
                        //     //     position: LinearElementPosition.cross,
                        //     //     color: Theme.of(context).primaryColor,
                        //     //   ),
                        //     // ],
                        //     axisTrackStyle: LinearAxisTrackStyle(
                        //         thickness: 5,
                        //         gradient: LinearGradient(
                        //             colors: [
                        //               Theme.of(context)
                        //                   .dividerColor
                        //                   .withOpacity(0.5),
                        //               Theme.of(context)
                        //                   .dividerColor
                        //                   .withOpacity(0.7)
                        //             ],
                        //             begin: Alignment.centerLeft,
                        //             end: Alignment.centerRight,
                        //             stops: const [0.4, 0.9],
                        //             tileMode: TileMode.clamp)),
                        //   ),
                        // ),
                        // Stack(
                        //   children: <Widget>[
                        //     AspectRatio(
                        //       aspectRatio: 1.70,
                        //       child: DecoratedBox(
                        //         decoration: const BoxDecoration(
                        //           borderRadius: BorderRadius.all(
                        //             Radius.circular(18),
                        //           ),
                        //           color: Colors.white,
                        //         ),
                        //         child: Padding(
                        //           padding: const EdgeInsets.only(
                        //             right: 18,
                        //             left: 12,
                        //             top: 24,
                        //             bottom: 12,
                        //           ),
                        //           child: LineChart(
                        //             showAvg ? avgData() : mainData(),
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //     SizedBox(
                        //       width: 60,
                        //       height: 34,
                        //       child: TextButton(
                        //         onPressed: () {
                        //           setState(() {
                        //             showAvg = !showAvg;
                        //           });
                        //         },
                        //         child: Text(
                        //           'avg',
                        //           style: TextStyle(
                        //             fontSize: 12,
                        //             color: Theme.of(context)
                        //                 .dividerColor
                        //                 .withOpacity(0.8),
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 20, right: 8, left: 8, bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 8, right: 20, left: 20, bottom: 8),
                          child: Text(
                            state is ViewsSuccess
                                ? (state.totalViews?.totalProfileViews
                                        .toString() ??
                                    '0')
                                : '0',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 0, right: 20, left: 20, bottom: 4),
                          child: Text(
                            Translate.of(context).translate('account_views'),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 0, right: 20, left: 20, bottom: 16),
                          child: Text(
                            Translate.of(context).translate(
                                'your_account_views_in_the_last_30_weeks'),
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 300,
                          width: 370,
                          child: SfCartesianChart(
                              loadMoreIndicatorBuilder: (BuildContext context,
                                      ChartSwipeDirection direction) =>
                                  getLoadMoreProfileViewsBuilder(
                                      context, direction),
                              primaryXAxis: CategoryAxis(),
                              zoomPanBehavior: _zoomPanBehavior,
                              series: <ChartSeries<ChartData, String>>[
                                if (allowLine)
                                  LineSeries<ChartData, String>(
                                    dataSource: _listProfileViews,
                                    xValueMapper: (ChartData data, _) => data.x,
                                    yValueMapper: (ChartData data, _) => data.y,
                                  ),
                                if (allowArea)
                                  AreaSeries<ChartData, String>(
                                    dataSource: _listProfileViews,
                                    xValueMapper: (ChartData data, _) => data.x,
                                    yValueMapper: (ChartData data, _) => data.y,
                                  ),
                                if (allowSpline)
                                  SplineSeries<ChartData, String>(
                                    dataSource: _listProfileViews,
                                    xValueMapper: (ChartData data, _) => data.x,
                                    yValueMapper: (ChartData data, _) => data.y,
                                  ),
                                if (allowColumn)
                                  ColumnSeries<ChartData, String>(
                                    dataSource: _listProfileViews,
                                    xValueMapper: (ChartData data, _) => data.x,
                                    yValueMapper: (ChartData data, _) => data.y,
                                  ),
                                if (allowScatter)
                                  ScatterSeries<ChartData, String>(
                                    dataSource: _listProfileViews,
                                    xValueMapper: (ChartData data, _) => data.x,
                                    yValueMapper: (ChartData data, _) => data.y,
                                  ),
                                if (allowStepLine)
                                  StepLineSeries<ChartData, String>(
                                    dataSource: _listProfileViews,
                                    xValueMapper: (ChartData data, _) => data.x,
                                    yValueMapper: (ChartData data, _) => data.y,
                                  ),
                              ]),
                        ),
                        // Stack(
                        //   children: <Widget>[
                        //     AspectRatio(
                        //       aspectRatio: 1.70,
                        //       child: DecoratedBox(
                        //         decoration: const BoxDecoration(
                        //           borderRadius: BorderRadius.all(
                        //             Radius.circular(18),
                        //           ),
                        //           color: Colors.white,
                        //         ),
                        //         child: Padding(
                        //           padding: const EdgeInsets.only(
                        //             right: 18,
                        //             left: 12,
                        //             top: 24,
                        //             bottom: 12,
                        //           ),
                        //           child: LineChart(
                        //             showAvg ? avgData() : mainData(),
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //     SizedBox(
                        //       width: 60,
                        //       height: 34,
                        //       child: TextButton(
                        //         onPressed: () {
                        //           setState(() {
                        //             showAvg = !showAvg;
                        //           });
                        //         },
                        //         child: Text(
                        //           'avg',
                        //           style: TextStyle(
                        //             fontSize: 12,
                        //             color: Theme.of(context)
                        //                 .dividerColor
                        //                 .withOpacity(0.8),
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // ),
        // ),
      );
    });
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final int? y;
}

class ChartData2 {
  ChartData2(this.x, this.y);
  final double? x;
  final double? y;
}
