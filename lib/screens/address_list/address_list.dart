import 'package:akarak/app_properties.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/constants/constants.dart';
import 'package:akarak/repository/address_repository.dart';
import 'package:akarak/utils/other.dart';
import 'package:akarak/utils/translate.dart';
import 'package:akarak/widgets/shop_item_list.dart';
import 'package:akarak/widgets/widget.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../configs/routes.dart';

class AddressList extends StatefulWidget {
  final bool? isSelectable;
  const AddressList({Key? key, this.isSelectable = false}) : super(key: key);

  @override
  _AddressListState createState() => _AddressListState();
}

class _AddressListState extends State<AddressList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ShowCaseWidget(
        builder: Builder(
          builder: (context) =>
              AddressListChild(isSelectable: widget.isSelectable),
        ),
      ),
    );
  }
}

class AddressListChild extends StatefulWidget {
  final bool? isSelectable;
  const AddressListChild({Key? key, this.isSelectable = false})
      : super(key: key);

  @override
  _AddressListChildState createState() => _AddressListChildState();
}

class _AddressListChildState extends State<AddressListChild> {
  SwiperController swiperController = SwiperController();
  final addressListCubit = AddressListCubit();

  @override
  void initState() {
    super.initState();
    addressListCubit.onLoad();
  }

  @override
  void dispose() {
    addressListCubit.close();
    swiperController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: BlocProvider(
        create: (context) => addressListCubit,
        child: BlocBuilder<AddressListCubit, AddressListState>(
          builder: (context, state) {
            Widget content = AppPlaceholder(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 8,
                ),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: 130,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          boxShadow: smallShadow,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: 130,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          boxShadow: smallShadow,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: 130,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          boxShadow: smallShadow,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: 130,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          boxShadow: smallShadow,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: 130,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          boxShadow: smallShadow,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: 130,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          boxShadow: smallShadow,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: 130,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          boxShadow: smallShadow,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            );

            if (state is AddressListSuccess) {
              // content
              if (state.list != null) {
                // content
                content = Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (widget.isSelectable == true)
                      Info(
                          message: Translate.of(context).translate(
                              'just_click_on_the_delivery_address_for_the_order')),
                    if (!(state.list!.length == 1 &&
                            state.list!.single.isDefault) &&
                        widget.isSelectable == false)
                      Info(
                          message: Translate.of(context).translate(
                              'just_click_on_the_shipping_address_to_set_as_default_shipping_address')),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.7,
                      color: Theme.of(context).colorScheme.tertiary,
                      child: Scrollbar(
                          child: ListView.builder(
                        itemBuilder: (_, index) => InkWell(
                          onTap: () {
                            if (widget.isSelectable == true) {
                              Navigator.pop(context, state.list![index].id);
                            } else {
                              for (var item in state.list!) {
                                item.isDefault = false;
                              }
                              state.list![index].isDefault = true;
                              setState(() {});
                              AddressRepository.setDefault(
                                      address: state.list![index])
                                  .then((value) {
                                if (value == false) {
                                  addressListCubit.onLoad();
                                }
                              });
                            }
                          },
                          child: Center(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              margin: index == 0
                                  ? const EdgeInsets.only(
                                      right: 16.0,
                                      left: 16.0,
                                      top: 20,
                                      bottom: 5)
                                  : const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 5),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                boxShadow: smallShadow,
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10)),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const SizedBox(height: 5),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Text(
                                            state.list![index].name,
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .caption
                                                ?.copyWith(
                                                  color: Colors.black
                                                      .withOpacity(0.6),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Wrap(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Text(
                                            "${Application.currentCountry!.name}, ${state.list![index].stateId}, ${state.list![index].cityId}, ${state.list![index].description}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .caption,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Wrap(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Text(
                                            "${state.list![index].firstName} ${state.list![index].lastName}",
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .caption,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          state.list![index].phoneNumber,
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption,
                                        ),
                                      ],
                                    ),
                                    if (!(state.list![index]
                                            .isShippingAddressSupported ??
                                        true)) ...[
                                      const SizedBox(height: 5),
                                      Wrap(
                                        children: [
                                          Text(
                                            Translate.of(context).translate(
                                                'the_delivery_address_is_not_supported'),
                                            style: Theme.of(context)
                                                .textTheme
                                                .caption
                                                ?.copyWith(color: Colors.red),
                                          ),
                                        ],
                                      ),
                                    ],
                                    Row(
                                      // mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.45,
                                          child: Wrap(
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  Icons.edit_location_alt,
                                                  textDirection:
                                                      TextDirection.ltr,
                                                  color: Colors.orange[300],
                                                ),
                                                onPressed: () {
                                                  Navigator.pushNamed(
                                                    context,
                                                    Routes.addAddress,
                                                    arguments: {
                                                      "item":
                                                          state.list![index],
                                                      "isSelectable":
                                                          widget.isSelectable
                                                    },
                                                  );
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.location_off,
                                                  textDirection:
                                                      TextDirection.ltr,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () async {
                                                  await AddressRepository
                                                      .removeAddress(
                                                    id: state.list![index].id,
                                                  ).then((value) async {
                                                    final defaultAddress =
                                                        await AddressRepository
                                                            .loadDefault();
                                                    if (defaultAddress !=
                                                            null &&
                                                        defaultAddress.id ==
                                                            state.list![index]
                                                                .id) {
                                                      await AddressRepository
                                                          .removeDefault();
                                                    }
                                                    addressListCubit.onLoad();
                                                  });
                                                },
                                              )
                                            ],
                                          ),
                                        ),
                                        if (state.list![index].isDefault) ...[
                                          const VerticalDivider(),
                                          Text(
                                            Translate.of(context)
                                                .translate('default'),
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context)
                                                        .iconTheme
                                                        .color),
                                          ),
                                          const Icon(
                                            Icons.check,
                                            textDirection: TextDirection.ltr,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        itemCount: state.list!.length,
                      )),
                    ),
                  ],
                );
              }
              return Scaffold(
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  appBar: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0.0,
                    iconTheme: const IconThemeData(color: darkGrey),
                    actions: const <Widget>[],
                    title: Text(
                      Translate.of(context).translate('shipping_addresses'),
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
                          constraints: BoxConstraints(
                              minHeight: constraints.maxHeight * 1.3),
                          child: content),
                    ),
                  ),
                  floatingActionButton: FloatingActionButton.extended(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                    onPressed: () {
                      // Respond to button press
                      Navigator.pushNamed(context, Routes.addAddress,
                          arguments: {
                            "item": null,
                            "isSelectable": widget.isSelectable
                          }).then((value) {
                        if (value != null) {
                          addressListCubit.onLoad();
                        }
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: Text(
                      Translate.of(context).translate('add'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                    ),
                  ));
            }

            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                iconTheme: const IconThemeData(color: darkGrey),
                actions: const <Widget>[],
                title: Text(
                  Translate.of(context).translate('addresses'),
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
          },
        ),
      ),
    );
  }
}
