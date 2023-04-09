import 'package:bloc/bloc.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/repository/repository.dart';

class ProductDetailCubit extends Cubit<ProductDetailState> {
  ProductDetailCubit() : super(ProductDetailLoading());
  ProductModel? product;

  void onLoad(int id) async {
    final result = await ListRepository.loadProduct(id);
    if (result != null) {
      product = result;
      emit(ProductDetailSuccess(product!));
    }
  }

  Future<bool> onFavorite() async {
    var result = false;
    if (product != null) {
      product!.favorite = !product!.favorite;
      emit(ProductDetailSuccess(product!));
      if (product!.favorite) {
        result = await AppBloc.wishListCubit.onAdd(product!.id);
      } else {
        result = await AppBloc.wishListCubit.onRemove(product!.id);
      }
    }
    if (!result) {
      product!.favorite = !product!.favorite;
      emit(ProductDetailSuccess(product!));
    }
    return result;
  }

  Future<bool> onAddDeleteCart() async {
    var result = false;
    if (product != null) {
      product!.isAddedCart = !product!.isAddedCart;
      emit(ProductDetailSuccess(product!));
      result = await OrderRepository.addDeleteCart(product!.id);
    }
    if (!result) {
      product!.isAddedCart = !product!.isAddedCart;
      emit(ProductDetailSuccess(product!));
    }
    return result;
  }
}
