import 'package:flutter/foundation.dart';

import '../models/orders/index.dart';
import '../util/index.dart' show Http;

class OrdersProvider with ChangeNotifier {
  List<OrderByDateDetail> _orderByDateApartment = [];

  get orderByDateApartment {
    return this._orderByDateApartment;
  }

  OrderByDateDetail getOrderDetails(String id) {
    return orderByDateApartment.firstWhere(
      (orderEl) => orderEl.id == id,
      orElse: () => null,
    );
  }

  Future<void> fetchOrderByDateApartment(
      String apartmentId, String date) async {
    final response = await Http.get(
        '/api/seller/orders/$apartmentId/$date?limit=100&page=1');
    List<OrderByDateDetail> items = [];
    for (var order in response['orders']) {
      items.add(OrderByDateDetail.fromJson(order));
    }
    _orderByDateApartment = items;
    notifyListeners();
  }

  Future resetOrder() async {
    this._orderByDateApartment = [];
    notifyListeners();
  }
}
