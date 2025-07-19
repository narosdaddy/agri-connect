import 'package:dio/dio.dart';
import '../../core/config/api_config.dart';
import '../models/order_model.dart';

class OrderService {
  final Dio dio;
  OrderService(this.dio);

  List<OrderModel> _orders = [];
  List<OrderModel> get orders => _orders;

  Future<void> loadOrders() async {
    final response = await dio.get(ApiConfig.orders);
    _orders =
        (response.data as List)
            .map((json) => OrderModel.fromJson(json))
            .toList();
  }

  Future<OrderModel> createOrder(OrderModel order) async {
    final response = await dio.post(ApiConfig.orders, data: order.toJson());
    final newOrder = OrderModel.fromJson(response.data);
    _orders.add(newOrder);
    return newOrder;
  }

  Future<OrderModel> getOrderById(String id) async {
    final response = await dio.get(ApiConfig.orderById.replaceFirst('{id}', id));
    return OrderModel.fromJson(response.data);
  }

  List<OrderModel> getOrders() {
    return _orders;
  }
}
