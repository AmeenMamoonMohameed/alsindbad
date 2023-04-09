import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc.dart';

class AppBloc {
  static final applicationCubit = ApplicationCubit();
  static final realTimeCubit = RealTimeCubit();
  // static final initCubit = InitCubit();
  // static final orderListCubit = OrderListCubit();
  static final viewsCubit = ViewsCubit();
  static final chatSignalRCubit = ChatSignalRCubit();
  static final discoveryCubit = DiscoveryCubit();
  static final profileListCubit = ProfileListCubit();
  static final userCubit = UserCubit();
  static final chatUsersListCubit = ChatUsersListCubit();
  static final chatCubit = ChatCubit();
  static final submitMessageCubit = SubmitMessageCubit();
  static final languageCubit = LanguageCubit();
  static final themeCubit = ThemeCubit();
  static final authenticateCubit = AuthenticationCubit();
  static final loginCubit = LoginCubit();
  static final homeCubit = HomeCubit();
  static final wishListCubit = WishListCubit();
  static final reviewCubit = ReviewCubit();
  static final messageCubit = MessageCubit();
  static final submitCubit = SubmitCubit();
  static final locationCubit = LocationCubit();
  static final searchCubit = SearchCubit();

  static final List<BlocProvider> providers = [
    BlocProvider<ApplicationCubit>(
      create: (context) => applicationCubit,
    ),
    BlocProvider<RealTimeCubit>(
      create: (context) => realTimeCubit,
    ),
    // BlocProvider<InitCubit>(
    //   create: (context) => initCubit,
    // ),
    // BlocProvider<OrderListCubit>(
    //   create: (context) => orderListCubit,
    // ),
    BlocProvider<ViewsCubit>(
      create: (context) => viewsCubit,
    ),
    BlocProvider<ChatSignalRCubit>(
      create: (context) => chatSignalRCubit,
    ),
    BlocProvider<LocationCubit>(
      create: (context) => locationCubit,
    ),
    BlocProvider<ProfileListCubit>(
      create: (context) => profileListCubit,
    ),
    BlocProvider<UserCubit>(
      create: (context) => userCubit,
    ),
    BlocProvider<DiscoveryCubit>(
      create: (context) => discoveryCubit,
    ),
    BlocProvider<ChatUsersListCubit>(
      create: (context) => chatUsersListCubit,
    ),
    BlocProvider<ChatCubit>(
      create: (context) => chatCubit,
    ),
    BlocProvider<SubmitMessageCubit>(
      create: (context) => submitMessageCubit,
    ),
    BlocProvider<LanguageCubit>(
      create: (context) => languageCubit,
    ),
    BlocProvider<ThemeCubit>(
      create: (context) => themeCubit,
    ),
    BlocProvider<AuthenticationCubit>(
      create: (context) => authenticateCubit,
    ),
    BlocProvider<LoginCubit>(
      create: (context) => loginCubit,
    ),
    BlocProvider<HomeCubit>(
      create: (context) => homeCubit,
    ),
    BlocProvider<WishListCubit>(
      create: (context) => wishListCubit,
    ),
    BlocProvider<ReviewCubit>(
      create: (context) => reviewCubit,
    ),
    BlocProvider<MessageCubit>(
      create: (context) => messageCubit,
    ),
    BlocProvider<SubmitCubit>(
      create: (context) => submitCubit,
    ),
    BlocProvider<SearchCubit>(
      create: (context) => searchCubit,
    ),
  ];

  static void dispose() {
    applicationCubit.close();
    locationCubit.close();
    userCubit.close();
    languageCubit.close();
    themeCubit.close();
    homeCubit.close();
    wishListCubit.close();
    authenticateCubit.close();
    loginCubit.close();
    reviewCubit.close();
    messageCubit.close();
    submitCubit.close();
    searchCubit.close();
  }

  ///Singleton factory
  static final AppBloc _instance = AppBloc._internal();

  factory AppBloc() {
    return _instance;
  }

  AppBloc._internal();
}
