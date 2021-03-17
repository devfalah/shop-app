import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/cart.dart';
import 'package:shop/providers/products.dart';
import 'package:shop/screens/cart_screen.dart';
import 'package:shop/widgets/badge.dart';
import 'package:shop/widgets/loading.dart';
import 'package:shop/widgets/product_grid.dart';
import '../widgets/app_drawer.dart';

enum FilterOption { Favorites, All }

class ProductOverveiwScreen extends StatefulWidget {
  @override
  _ProductOverveiwScreenState createState() => _ProductOverveiwScreenState();
}

class _ProductOverveiwScreenState extends State<ProductOverveiwScreen> {
  bool _showOnlyFavorite = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton(
            onSelected: (FilterOption selectValue) {
              setState(() {
                if (selectValue == FilterOption.Favorites) {
                  _showOnlyFavorite = true;
                } else {
                  _showOnlyFavorite = false;
                }
              });
            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text("only favorites"),
                value: FilterOption.Favorites,
              ),
              PopupMenuItem(
                child: Text("show all"),
                value: FilterOption.All,
              ),
            ],
          ),
          Consumer<Cart>(
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
            builder: (_, cart, ch) =>
                Badge(value: cart.itemCount.toString(), child: ch),
          ),
        ],
      ),
      body: FutureBuilder(
        future:
            Provider.of<Products>(context, listen: false).fetchAndsetProduct(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Loading();
          return ProductGrid(_showOnlyFavorite);
        },
      ),
      drawer: AppDrawer(),
    );
  }
}
