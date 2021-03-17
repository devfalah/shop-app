import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/widgets/app_drawer.dart';
import 'package:shop/widgets/loading.dart';
import 'package:shop/widgets/order_item.dart';
import '../providers/orders.dart' show Orders;

class OrderScreen extends StatelessWidget {
  static const routeName = "/order";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Your Order")),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future:
            Provider.of<Orders>(context, listen: false).fetchAndsetProduct(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Loading();
          } else {
            if (snapshot.error == null) {
              return Center(child: Text("An error occurred!"));
            } else {
              return Consumer<Orders>(
                builder: (ctx, orderData, ch) => ListView.builder(
                  itemCount: orderData.orders.length,
                  itemBuilder: (context, index) => OrderItem(
                    orderItem: orderData.orders[index],
                  ),
                ),
              );
            }
          }
        },
      ),
    );
  }
}
