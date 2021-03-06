import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    @required this.id,
    @required this.title,
    @required this.quantity,
    @required this.price,
  });
}

class Cart extends ChangeNotifier {
  Map<String, CartItem> _items = {};
  Map<String, CartItem> get items => {..._items};
  int get itemCount => _items.length;
  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void addItem({String prodId, String title, double price}) {
    if (_items.containsKey(prodId)) {
      _items.update(
        prodId,
        (cartItem) => CartItem(
          id: cartItem.id,
          title: cartItem.title,
          quantity: cartItem.quantity + 1,
          price: cartItem.price,
        ),
      );
    } else {
      _items.putIfAbsent(
        prodId,
        () => CartItem(
          id: DateTime.now().toIso8601String(),
          title: title,
          quantity: 1,
          price: price,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem({String productId}) {
    _items.remove(productId);
    notifyListeners();
  }

  void removeSingleItem({String productId}) {
    if (!_items.containsKey(productId)) return;
    if (_items[productId].quantity > 1) {
      _items.update(
          productId,
          (cartItem) => CartItem(
                id: cartItem.id,
                title: cartItem.title,
                quantity: cartItem.quantity - 1,
                price: cartItem.price,
              ));
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}
