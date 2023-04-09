// import 'package:flutter/material.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';

// class NoonClone extends StatefulWidget {
//   @override
//   _NoonCloneState createState() => _NoonCloneState();
// }

// class _NoonCloneState extends State<NoonClone> {
//   List<Product> products = [
//     Product(
//         id: 1,
//         title: 'هاتف ذكي',
//         price: 3000.0,
//         imageUrl: 'https://via.placeholder.com/150',
//         category: 'إلكترونيات'),
//     // أضف المزيد من المنتجات هنا
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('نون كلون'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.filter_list),
//             onPressed: () => _showFilters(context),
//           ),
//         ],
//       ),
//       body:                       
//       //  StaggeredGrid.count(
//       //                     crossAxisCount: 4,
//       //                     mainAxisSpacing: 4,
//       //                     // crossAxisSpacing: 4,
//       //                     children: [
//       //                       StaggeredGridTile.count(
//       //                         crossAxisCellCount: 1,
//       //                         mainAxisCellCount: 1,
//       //                         child: 
//       //                         Container(
//       //                           child: Center(
//       //                             child: actionGalleries,
//       //                           ),
//       //                         ),
//       //                       ),
//       //                     ],
//       //                   ),
//        StaggeredGridView.countBuilder(
//         crossAxisCount: 4,
//         itemCount: products.length,
//         itemBuilder: (BuildContext context, int index) => _buildProductCard(products[index]),
//         staggeredTileBuilder: (int index) => StaggeredTile.fit(2),
//         mainAxisSpacing: 4.0,
//         crossAxisSpacing: 4.0,
//       ),
//     );
//   }

//   Widget _buildProductCard(Product product) {
//     return Card(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Image.network(product.imageUrl),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Text(product.title),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 8.0),
//             child: Text(
//               NumberFormat.currency(locale: 'ar', symbol: 'ج.م.').format(product.price),
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showFilters(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         final filterNotifier = Provider.of<FilterNotifier>(context, listen: false);
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               title: Text('فلاتر'),
//               content: SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     ListTile(
//                       title: Text('الكل'),
//                       trailing: Radio(
//                         value: '',
//                         groupValue: filterNotifier.selectedCategory,
//                         onChanged: (value) {
//                           filterNotifier.selectedCategory = value;
//                           setState(() {});
//                         },
//                       ),
//                     ),
//                     ListTile(
//                       title: Text('إلكترونيات'),
//                       trailing: Radio(
//                         value: 'إلكترونيات',
//                         groupValue: filterNotifier.selectedCategory,
//                         onChanged: (value) {
//                           filterNotifier.selectedCategory = value;
//                           setState(() {});
//                         },
//                       ),
//                     ),
//                     // أضف المزيد من الفلاتر هنا
//                   ],
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   child: Text('تطبيق الفلاتر'),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
// }

// class Product {
//   final int id;
//   final String title;
//   final double price;
//   final String imageUrl;
//   final String category;

//   Product({
//     required this.id,
//     required this.title,
//     required this.price,
//     required this.imageUrl,
//     required this.category,
//   });
// }

// class FilterNotifier extends ChangeNotifier {
//   String _selectedCategory = '';

//   String get selectedCategory => _selectedCategory;

//   set selectedCategory(String value) {
//     _selectedCategory = value;
//     notifyListeners();
//   }
// }
