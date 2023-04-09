import 'dart:async';
import 'package:akarak/api/http_manager.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/utils/utils.dart';
import '../blocs/app_bloc.dart';
import 'package:uuid/uuid.dart';

class Api {
  static final httpManager = HTTPManager();

  ///URL API
  static const String loadNotification = "api/v1/notifications/list";
  static const String login = "api/identity/token";
  static const String fetch = "api/identity/account";
  static const String authValidate = "api/identity/token/validateToken";
  static const String user = "api/identity/user/get-current";
  static const String register = "api/identity/user/register";
  static const String confirmPhoneNumber =
      "api/identity/user/confirm-phone-number";
  static const String confirmForgotPassword =
      "api/identity/user/confirm-forgot-password";
  static const String sendVerificationPhoneNumber =
      "api/identity/user/send-verification-phone-number";
  static const String forgotPassword = "api/identity/user/forgot-password";
  static const String validationPhoneNumber =
      "api/identity/user/validation-phone-number";
  static const String changePassword = "api/identity/account/changePassword";
  static const String resetPassword = "api/identity/user/reset-password";
  static const String changeProfile = "api/identity/account/updateProfile";
  static const String getUserRating = "api/identity/user/get-user-rating";
  static const String listAddress = "api/v1/shippingAddresses";
  static const String submitAddress = "api/v1/shippingAddresses";
  static const String removeAddress = "api/v1/shippingAddresses";
  static const String setDefaultAddress = "api/v1/shippingAddresses";
  static const String setting = "api/v1/setting/general";
  // static const String setting = "api/v1/setting";
  static const String submitSetting = "api/v1/setting/submit";
  static const String homeSections = "api/v1/homeSections";
  static const String home = "api/v1/home";
  static const String categories = "api/v1/categories";
  static const String discovery = "";
  static const String withLists = "api/v1/wishs";
  static const String addWishList = "api/v1/wishs/";
  static const String removeWishList = "api/v1/wishs/";
  static const String clearWithList = "api/v1/wishs/clear";
  static const String list = "api/v1/products/list";
  static const String deleteProduct = "api/v1/products";
  static const String authorList = "api/v1/products/user-list";
  static const String authorReview = "api/v1/reviews/list";
  static const String tags = "/akarak/v1/place/terms";
  static const String reviews = "api/v1/reviews/get-all-paged";
  static const String reviewsById = "api/v1/reviews/";
  static const String rating = "api/v1/reviews/get-rating/";
  static const String saveReview = "api/v1/reviews";
  static const String removeReview = "api/v1/reviews/";
  static const String saveReplay = "api/v1/reviews/replay";
  static const String removeReplay = "api/v1/reviews/replay/";
  static const String product = "api/v1/products/get";
  // static const String addView = "api/v1/products/add-view";
  static const String totalViews = "api/identity/views/";
  static const String userProductsViewsByDays =
      "api/identity/views/products-by-days";
  static const String userProductsViewsByHours =
      "api/identity/views/products-by-hours";
  static const String userProfileViewsByDays =
      "api/identity/views/profile-by-days";
  static const String userProfileViewsByHours =
      "api/identity/views/profile-by-hours";
  static const String addProductView = "api/identity/views/add-product-view";
  static const String addProfileView = "api/identity/views/add-profile-view";
  static const String saveProduct = "api/v1/products";
  static const String countries = "api/v1/countries";
  static const String locations = "api/v1/locations";
  static const String locationsById = "api/v1/locations/get-all/";
  static const String uploadImage = "api/utilities/upload/upload-image";
  static const String protectedUpload = "api/utilities/upload/protected-file";
  static const String uploadImageBytes = "api/utilities/upload/image";
  static const String createPaymentIntent =
      "api/v1/payment/create-payment-intent";
  static const String createPaypalLink = "api/v1/payment/create-paypal-link";
  static const String orderForm = "api/v1/orders/addtrttr-test";
  static const String calcPrice = "api/v1/orders/cart";
  static const String order = "api/v1/orders/order";
  static const String addDeleteCart = "api/v1/orders/add-delete-cart";
  static const String setShippingAddress = "api/v1/orders/set-shipping-address";
  static const String initOrder = "api/v1/orders/init-order";
  static const String removeFromCart = "api/v1/orders/remove-from-cart";
  static const String shippingFeeCalc = "api/v1/orders/shipping-fee-calc";
  static const String orderDetail = "api/v1/orders/by-id";
  static const String checkOut = "api/v1/orders/check-out";
  static const String customerOrderAmount =
      "api/v1/customerOrders/customer-order-amount";
  static const String orderList = "api/v1/orders/order-list";
  static const String customerOrderList = "api/v1/customerOrders";
  static const String outStockOrder = "api/v1/customerOrders/out-stock-order";
  static const String confirmCustomerOrder =
      "api/v1/customerOrders/confirm-customer-order";
  static const String confirmRefuseRefund =
      "api/v1/customerOrders/refusal-to-refund";
  static const String orderReceipt = "api/v1/orders/order-receipt";
  static const String shippingFeedback = "api/v1/orders/shipping-feedback";
  static const String refundRequest = "api/v1/orders/refund-request";
  static const String cancelRefundRequest =
      "api/v1/orders/cancel-refund-request";
  static const String complaint = "api/v1/orders/complaint";
  static const String closeComplaint = "api/v1/orders/close-complaint";
  static const String orderCancel = "api/v1/orders";
  static const String orderItemCancel = "api/v1/orders/cancel-order-item";
  static const String sendContactUs = "api/v1/contactUs";
  static const String blockUser = "api/identity/user/block-user";
  static const String unblockUser = "api/identity/user/unblock-user";
  static const String sendProductReport = "api/v1/products/send-report";
  static const String sendProfileReport = "api/identity/user/send-report";
  static const String sendReviewReport = "api/v1/reviews/send-report";
  static const String sendChatReport = "api/v1/chats/send-report";
  static const String chatLoadById = "api/chats/chat-by-id";
  static const String chatLoadByContact = "api/chats/chat-by-contact";
  static const String saveMessage = "api/chats";
  static const String setReaction = "api/chats/set-reaction";
  static const String confirmReceiptStatus = "api/chats/confirm-receipt-status";
  static const String sendReadStatus = "api/chats/send-read-status";
  static const String sendDeliveredStatus = "api/chats/send-delivered-status";
  static const String sendDeliveredStatusUsers =
      "api/chats/send-delivered-status-users";
  static const String blockedUsers = "api/chats/blocked-users";
  static const String chatUsers = "api/chats/users";
  static const String profiles = "api/v1/companies";
  static const String deactivate = "api/identity/account/deactive";

  /// Load Notification
  static Future<ResultApiModel> requestLoadNotification(params) async {
    final result = await httpManager.get(
        url:
            '$loadNotification?pageNumber=${params['pageNumber']}&pageSize=${params['pageSize']}');
    return ResultApiModel.fromJson(result);
  }

  ///Login api
  static Future<ResultApiModel> requestLogin(params) async {
    final result = await httpManager.post(url: login, data: params);
    if (result['succeeded'] == true) {
      HTTPManager.key = const Uuid().v4();
    }
    return ResultApiModel.fromJson(result);
  }

  ///Fetch api
  static Future<ResultApiModel> requestFetch() async {
    final result = await httpManager.get(url: fetch);
    if (result['succeeded'] == true) {
      HTTPManager.key = const Uuid().v4();
    }
    return ResultApiModel.fromJson(result);
  }

  ///Validate token valid
  static Future<ResultApiModel> requestValidateToken() async {
    Map<String, dynamic> result = {};
    try {
      result = await httpManager.post(url: authValidate);
      result['success'] = result['code'] == 'jwt_auth_valid_token';
      result['message'] = result['code'] ?? result['message'];
    } catch (Exception) {
      result['success'] = result['code'] == 'jwt_auth_no_valid_token';
      result['message'] = result['code'] ?? 'jwt_auth_no_valid_token';
    }
    return ResultApiModel.fromJson(result);
  }

  ///Validation phone number
  static Future<ResultApiModel> requestValidationPhoneNumber(params) async {
    Map<String, dynamic> result = await httpManager.post(
      url: validationPhoneNumber,
      data: params,
      loading: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Forgot password
  static Future<ResultApiModel> requestSendVerifiyCodeForgotPassword(
      params) async {
    Map<String, dynamic> result = await httpManager.post(
      url: forgotPassword,
      data: params,
      loading: true,
    );
    result['message'] = result['code'] ?? result['msg'];
    return ResultApiModel.fromJson(result);
  }

  ///Confirm Forgot Password
  static Future<ResultApiModel> requestConfirmForgotPassword(params) async {
    final result = await httpManager.post(
      // url:
      //     "$confirmForgotPassword/${params['countryCode']}/${params['phoneNumber']}/${params['otp']}",
      url: confirmForgotPassword,
      data: params,
      loading: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Register account
  static Future<ResultApiModel> requestRegister(params) async {
    final result = await httpManager.post(
      url: register,
      data: params,
      loading: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Confirm PhoneNumber
  static Future<ResultApiModel> requestConfirmPhoneNumber(params) async {
    final result = await httpManager.post(
      url: "$confirmPhoneNumber/${params['userId']}/${params['otp']}",
      // data: params,
      loading: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Resend Verification PhoneNumber
  static Future<ResultApiModel> requestSendVerificationPhoneNumber(
      params) async {
    final result = await httpManager.post(
      url:
          "$sendVerificationPhoneNumber/${params['userId']}/${params['confirmType']}",
      // data: params,
      loading: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Change Profile
  static Future<ResultApiModel> requestChangeProfile(params) async {
    final result = await httpManager.put(
      url: changeProfile,
      data: params,
      loading: true,
    );
    // final convertResponse = {
    //   "success": result['code'] == null,
    //   "message": result['code'] ?? "update_info_success",
    //   "data": result
    // };
    return ResultApiModel.fromJson(result);
  }

  ///change password
  static Future<ResultApiModel> requestChangePassword(params) async {
    final result = await httpManager.put(
      url: changePassword,
      data: params,
      loading: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///change password
  static Future<ResultApiModel> requestResetPassword(params) async {
    final result = await httpManager.post(
      url: resetPassword,
      data: params,
      loading: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Get User
  static Future<ResultApiModel> requestUser() async {
    final result = await httpManager.get(url: user);
    return ResultApiModel.fromJson(result);
  }

  static Future<ResultApiModel> requestUserRating(String userId) async {
    final result =
        await httpManager.get(url: "$getUserRating/$userId", loading: true);
    return ResultApiModel.fromJson(result);
  }

  ///All Address
  static Future<ResultApiModel> requestAllAddresses() async {
    final result = await httpManager.get(url: listAddress, loading: true);
    return ResultApiModel.fromJson(result);
  }

  ///Submit Address
  static Future<ResultApiModel> requestSubmitAddress(param) async {
    final result =
        await httpManager.post(url: submitAddress, data: param, loading: true);
    return ResultApiModel.fromJson(result);
  }

  ///Remove Address
  static Future<ResultApiModel> requestRemoveAddress(id) async {
    final result =
        await httpManager.delete(url: "$removeAddress/$id", loading: true);
    return ResultApiModel.fromJson(result);
  }

  ///Set The Default Address
  static Future<ResultApiModel> requestSetDefaultAddress(param) async {
    final result = await httpManager.put(
        url: setDefaultAddress, data: param, loading: false);
    return ResultApiModel.fromJson(result);
  }

  ///Get Setting
  static Future<ResultApiModel> requestSetting() async {
    final result = await httpManager.get(url: setting);
    return ResultApiModel.fromJson(result);
  }

  ///Get Submit Setting
  static Future<ResultApiModel> requestSubmitSetting(int countryId) async {
    final result = await httpManager.get(
      url: "$submitSetting/$countryId",
      // params: params,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Get Countries
  static Future<ResultApiModel> requestCountries() async {
    final result = await httpManager.get(url: countries, loading: false);

    return ResultApiModel.fromJson(result);
  }

  ///Get Location
  static Future<ResultApiModel> requestLocation(LocationType? type) async {
    String url = locations;
    if (type != null) {
      url = "$locations?type=${type.index}";
    }
    final result = await httpManager.get(url: url);
    return ResultApiModel.fromJson(result);
  }

  ///Get Location
  static Future<ResultApiModel> requestLocationById(param) async {
    String url = "$locationsById${param['countryId']}";
    if (param['parentId'] != null) {
      url = "$url/${param['parentId']}";
    }
    final result = await httpManager.get(url: url, loading: false);
    return ResultApiModel.fromJson(result);
  }

  ///Get Category
  static Future<ResultApiModel> requestCategory() async {
    final result = await httpManager.get(url: categories);
    return ResultApiModel.fromJson(result);
  }

  ///Get Discovery
  static Future<ResultApiModel> requestDiscovery() async {
    final result = await httpManager.get(url: discovery);
    return ResultApiModel.fromJson(result);
  }

  ///Get Home
  static Future<ResultApiModel> requestHome() async {
    final result = await httpManager.get(url: home);
    return ResultApiModel.fromJson(result);
  }

  ///Get Home Sections
  static Future<ResultApiModel> requestHomeSections(params) async {
    String url =
        "$homeSections?pageNumber=${params['pageNumber']}&pageSize=${params['pageSize']}";
    final result = await httpManager.get(url: url);
    return ResultApiModel.fromJson(result);
  }

  ///Get User Products Views (By Days)
  static Future<ResultApiModel> requestProductsByDaysViews(params) async {
    final result = await httpManager.get(
        url:
            "$userProductsViewsByDays/${params['from']}/${params['to']}/${params['pageNumber']}/${params['pageSize']}");
    return ResultApiModel.fromJson(result);
  }

  ///Get Total Views
  static Future<ResultApiModel> requestTotalViews() async {
    final result = await httpManager.get(url: totalViews);
    return ResultApiModel.fromJson(result);
  }

  ///Get User Products Views (By Hours)
  static Future<ResultApiModel> requestProductsByHoursViews(params) async {
    final result = await httpManager.get(
        url:
            "$userProductsViewsByHours/${params['from']}/${params['to']}/${params['pageNumber']}/${params['pageSize']}");
    return ResultApiModel.fromJson(result);
  }

  ///Get User Profile Views (By Days)
  static Future<ResultApiModel> requestProfileByDaysViews(params) async {
    final result = await httpManager.get(
        url:
            "$userProfileViewsByDays/${params['from']}/${params['to']}/${params['pageNumber']}/${params['pageSize']}");
    return ResultApiModel.fromJson(result);
  }

  ///Get User Profile Views (By Hours)
  static Future<ResultApiModel> requestProfileByHoursViews(params) async {
    final result = await httpManager.get(
        url:
            "$userProfileViewsByHours/${params['from']}/${params['to']}/${params['pageNumber']}/${params['pageSize']}");
    return ResultApiModel.fromJson(result);
  }

  ///Get ProductDetail
  static Future<ResultApiModel> requestProduct(params) async {
    final result = await httpManager.get(
      url: "$product/${params['id']}",
    );
    if (result['succeeded'] == true) {
      httpManager.post(url: "$addProductView/${params['id']}").ignore();
      // httpManager.product(url: addView, data: params).ignore();
    }
    return ResultApiModel.fromJson(result);
  }

  ///Get Wish List
  static Future<ResultApiModel> requestWishList(params) async {
    final result =
        await httpManager.get(url: withLists, params: {'id': params});
    return ResultApiModel.fromJson(result);
  }

  ///Save Wish List
  static Future<ResultApiModel> requestAddWishList(params) async {
    final result = await httpManager.post(
        url: addWishList + params.toString(), loading: false);
    return ResultApiModel.fromJson(result);
  }

  ///Save Product
  static Future<ResultApiModel> requestSaveProduct(params) async {
    final result = await httpManager.post(
      url: saveProduct,
      data: params,
      loading: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Remove Wish List
  static Future<ResultApiModel> requestRemoveWishList(params) async {
    final result = await httpManager.delete(
      url: removeWishList + params.toString(),
      loading: false,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Clear Wish List
  static Future<ResultApiModel> requestClearWishList() async {
    final result = await httpManager.delete(url: clearWithList, loading: true);
    return ResultApiModel.fromJson(result);
  }

  ///Get Product List
  static Future<ResultApiModel> requestList(params, loading) async {
    final result = await httpManager.post(
      url: list,
      data: params,
      loading: false, //loading ?? false,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Get Tags List
  static Future<ResultApiModel> requestTags(params) async {
    final result = await httpManager.get(url: tags, params: params);
    return ResultApiModel.fromJson(result);
  }

  ///Clear Wish List
  static Future<ResultApiModel> requestDeleteProduct(id) async {
    final result = await httpManager.delete(
      url: "$deleteProduct/$id",
      loading: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Get Author Product List
  static Future<ResultApiModel> requestAuthorList(params) async {
    final result = await httpManager.post(
      url: authorList,
      data: params,
      loading: true,
    );
    httpManager.post(url: "$addProfileView/${params['createdBy']}").ignore();
    return ResultApiModel.fromJson(result);
  }

  ///Get Author Review List
  static Future<ResultApiModel> requestAuthorReview(params) async {
    final result = await httpManager.post(
      url: authorReview,
      data: params,
      loading: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Get Rating
  static Future<ResultApiModel> requestRating() async {
    final result = await httpManager.get(url: rating);
    return ResultApiModel.fromJson(result);
  }

  ///Get Review
  static Future<ResultApiModel> requestReview(params) async {
    final result = await httpManager.get(
        url:
            '$reviews?pageNumber=${params['pageNumber']}&pageSize=${params['pageSize']}&searchString=${params['searchString']}');
    return ResultApiModel.fromJson(result);
  }

  ///Get Review For Product
  static Future<ResultApiModel> requestReviewById(params) async {
    final result = await httpManager.get(
        url: reviewsById + params["productId"].toString());
    return ResultApiModel.fromJson(result);
  }

  ///Save Review
  static Future<ResultApiModel> requestSaveReview(params) async {
    final result = await httpManager.post(
      url: saveReview,
      data: params,
      loading: true,
    );

    return ResultApiModel.fromJson(result);
  }

  ///Save Replay
  static Future<ResultApiModel> requestSaveReplay(params) async {
    final result = await httpManager.post(
      url: saveReplay,
      data: params,
      loading: true,
    );

    return ResultApiModel.fromJson(result);
  }

  ///Remove Review
  static Future<ResultApiModel> requestRemoveReview(id) async {
    final result = await httpManager.delete(
      url: removeReview + id.toString(),
      loading: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Remove Replay
  static Future<ResultApiModel> requestRemoveReplay(id) async {
    final result = await httpManager.delete(
      url: removeReplay + id.toString(),
      loading: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Get Companies
  static Future<ResultApiModel> requestProfiles({
    required int pageNumber,
    required int pageSize,
    required String searchString,
    required int userType,
    bool loading = false,
  }) async {
    final result = await httpManager.get(
        url:
            "$profiles?pageNumber=$pageNumber&pageSize=$pageSize&searchString=$searchString&userType=$userType");
    return ResultApiModel.fromJson(result);
  }

  ///Upload image
  static Future<ResultApiModel> requestUploadImage(formData, progress) async {
    var result = await httpManager.post(
      url: uploadImage,
      formData: formData,
      progress: progress,
    );

    final convertResponse = {"success": result['id'] != null, "data": result};
    return ResultApiModel.fromJson(convertResponse);
  }

  ///Upload image Bytes
  static Future<ResultApiModel> requestUploadImageBytes(
      params, progress) async {
    var result = await httpManager.post(
      url: uploadImageBytes,
      data: params,
      progress: progress,
    );

    // final convertResponse = {"success": result['id'] != null, "data": result};
    return ResultApiModel.fromJson(result);
  }

  ///Protected Upload
  static Future<ResultApiModel> requestProtectedUpload(params, progress) async {
    var result = await httpManager.post(
      url: protectedUpload,
      data: params,
      progress: progress,
    );

    // final convertResponse = {"success": result['id'] != null, "data": result};
    return ResultApiModel.fromJson(result);
  }

  ///Create PaymentIntent
  static Future<ResultApiModel> requestCreatePaymentIntent(params) async {
    final result = await httpManager.post(
      url: createPaymentIntent,
      data: params,
      loading: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Create PaymentIntent
  static Future<ResultApiModel> requestCreatePaypalLink(params) async {
    final result = await httpManager.post(
      url: createPaypalLink,
      data: params,
      loading: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Get order form
  static Future<ResultApiModel> requestOrderForm(params) async {
    final result = await httpManager.get(
      url: orderForm,
      // params: params,
      loading: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Get Price
  static Future<ResultApiModel> requestPrice(params) async {
    final result = await httpManager.post(
      url: calcPrice,
      data: params,
      loading: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Get Order
  static Future<ResultApiModel> requestOrder(params) async {
    final result = await httpManager.post(
      url: order,
      data: params,
      loading: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Shipping Fee Calc
  static Future<ResultApiModel> requestShippingFeeCalc(
      id, latitude, longitude) async {
    final result =
        await httpManager.get(url: '$shippingFeeCalc/$id/$latitude/$longitude');
    return ResultApiModel.fromJson(result);
  }

  ///Get Order Detail
  static Future<ResultApiModel> requestOrderDetail(id) async {
    dynamic result;
    if (id == null) {
      result = await httpManager.get(url: '$orderDetail/');
    } else {
      result = await httpManager.get(url: '$orderDetail/$id');
    }
    return ResultApiModel.fromJson(result);
  }

  ///Check Out
  static Future<ResultApiModel> requestCheckOut(id) async {
    final result = await httpManager.get(url: '$checkOut/$id');
    return ResultApiModel.fromJson(result);
  }

  /// Customer Order Amount
  static Future<ResultApiModel> requestCustomerOrderAmount(id) async {
    final result =
        await httpManager.get(url: '$customerOrderAmount/$id', loading: true);
    return ResultApiModel.fromJson(result);
  }

  ///Get Customer Order List
  static Future<ResultApiModel> requestCustomerOrderList(params) async {
    final result = await httpManager.get(
        url:
            "$customerOrderList?pageNumber=${params['pageNumber']}&pageSize=${params['pageSize']}&searchString=${params['searchString'] ?? ''}&orderStatus=${params['orderStatus'] ?? ''}&orderBy=${params['orderBy'] ?? ''}",
        loading: false);

    return ResultApiModel.fromJson(result);
  }

  ///Out Stock Order
  static Future<ResultApiModel> requestOutStockOrder(params) async {
    final result =
        await httpManager.post(url: outStockOrder, data: params, loading: true);
    return ResultApiModel.fromJson(result);
  }

  ///Confirm Customer Order
  static Future<ResultApiModel> requestConfirmCustomerOrder(params) async {
    final result = await httpManager.post(
        url: confirmCustomerOrder, data: params, loading: true);
    return ResultApiModel.fromJson(result);
  }

  ///Confirm Refuse Refund
  static Future<ResultApiModel> requestConfirmRefuseRefund(params) async {
    final result = await httpManager.post(
        url: confirmRefuseRefund, data: params, loading: true);
    return ResultApiModel.fromJson(result);
  }

  ///Get Order List
  static Future<ResultApiModel> requestOrderList(params) async {
    final result = await httpManager.get(
        url:
            "$orderList?pageNumber=${params['pageNumber']}&pageSize=${params['pageSize']}&searchString=${params['searchString'] ?? ''}&orderStatus=${params['orderStatus'] ?? ''}&orderBy=${params['orderBy'] ?? ''}",
        loading: false);
    return ResultApiModel.fromJson(result);
  }

  // ///Order Cancel
  // static Future<ResultApiModel> requestOrderCancel(params) async {
  //   final result = await httpManager.product(
  //     url: orderCancel,
  //     data: params,
  //     loading: true,
  //   );
  //   return ResultApiModel.fromJson(result);
  // }

  ///Order Receipt
  static Future<ResultApiModel> requestOrderReceipt(params) async {
    final result = await httpManager.post(
      url: orderReceipt,
      data: params,
      loading: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Shipping Feedback
  static Future<ResultApiModel> requestShippingFeedback(params) async {
    final result = await httpManager.post(
      url: shippingFeedback,
      data: params,
      loading: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Request Return
  static Future<ResultApiModel> requestRefundRequest(params) async {
    final result = await httpManager.post(
      url: refundRequest,
      data: params,
      loading: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Cancel Request Return
  static Future<ResultApiModel> requestCancelRefundRequest(params) async {
    final result = await httpManager.post(
      url: cancelRefundRequest,
      data: params,
      loading: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Complaint
  static Future<ResultApiModel> requestComplaint(params) async {
    final result = await httpManager.post(
      url: complaint,
      data: params,
      loading: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Close Complaint
  static Future<ResultApiModel> requestCloseComplaint(params) async {
    final result = await httpManager.post(
      url: closeComplaint,
      data: params,
      loading: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Order Cancel
  static Future<ResultApiModel> requestOrderCancel(params) async {
    final result = await httpManager.delete(
      url: "$orderCancel/${params['id']}",
      loading: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Order Cancel
  static Future<ResultApiModel> requestOrderItemCancel(params) async {
    // final result = await httpManager.delete(
    //   url: "$orderItemCancel/${params['orderId']}/${params['orderItemId']}",
    //   loading: true,
    // );
    final result = await httpManager.post(
      url: orderItemCancel,
      data: params,
      loading: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Add Delete Cart
  static Future<ResultApiModel> requestAddDeleteCart(productId) async {
    final result = await httpManager.post(url: "$addDeleteCart/$productId");
    return ResultApiModel.fromJson(result);
  }

  ///Set Shipping Address
  static Future<ResultApiModel> requestSetShippingAddress(params) async {
    final result = await httpManager.put(url: setShippingAddress, data: params);
    return ResultApiModel.fromJson(result);
  }

  ///CheckOut
  static Future<ResultApiModel> requestInitOrder(params) async {
    final result =
        await httpManager.post(url: initOrder, data: params, loading: true);
    return ResultApiModel.fromJson(result);
  }
  // static Future<ResultApiModel> requestCheckOut(params) async {
  //   final result =
  //       await httpManager.post(url: checkOut, data: params, loading: true);
  //   return ResultApiModel.fromJson(result);
  // }

  ///Download file
  static Future<ResultApiModel> requestDownloadFile({
    required FileModel file,
    required progress,
    String? directory,
  }) async {
    directory ??= await UtilFile.getFilePath();
    final filePath = '$directory/${file.name}.${file.type}';
    final result = await httpManager.download(
      url: file.url,
      filePath: filePath,
      progress: progress,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Deactivate account
  static Future<ResultApiModel> requestDeactivate(params) async {
    final result = await httpManager.post(
      url: "$deactivate/${params['deactiveReason']}",
      loading: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Block User
  static Future<ResultApiModel> requestBlockUser(params) async {
    final result = await httpManager.post(
      url: "$blockUser/${params['userId']}/${params['because']}",
      // data: params,
      loading: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///UnBlock User
  static Future<ResultApiModel> requestUnBlockUser(String userId) async {
    final result = await httpManager.post(
      url: "$unblockUser/$userId",
      loading: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Send Report
  static Future<ResultApiModel> requestSendReport(
      params, ReportType reportType) async {
    final result = await httpManager.post(
      url: reportType == ReportType.product
          ? sendProductReport
          : reportType == ReportType.profile
              ? sendProfileReport
              : reportType == ReportType.chat
                  ? sendChatReport
                  : sendReviewReport,
      data: params,
      loading: true,
    );
    if (result) {
      return ResultApiModel.fromJson({'succeeded': true, 'data': true});
    } else {
      return ResultApiModel.fromJson({'succeeded': true, 'data': false});
    }
  }

  ///Send Message Contact Us
  static Future<ResultApiModel> requestSendContactUs(params) async {
    final result = await httpManager.post(
      url: sendContactUs,
      data: params,
      loading: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Get Chat
  static Future<ResultApiModel> requestChat({
    required int chatId,
    required String contactId,
    required int pageNumber,
    required int pageSize,
    bool loading = false,
  }) async {
    dynamic result;
    if (chatId != 0) {
      result = await httpManager.get(
        url: "$chatLoadById/$chatId/$pageNumber/$pageSize",
        loading: loading,
      );
    } else {
      result = await httpManager.get(
        url: "$chatLoadByContact/$contactId/$pageNumber/$pageSize",
        loading: loading,
      );
    }
    return ResultApiModel.fromJson(result);
  }

  ///Save Message Chat
  static Future<ResultApiModel> requestSaveMessage(params, progress) async {
    final result = await httpManager.post(
      url: saveMessage,
      data: params,
      loading: false,
      progress: progress,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Set Reaction
  static Future<ResultApiModel> requestSetReaction(params) async {
    final result = await httpManager.post(
      url: setReaction,
      data: params,
      loading: false,
    );

    return ResultApiModel.fromJson(result);
  }

  ///Ping
  static Future requestConfirmReceiptStatus(statusType) async {
    await httpManager.post(
      url: "$confirmReceiptStatus/$statusType",
      loading: false,
    );
  }

  ///Send Read Status
  static Future<ResultApiModel> requestSendReadStatus(chatId) async {
    final result = await httpManager.post(
      url: "$sendReadStatus/$chatId",
      loading: false,
    );
    return ResultApiModel.fromJson(result);
  }
  // static Future<ResultApiModel> requestSendReadStatus(fromUserId) async {
  //   final result = await httpManager.post(
  //     url: "$sendReadStatus/$fromUserId",
  //     loading: false,
  //   );
  //   return ResultApiModel.fromJson(result);
  // }

  ///Send Delivered Status
  static Future<ResultApiModel> requestSendDeliveredStatus(chatId) async {
    final result = await httpManager.post(
      url: "$sendDeliveredStatus/$chatId",
      loading: false,
    );
    return ResultApiModel.fromJson(result);
  }
  // static Future<ResultApiModel> requestSendDeliveredStatus(fromUserId) async {
  //   final result = await httpManager.post(
  //     url: "$sendDeliveredStatus/$fromUserId",
  //     loading: false,
  //   );
  //   return ResultApiModel.fromJson(result);
  // }

  ///Send Delivered Status
  static Future<ResultApiModel> requestSendDeliveredStatusForUsers(
      List<int> chats) async {
    final result = await httpManager.post(
      url: sendDeliveredStatusUsers,
      data: chats,
      loading: false,
    );
    return ResultApiModel.fromJson(result);
  }
  // static Future<ResultApiModel> requestSendDeliveredStatusForUsers(
  //     List<String> users) async {
  //   final result = await httpManager.post(
  //     url: sendDeliveredStatusUsers,
  //     data: users,
  //     loading: false,
  //   );
  //   return ResultApiModel.fromJson(result);
  // }

  ///Chat Users
  static Future<ResultApiModel> requestChatUsers({
    required String keyword,
    required int pageNumber,
    required int pageSize,
    bool loading = false,
  }) async {
    final result = await httpManager.get(
      url:
          "$chatUsers/${keyword.isNotEmpty ? keyword : "empty"}/$pageNumber/$pageSize",
      loading: loading,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Blocked Users
  static Future<ResultApiModel> requestBlockedUsers({
    required String keyword,
    required int pageNumber,
    required int pageSize,
    bool loading = false,
  }) async {
    final result = await httpManager.get(
      url:
          "$blockedUsers/${keyword.isNotEmpty ? keyword : "empty"}/$pageNumber/$pageSize",
      loading: loading,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Singleton factory
  static final Api _instance = Api._internal();

  factory Api() {
    return _instance;
  }

  Api._internal();
}
