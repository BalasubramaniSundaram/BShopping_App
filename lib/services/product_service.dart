import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shopping_app/services/user_service.dart';

class ProductService {
  final UsersService usersService;

  ProductService(this.usersService);

  Future<List<Map<String, dynamic>>> getProducts() async {
    String responseBody = await rootBundle.loadString("assets/products.json");
    var list = await json.decode(responseBody).cast<Map<String, dynamic>>();
    return Future.value(list);
  }

  Future<Map<String, dynamic>> getProductsByProductModel(
      String productModelNumber) async {
    String responseBody = await rootBundle.loadString("assets/products.json");
    List<Map<String, dynamic>> list =
        await json.decode(responseBody).cast<Map<String, dynamic>>();
    var data = list.firstWhere(
        (element) => element['productModelNumber'] == productModelNumber);
    return Future.value(data);
  }
}
