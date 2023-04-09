class Images {
  static const String intro1 = "assets/images/intro_1.png";
  static const String intro2 = "assets/images/intro_2.png";
  static const String intro3 = "assets/images/intro_3.png";
  static const String logo = "assets/images/logo.png";
  static const String slide = "assets/images/slide.png";
  static const String shoppingCart = "assets/images/shopping-cart.png";
  static const String commercialInvoices =
      "assets/images/commercial_invoices.png";
  static const String paypal = "assets/images/paypal.png";
  static const String orders = "assets/images/orders.png";
  static const String phone = "assets/images/phone.png";
  static const String whatsapp = "assets/images/whatsapp.png";
  static const String telegram = "assets/images/telegram.png";
  static const String viber = "assets/images/viber.png";
  static const String authenticated = "assets/images/authenticated.png";
  static const String facebook = "assets/images/facebook.png";
  static const String instagram = "assets/images/instagram.png";
  static const String flickr = "assets/images/flickr.png";
  static const String google = "assets/images/google.png";
  static const String linkedin = "assets/images/linkedin.png";
  static const String pinterest = "assets/images/pinterest.png";
  static const String youtube = "assets/images/youtube.png";
  static const String twitter = "assets/images/twitter.png";
  static const String tumblr = "assets/images/tumblr.png";
  static const String user = "assets/images/user.jpg";
  static const String message = "assets/images/message.png";
  static const String alarm = "assets/images/alarm.png";
  static const String address = "assets/images/address.png";
  static const String moreDetails = "assets/images/more-details.png";
  static const String pay = "assets/images/pay.png";
  static const String chatbackground = "assets/images/chat-background.jpg";

  ///Singleton factory
  static final Images _instance = Images._internal();

  factory Images() {
    return _instance;
  }

  Images._internal();
}
