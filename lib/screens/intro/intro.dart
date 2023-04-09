import 'package:flutter/material.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/utils/utils.dart';

class Intro extends StatefulWidget {
  const Intro({Key? key}) : super(key: key);

  @override
  _IntroState createState() {
    return _IntroState();
  }
}

class _IntroState extends State<Intro> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  ///On complete preview intro
  void _onCompleted() {
    AppBloc.applicationCubit.onCompletedIntro();
  }

  @override
  Widget build(BuildContext context) {
    ///List Intro view page model
    final List<PageViewModel> pages = [
      PageViewModel(
        pageColor: const Color.fromARGB(255, 89, 149, 197),
        bubble: const Icon(
          Icons.shop,
          color: Colors.white,
        ),
        body: Text(
          Translate.of(context).translate('browse_intro'),
          style: Theme.of(context).textTheme.headline6!.copyWith(
                color: Colors.white,
              ),
        ),
        title: Text(
          Translate.of(context).translate('browse'),
          style: Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: Colors.white),
        ),
        mainImage: Image.asset(
          Images.intro1,
          fit: BoxFit.contain,
        ),
      ),
      PageViewModel(
        pageColor: const Color.fromARGB(255, 89, 149, 197),
        bubble: const Icon(
          Icons.phonelink,
          color: Colors.white,
        ),
        body: Text(
          Translate.of(context).translate('communication_intro'),
          style: Theme.of(context)
              .textTheme
              .headline6!
              .copyWith(color: Colors.white),
        ),
        title: Text(
          Translate.of(context).translate('communication'),
          style: Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: Colors.white),
        ),
        mainImage: Image.asset(
          Images.intro2,
          fit: BoxFit.contain,
        ),
      ),
      PageViewModel(
        pageColor: const Color.fromARGB(255, 89, 149, 197),
        bubble: const Icon(
          Icons.home,
          color: Colors.white,
        ),
        body: Text(
          Translate.of(context).translate('location_intro'),
          style: Theme.of(context)
              .textTheme
              .headline6!
              .copyWith(color: Colors.white),
        ),
        title: Text(
          Translate.of(context).translate('locations'),
          style: Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: Colors.white),
        ),
        mainImage: Image.asset(
          Images.intro3,
          fit: BoxFit.contain,
        ),
      ),
    ];

    ///Build Page
    return Scaffold(
      body: IntroViewsFlutter(
        pages,
        onTapSkipButton: _onCompleted,
        onTapDoneButton: _onCompleted,
        // showSkipButton: false,
        doneText: Text(Translate.of(context).translate('done')),
        nextText: Text(Translate.of(context).translate('next')),
        skipText: Text(Translate.of(context).translate('skip')),
        backText: Text(Translate.of(context).translate('back')),
        pageButtonTextStyles: Theme.of(context).textTheme.button!.copyWith(
              color: Colors.white,
            ),
      ),
    );
  }
}
