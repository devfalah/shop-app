import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:shop/providers/cart.dart';

class OrderItem {
  final String id;

  final double amount;
  final DateTime dateTime;
  final List<CartItem> products;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.dateTime,
    @required this.products,
  });
}

class Orders extends ChangeNotifier {
  List<OrderItem> _orders = [];
  String authToken;
  String userId;
  List<OrderItem> get orders => [..._orders];
  getData({String token, String uId, List<OrderItem> orders}) {
    authToken = token;
    userId = uId;
    _orders = orders;
  }

  Future<void> fetchAndsetProduct() async {
    final url =
        "https://shop-15825-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken";

    try {
      final res = await http.get(url);
      final extractData = json.decode(res.body) as Map<String, dynamic>;
      if (extractData == null) {
        return;
      }

      final List<OrderItem> loadedOrders = [];
      extractData.forEach((orderId, orderData) {
        loadedOrders.add(OrderItem(
          id: orderData['id'],
          amount: orderData['amount'],
          dateTime: DateTime.parse(orderData['dateTime']),
          products: (orderData['products'] as List<dynamic>).map(
            (product) => CartItem(
              id: product['id'],
              title: product['title'],
              quantity: product['quantity'],
              price: product['price'],
            ),
          ),
        ));
      });
      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addOrder({List<CartItem> cartProduct, double total}) async {
    final url =
        "https://shop-15825-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken";
    try {
      final timeStamp = DateTime.now();
      final res = await http.post(url,
          body: json.encode(
            {
              'amount': total,
              'dateTime': timeStamp.toIso8601String(),
              'products': cartProduct
                  .map(
                    (cartProd) => {
                      'title': cartProd.title,
                      'id': cartProd.id,
                      'quantity': cartProd.quantity,
                      'price': cartProd.price,
                    },
                  )
                  .toList(),
            },
          ));
      _orders.insert(
          0,
          OrderItem(
            id: json.decode(res.body)['name'],
            amount: total,
            dateTime: timeStamp,
            products: cartProduct,
          ));
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
}
