import '../configs/application.dart';
import '../configs/image.dart';
import 'model.dart';

enum UserType { owner, broker, office, company }

enum Gender { male, female }

class UserModel {
  late final String userId;
  late final num membershipNo;
  late String userName;
  // late String nickName;
  late String accountName;
  late Gender gender;
  late String fullName;
  late String countryCode;
  late String phoneNumber;
  late bool isAppearPhoneNumber;
  late String profilePictureDataUrl;
  late String url;
  late final int userLevel;
  late String description;
  late final String tag;
  late int views;
  late double ratingAvg;
  late final int totalComment;
  late int total;
  late final String token;
  // late final String refreshToken;
  late String email;
  late UserType userType;
  late bool phoneNumberConfirmed;
  late int addresses;
  late int shoppingCarts;
  late int customerOrders;
  late int orders;
  late bool isVerified;
  late List<ExtendedAttributeModel>? extendedAttributes;

  UserModel({
    required this.userId,
    required this.membershipNo,
    required this.userName,
    // required this.nickName,
    required this.accountName,
    required this.fullName,
    this.gender = Gender.male,
    required this.countryCode,
    required this.phoneNumber,
    this.isAppearPhoneNumber = false,
    required this.profilePictureDataUrl,
    required this.url,
    required this.userLevel,
    required this.description,
    required this.tag,
    required this.views,
    required this.ratingAvg,
    required this.totalComment,
    required this.total,
    required this.token,
    // required this.refreshToken,
    required this.email,
    required this.userType,
    required this.phoneNumberConfirmed,
    this.addresses = 0,
    this.shoppingCarts = 0,
    this.customerOrders = 0,
    this.orders = 0,
    this.isVerified = false,
    this.extendedAttributes,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    List<ExtendedAttributeModel>? extendedAttributes = [];
    var gender = Gender.male;
    if (json['gender'] != null) {
      gender = Gender.values[int.parse(json['gender'].toString())];
    }

    var userType = UserType.owner;
    if (json['userType'] != null) {
      userType = UserType.values[int.parse(json['userType'].toString())];
    }
    if (json['extendedAttributes'] != null) {
      extendedAttributes =
          List.from(json['extendedAttributes'] ?? []).map((item) {
        return ExtendedAttributeModel.fromJson(item);
      }).toList();
    }
    return UserModel(
      userId: json['id'] ?? 'Unknown',
      membershipNo: json['membershipNo'] ?? 0,
      userName: json['userName'] ?? 'Unknown',
      // nickName: json['userName'] ?? 'Unknown',
      accountName: json['accountName'] ?? 'Unknown',
      fullName: json['fullName'] ?? 'Unknown',
      gender: gender,
      countryCode: json['countryCode'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      isAppearPhoneNumber: json['isAppearPhoneNumber'] ?? false,
      profilePictureDataUrl: json['profilePictureDataUrl'] ?? '',
      url: json['url'] ?? 'Unknown',
      userLevel: json['userLevel'] ?? 0,
      description: json['description'] ?? 'description',
      tag: json['tag'] ?? json['Tag'] ?? 'Unknown',
      views: int.tryParse('${json['views']}') ?? 0,
      ratingAvg: double.tryParse('${json['ratingAvg']}') ?? 0.0,
      totalComment: int.tryParse('${json['totalComment']}') ?? 0,
      total: json['total'] ?? 0,
      token: json['token'] ?? "Unknown",
      // refreshToken: json['refreshToken'] ?? "Unknown",
      email: json['email'] ?? 'Unknown',
      userType: userType,
      phoneNumberConfirmed: json['phoneNumberConfirmed'] ?? false,
      addresses: json['addresses'] ?? 0,
      shoppingCarts: json['shoppingCarts'] ?? 0,
      customerOrders: json['customerOrders'] ?? 0,
      orders: json['orders'] ?? 0,
      isVerified: json['isVerified'] ?? false,
      extendedAttributes: extendedAttributes,
    );
  }

  UserModel updateUser({
    // String? nickname,
    String? accountName,
    String? fullName,
    Gender? gender,
    String? countryCode,
    String? phoneNumber,
    bool? isAppearPhoneNumber,
    String? email,
    String? url,
    String? description,
    String? image,
    int? total,
    bool? phoneNumberConfirmed,
    int? views,
    double? ratingAvg,
    int? addresses,
    int? shoppingCarts,
    int? customerOrders,
    int? orders,
    bool? isVerified,
    List<ExtendedAttributeModel>? extendedAttributes,
  }) {
    // this.nickName = userName ?? this.userName;
    this.accountName = accountName ?? this.accountName;
    this.fullName = fullName ?? this.fullName;
    this.gender = gender ?? this.gender;
    this.countryCode = countryCode ?? this.countryCode;
    this.phoneNumber = phoneNumber ?? this.phoneNumber;
    this.isAppearPhoneNumber = isAppearPhoneNumber ?? this.isAppearPhoneNumber;
    this.email = email ?? this.email;
    this.url = url ?? this.url;
    this.description = description ?? this.description;
    profilePictureDataUrl = image ?? profilePictureDataUrl;
    this.total = total ?? this.total;
    this.phoneNumberConfirmed =
        phoneNumberConfirmed ?? this.phoneNumberConfirmed;
    this.views = views ?? this.views;
    this.ratingAvg = ratingAvg ?? this.ratingAvg;
    this.addresses = addresses ?? this.addresses;
    this.shoppingCarts = shoppingCarts ?? this.shoppingCarts;
    this.orders = orders ?? this.orders;
    this.customerOrders = customerOrders ?? this.customerOrders;
    this.isVerified = isVerified ?? this.isVerified;
    this.extendedAttributes = extendedAttributes ?? this.extendedAttributes;
    return clone();
  }

  UserModel.fromSource(source) {
    userId = source.userId;
    membershipNo = source.membershipNo;
    userName = source.userName;
    // nickName = source.nickName;
    accountName = source.accountName;
    fullName = source.fullName;
    gender = source.gender;
    countryCode = source.countryCode;
    phoneNumber = source.phoneNumber;
    isAppearPhoneNumber = source.isAppearPhoneNumber;
    profilePictureDataUrl = source.profilePictureDataUrl;
    url = source.url;
    userLevel = source.userLevel;
    description = source.description;
    tag = source.tag;
    views = source.views;
    ratingAvg = source.ratingAvg;
    totalComment = source.totalComment;
    total = source.total;
    token = source.token;
    email = source.email;
    phoneNumberConfirmed = source.phoneNumberConfirmed;
    addresses = source.addresses;
    shoppingCarts = source.shoppingCarts;
    customerOrders = source.customerOrders;
    orders = source.orders;
    isVerified = source.isVerified;
    extendedAttributes = source.extendedAttributes;
    // refreshToken = source.refreshToken;
  }

  UserModel clone() {
    return UserModel.fromSource(this);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': userId,
      'membershipNo': membershipNo,
      'userName': userName,
      'accountName': accountName,
      'fullName': fullName,
      'gender': gender.index,
      'countryCode': countryCode,
      'phoneNumber': phoneNumber,
      'isAppearPhoneNumber': isAppearPhoneNumber,
      'image': profilePictureDataUrl,
      'url': url,
      'userLevel': userLevel,
      'description': description,
      'tag': tag,
      'views': views,
      'ratingAvg': ratingAvg,
      'totalComment': totalComment,
      'total': total,
      'token': token,
      'email': email,
      'phoneNumberConfirmed': phoneNumberConfirmed,
      'addresses': addresses,
      'shoppingCarts': shoppingCarts,
      'customerOrders': customerOrders,
      'orders': orders,
      'isVerified': isVerified,
      'extendedAttributes': extendedAttributes?.map((e) => e.toJson()).toList(),
      // 'refreshToken': refreshToken,
    };
  }

  String getProfileImage({String? imageType}) {
    if (profilePictureDataUrl.isNotEmpty) {
      return "${Application.domain}$profilePictureDataUrl"
          .replaceAll("\\", "/")
          .replaceAll("TYPE", imageType ?? "thumb");
    }
    return '';
  }
}
