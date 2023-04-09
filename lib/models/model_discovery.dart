import 'package:akarak/configs/config.dart';
import 'package:akarak/models/model.dart';

class DiscoveryModel {
  final CategoryModel category;
  final List<ProductModel> list;

  DiscoveryModel({
    required this.category,
    required this.list,
  });

  factory DiscoveryModel.fromJson(Map<String, dynamic> json) {
    return DiscoveryModel(
      category: CategoryModel.fromJson(json),
      list: List.from(json['products'] ?? []).map((e) {
        return ProductModel.fromJson(e, setting: Application.setting);
      }).toList(),
    );
  }
}
