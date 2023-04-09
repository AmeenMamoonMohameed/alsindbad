abstract class OrderStyleModel {
  String price;
  int? adult;
  int? children;

  OrderStyleModel({
    required this.price,
    this.adult,
    this.children,
  });

  Map<String, dynamic> get params;
}
