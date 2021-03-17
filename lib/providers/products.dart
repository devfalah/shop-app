import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../providers/product.dart';

class Products extends ChangeNotifier {
  List<Product> _items = [];
  String authToken;
  String userId;
  getData(String token, String uId, List<Product> products) {
    authToken = token;
    userId = uId;
    _items = products;
    notifyListeners();
  }

  List<Product> get item => [..._items];
  List<Product> get favoriteItems {
    return _items.where((product) => product.isFavorite).toList();
  }

  Product findById(id) {
    return _items.firstWhere((product) => product.id == id);
  }

  Future<void> fetchAndsetProduct({filterByUser = false}) async {
    final filtered =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url =
        "https://shop-15825-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filtered";

    try {
      final res = await http.get(url);
      final extractData = json.decode(res.body) as Map<String, dynamic>;
      if (extractData == null) {
        return;
      }
      url =
          "https://shop-15825-default-rtdb.firebaseio.com/userFavorite/$userId.json?auth=$authToken";
      final favRes = await http.get(url);
      final extractFavoriteData = json.decode(favRes.body);
      final List<Product> loadedProducts = [];
      extractData.forEach((prodId, prodData) {
        loadedProducts.add(
          Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            imageUrl: prodData['imageUrl'],
            price: prodData['price'],
            isFavorite: extractFavoriteData == null
                ? false
                : extractFavoriteData[prodId] ?? false,
          ),
        );
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProdcut(Product product) async {
    final url =
        'https://shop-15825-default-rtdb.firebaseio.com/products.json?auth=$authToken';
    try {
      final res = await http.post(url,
          body: json.encode(
            {
              'title': product.title,
              'description': product.description,
              'imageUrl': product.imageUrl,
              'creatorId': product.id,
              'price': product.price,
            },
          ));
      _items.add(Product(
        id: json.decode(res.body)['name'],
        title: product.title,
        description: product.description,
        imageUrl: product.imageUrl,
        price: product.price,
      ));
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProdcut({String id, Product product}) async {
    final prodIndex = _items.indexWhere((prod) => id == prod.id);
    if (prodIndex >= 0) {
      final url =
          'https://shop-15825-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
      await http.patch(url,
          body: json.encode(
            {
              'title': product.title,
              'description': product.description,
              'imageUrl': product.imageUrl,
              'creatorId': product.id,
              'price': product.price,
            },
          ));
      _items[prodIndex] = product;
    }
  }

  Future<void> deleteProdcut(String id) async {
    final url =
        'https://shop-15825-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
    final prodIndex = _items.indexWhere((prod) => id == prod.id);
    final existingProduct = _items[prodIndex];
    _items.removeAt(prodIndex);
    notifyListeners();
    final res = await http.delete(url);
    if (res.statusCode >= 400) {
      _items.insert(prodIndex, existingProduct);
      notifyListeners();
      throw 'Could not delete item';
    }
  }
}
