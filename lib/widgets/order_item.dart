import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/orders.dart' as order;

class OrderItem extends StatelessWidget {
  final order.OrderItem orderItem;

  const OrderItem({this.orderItem});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ExpansionTile(
        title: Text('\$${orderItem.amount}'),
        subtitle:
            Text(DateFormat("dd/MM/yyyy hh:mm").format(orderItem.dateTime)),
        children: orderItem.products
            .map(
              (product) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    '${product.quantity} X\$${product.price}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
