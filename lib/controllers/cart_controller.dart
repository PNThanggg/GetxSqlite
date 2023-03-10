import 'package:get/get.dart';

import '../models/product.dart';
import '../utils/database_helper.dart';

class CartController extends GetxController {
  // list of stored in a cart
  RxList cartItems = [].obs;

  @override
  void onInit() {
    // fetch cartItems from database
    ProductDatabaseHelper.db
        .getCartProductList()
        .then((cartList) => {cartItems.value = cartList});
    super.onInit();
  }

  // get total price of cartItems
  double get totalPrice => cartItems.fold(0, (sum, item) => sum + item.price);
  // get total items in cart count.
  int get count => cartItems.length;

  /// add products to cart
  void addToCart(Product product) {
    product = product.copyWith(id: null);
    ProductDatabaseHelper.db.insertProduct(product, cart: true).then((id) {
      product = product.copyWith(id: id);
      cartItems.add(product);
    });
  }

  /// remove products from cart
  void removeFromCart(Product product) {
    ProductDatabaseHelper.db
        .deleteProduct(product.id!, cart: true)
        .then((value) => {cartItems.remove(product)});
  }

  /// reset cart and clear all items
  void resetCart() async {
    cartItems.forEach((product) async {
      var result =
          await ProductDatabaseHelper.db.deleteProduct(product.id!, cart: true);
      if (result == 1) {
        cartItems.remove(product);
      } else {
        await ProductDatabaseHelper.db.deleteProduct(product.id!, cart: true);
      }
    });
  }
}
