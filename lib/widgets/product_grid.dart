import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/products.dart';
import 'package:shop/widgets/product_item.dart';

class ProductGrid extends StatelessWidget {
  final bool showFavorite;

  const ProductGrid(this.showFavorite);
  @override
  Widget build(BuildContext context) {
    final prodData = Provider.of<Products>(context);
    final products = showFavorite ? prodData.favoriteItems : prodData.item;
    return products.isEmpty
        ? Center(
            child: Text("There is no product"),
          )
        : GridView.builder(
            padding: EdgeInsets.all(10.0),
            itemCount: products.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 3 / 2,
            ),
            itemBuilder: (context, index) => ChangeNotifierProvider.value(
              value: products[index],
              child: ProductItem(),
            ),
          );
  }
}
