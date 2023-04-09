import 'package:flutter/material.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/screens/screen.dart' as screen;
import 'package:akarak/screens/screen.dart';
import 'package:image_picker/image_picker.dart';

import '../models/model_feature.dart';
import '../models/model_location.dart';
import '../screens/address/add_address_page.dart';

class RouteArguments<T> {
  final T? item;
  final bool hasOperations;
  final VoidCallback? callback;
  RouteArguments({
    this.item,
    this.hasOperations = true,
    this.callback,
  });
}

class Routes {
  static const String notifications = "/notifications";
  static const String home = "/home";
  static const String discovery = "/discovery";
  static const String wishList = "/wishList";
  static const String account = "/account";
  static const String accountDetails = "/accountDetails";
  static const String addressList = "/addressList";
  static const String addAddress = "/addAddress";
  static const String views = "/views";
  static const String signIn = "/signIn";
  static const String signUp = "/signUp";
  static const String otp = "/confirmPhoneNumber";
  static const String forgotPassword = "/forgotPassword";
  static const String otpForgotPassword = "/otpForgotPassword";
  static const String productDetail = "/productDetail";
  static const String productScreen = "/productScreen";
  static const String searchHistory = "/searchHistory";
  static const String category = "/category";
  static const String brand = "/brand";
  static const String profile = "/profile";
  static const String listProfile = "/listProfile";
  static const String profileQRCode = "/profileQRCode";
  static const String submit = "/submit";
  static const String editProfile = "/editProfile";
  static const String changePassword = "/changePassword";
  static const String changeLanguage = "/changeLanguage";
  static const String contactUs = "/contactUs";
  static const String aboutUs = "/aboutUs";
  static const String gallery = "/gallery";
  static const String themeSetting = "/themeSetting";
  static const String listProduct = "/listProduct";
  static const String filter = "/filter";
  static const String review = "/review";
  static const String productReview = "/productReview";
  static const String feedback = "/feedback";
  static const String shippingFeedback = "/shippingFeedback";
  static const String location = "/location";
  static const String setting = "/setting";
  static const String chatterScreen = "/chatterScreen";
  static const String fontSetting = "/fontSetting";
  static const String picker = "/picker";
  static const String galleryUpload = "/galleryUpload";
  static const String categoryPicker = "/categoryPicker";
  static const String gpsPicker = "/gpsPicker";
  static const String submitSuccess = "/submitSuccess";
  static const String openTime = "/openTime";
  static const String socialNetwork = "/socialNetwork";
  static const String tagsPicker = "/tagsPicker";
  static const String sizesPicker = "/sizesPicker";
  static const String webView = "/webView";
  static const String paypalPayment = "/paypalPayment";
  static const String customerOrderList = "/customerOrderList";
  static const String order = "/order";
  static const String orderList = "/orderList";
  static const String incompleteOrderList = "/incompleteOrderList";
  static const String shoppingCart = "/shoppingCart";
  static const String checkOut = "/checkOut";
  static const String checkOutRefund = "/checkOutRefund";
  static const String orderDetail = "/orderDetail";
  static const String orderItemList = "/orderItemList";
  static const String blockedUsersList = "/blocked_users_list";
  static const String chatList = "/chat_users_list";
  static const String chat = "/chat";

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case signIn:
        return MaterialPageRoute(
          builder: (context) {
            return SignIn(from: settings.arguments as String);
          },
          fullscreenDialog: true,
        );

      case signUp:
        return MaterialPageRoute(
          builder: (context) {
            return const SignUp();
          },
        );

      case forgotPassword:
        return MaterialPageRoute(
          builder: (context) {
            return const ForgotPassword();
          },
        );

      case otpForgotPassword:
        return MaterialPageRoute(
          builder: (context) {
            return OtpForgotPassword(
              countryCode:
                  (settings.arguments as Map<String, dynamic>)['countryCode'],
              phoneNumber:
                  (settings.arguments as Map<String, dynamic>)['phoneNumber'],
            );
          },
        );

      case otp:
        return MaterialPageRoute(
          builder: (context) {
            return Otp(
              userId: (settings.arguments as Map<String, dynamic>)['userId'],
              routeName:
                  (settings.arguments as Map<String, dynamic>)['routeName'],
            );
          },
        );

      case contactUs:
        return MaterialPageRoute(
          builder: (context) {
            return const ContactUs();
          },
        );

      // case productDetail:
      //   return MaterialPageRoute(
      //     builder: (context) {
      //       return ProductDetail(
      //         id: (settings.arguments as Map<String, dynamic>)['id'] as int,
      //         categoryId: (settings.arguments
      //             as Map<String, dynamic>)['categoryId'] as int,
      //       );
      //     },
      //   );
      // case productDetail:
      //   return MaterialPageRoute(
      //     builder: (context) {
      //       return ProductScreen(
      //         '11',
      //       );
      //     },
      //   );
      case productDetail:
        return MaterialPageRoute(
          builder: (context) {
            return ProductScreen(
              id: (settings.arguments as Map<String, dynamic>)['id'] as int,
              categoryId: (settings.arguments
                  as Map<String, dynamic>)['categoryId'] as int,
            );
          },
        );

      case searchHistory:
        return MaterialPageRoute(
          builder: (context) {
            return SearchHistory(image: settings.arguments as XFile?);
          },
          fullscreenDialog: true,
        );

      case notifications:
        return MaterialPageRoute(
          builder: (context) {
            return const Notifications();
          },
          fullscreenDialog: true,
        );

      case accountDetails:
        return MaterialPageRoute(
          builder: (context) {
            if (settings.arguments is int) {
              return AccountDetails(categoryId: settings.arguments as int);
            }
            return const AccountDetails();
          },
          fullscreenDialog: true,
        );

      case addressList:
        return MaterialPageRoute(
          builder: (context) {
            if (settings.arguments == null) {
              return const AddressList();
            } else {
              return AddressList(
                isSelectable: settings.arguments as bool,
              );
            }
          },
          fullscreenDialog: true,
        );

      case addAddress:
        return MaterialPageRoute(
          builder: (context) {
            AddressModel? item;
            bool? isSelectable;
            if (settings.arguments != null) {
              item = (settings.arguments as Map<String, dynamic>)['item'];
              isSelectable =
                  (settings.arguments as Map<String, dynamic>)['isSelectable'];
            }
            return AddAddress(item: item, isSelectable: isSelectable);
          },
          fullscreenDialog: true,
        );

      case views:
        return MaterialPageRoute(
          builder: (context) {
            return const Views();
          },
          fullscreenDialog: true,
        );

      case category:
        return MaterialPageRoute(
          builder: (context) {
            if (settings.arguments is int) {
              return Category(
                parentId: settings.arguments as int,
              );
            } else if (settings.arguments is Map) {
              return Category(
                parentId: (settings.arguments as Map)['categoryId'] as int,
              );
            }
            return const Category();
          },
        );

      case brand:
        return MaterialPageRoute(
          builder: (context) {
            if (settings.arguments is int) {
              return Brand(
                categoryId: settings.arguments as int,
              );
            }
            return const Brand();
          },
        );

      case profile:
        return MaterialPageRoute(
          builder: (context) {
            if (settings.arguments is String) {
              return Profile(userId: settings.arguments as String);
            } else {
              return Profile(
                  userId:
                      (settings.arguments as Map<String, dynamic>)['userId']);
            }
          },
        );

      case listProfile:
        return MaterialPageRoute(
          builder: (context) {
            // return const ListProfile();
            return ListProfile(userType: settings.arguments as UserType);
          },
        );

      case profileQRCode:
        return MaterialPageRoute(
          builder: (context) {
            return ProfileQRCode(user: settings.arguments as UserModel);
          },
          fullscreenDialog: true,
        );

      case submit:
        return MaterialPageRoute(
          builder: (context) {
            ProductModel? item;
            if (settings.arguments != null) {
              item = settings.arguments as ProductModel;
            }
            return Submit(item: item);
          },
          fullscreenDialog: true,
        );

      case editProfile:
        return MaterialPageRoute(
          builder: (context) {
            return const EditProfile();
          },
        );

      case changePassword:
        return MaterialPageRoute(
          builder: (context) {
            return ChangePassword(
              token: settings.arguments is Map<String, dynamic>
                  ? (settings.arguments as Map<String, dynamic>)['token']
                  : null,
              countryCode: settings.arguments is Map<String, dynamic>
                  ? (settings.arguments as Map<String, dynamic>)['countryCode']
                  : null,
              phoneNumber: settings.arguments is Map<String, dynamic>
                  ? (settings.arguments as Map<String, dynamic>)['phoneNumber']
                  : null,
            );
          },
        );

      case changeLanguage:
        return MaterialPageRoute(
          builder: (context) {
            return const LanguageSetting();
          },
        );

      case themeSetting:
        return MaterialPageRoute(
          builder: (context) {
            return const ThemeSetting();
          },
        );

      case filter:
        return MaterialPageRoute(
          builder: (context) {
            return Filter(filter: settings.arguments as FilterModel);
          },
          fullscreenDialog: true,
        );

      case review:
        return MaterialPageRoute(
          builder: (context) {
            return Review();
          },
        );

      case productReview:
        return MaterialPageRoute(
          builder: (context) {
            return ProductReview(product: settings.arguments as ProductModel);
          },
        );

      case blockedUsersList:
        return MaterialPageRoute(
          builder: (context) {
            return const BlockedUsersList();
          },
        );

      case chatList:
        return MaterialPageRoute(
          builder: (context) {
            return const ChatUsersList();
          },
        );

      case chat:
        return MaterialPageRoute(
          builder: (context) {
            if (settings.arguments is ChatUserModel) {
              return ChatScreen(chatUser: settings.arguments as ChatUserModel);
            }
            return ChatScreen(
              chatUser: (settings.arguments as Map<String, dynamic>)['user'],
              questionMessage:
                  (settings.arguments as Map<String, dynamic>)['question'],
            );

            // return ChatScreen2(chatUser: settings.arguments as ChatUserModel);
          },
        );

      case setting:
        return MaterialPageRoute(
          builder: (context) {
            return const Setting();
          },
        );

      case fontSetting:
        return MaterialPageRoute(
          builder: (context) {
            return const FontSetting();
          },
        );

      case feedback:
        return MaterialPageRoute(
          builder: (context) => screen.Feedback(
            productId: (settings.arguments as Map)['productId'],
            totalRate: (settings.arguments as Map)['totalRate'],
            review: (settings.arguments as Map)['review'],
            type: (settings.arguments as Map)['type'],
          ),
        );

      case shippingFeedback:
        return MaterialPageRoute(
          builder: (context) =>
              ShippingFeedback(orderId: settings.arguments as int),
        );

      case location:
        return MaterialPageRoute(
          builder: (context) => Location(
            location: settings.arguments as CoordinateModel,
          ),
        );

      case listProduct:
        return MaterialPageRoute(
          builder: (context) {
            var categoryId = (settings.arguments as Map)['categoryId'];
            var locationId = (settings.arguments as Map)['locationId'];
            var featureId = (settings.arguments as Map)['featureId'];
            var brandId = (settings.arguments as Map)['brandId'];
            return ListProduct(
                locationId: locationId,
                categoryId: categoryId,
                featureId: featureId,
                brandId: brandId);
          },
        );

      case gallery:
        return MaterialPageRoute(
          builder: (context) {
            return Gallery(product: settings.arguments as ProductModel);
          },
          fullscreenDialog: true,
        );

      case galleryUpload:
        return MaterialPageRoute(
          builder: (context) {
            return GalleryUpload(
              images: settings.arguments as List<String>,
            );
          },
          fullscreenDialog: true,
        );

      case categoryPicker:
        return MaterialPageRoute(
          builder: (context) {
            return CategoryPicker(
              picker: settings.arguments as PickerModel,
            );
          },
          fullscreenDialog: true,
        );

      case gpsPicker:
        return MaterialPageRoute(
          builder: (context) {
            CoordinateModel? item;
            if (settings.arguments != null) {
              item = settings.arguments as CoordinateModel;
            }
            return GPSPicker(
              picked: item,
            );
          },
          fullscreenDialog: true,
        );

      case picker:
        return MaterialPageRoute(
          builder: (context) {
            return Picker(
              picker: settings.arguments as PickerModel,
            );
          },
          fullscreenDialog: true,
        );

      case openTime:
        return MaterialPageRoute(
          builder: (context) {
            List<OpenTimeModel>? arguments;
            if (settings.arguments != null) {
              arguments = settings.arguments as List<OpenTimeModel>;
            }
            return OpenTime(
              selected: arguments,
            );
          },
          fullscreenDialog: true,
        );
      case socialNetwork:
        return MaterialPageRoute(
          builder: (context) {
            return SocialNetwork(
              socials: settings.arguments as Map<String, dynamic>?,
            );
          },
          fullscreenDialog: true,
        );

      case submitSuccess:
        return MaterialPageRoute(
          builder: (context) {
            return const SubmitSuccess();
          },
          fullscreenDialog: true,
        );

      case tagsPicker:
        return MaterialPageRoute(
          builder: (context) {
            return TagsPicker(
              selected: settings.arguments as List<String>,
            );
          },
          fullscreenDialog: true,
        );

      case sizesPicker:
        return MaterialPageRoute(
          builder: (context) {
            return SizesPicker(
              selected: settings.arguments as List<String>,
            );
          },
          fullscreenDialog: true,
        );

      case webView:
        return MaterialPageRoute(
          builder: (context) {
            return Web(
              web: settings.arguments as WebViewModel,
            );
          },
          fullscreenDialog: true,
        );
      case paypalPayment:
        return MaterialPageRoute(
          builder: (context) {
            return PaypalPayment(
              onFinish: settings.arguments as Function,
            );
          },
        );

      case shoppingCart:
        return MaterialPageRoute(
          builder: (context) {
            return const ShoppingCart();
          },
        );

      case checkOut:
        return MaterialPageRoute(
          builder: (context) {
            return CheckOut(
              id: settings.arguments as int,
            );
          },
        );

      case checkOutRefund:
        return MaterialPageRoute(
          builder: (context) {
            return CheckOutRefund(
              id: settings.arguments as int,
            );
          },
        );

      case order:
        return MaterialPageRoute(
          builder: (context) {
            return Order(
              id: settings.arguments as int,
            );
          },
        );

      case orderList:
        return MaterialPageRoute(
          builder: (context) {
            return const OrderList();
          },
        );

      case customerOrderList:
        return MaterialPageRoute(
          builder: (context) {
            return const CustomerOrderList();
          },
        );

      case incompleteOrderList:
        return MaterialPageRoute(
          builder: (context) {
            return const IncompleteOrderList();
          },
        );

      case orderDetail:
        return MaterialPageRoute(
          builder: (context) {
            return OrderDetail(
              arguments: settings.arguments as RouteArguments,
            );
          },
        );

      case orderItemList:
        return MaterialPageRoute(
          builder: (context) {
            return OrderItemList(
              arguments: settings.arguments as RouteArguments,
            );
          },
        );

      default:
        return MaterialPageRoute(
          builder: (context) {
            return Scaffold(
              appBar: AppBar(
                title: const Text("Not Found"),
              ),
              body: Center(
                child: Text('No path for ${settings.name}'),
              ),
            );
          },
        );
    }
  }

  ///Singleton factory
  static final Routes _instance = Routes._internal();

  factory Routes() {
    return _instance;
  }

  Routes._internal();
}
