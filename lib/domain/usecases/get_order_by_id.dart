import '../repositories/order_repository.dart';
import '../entities/order.dart';

class GetOrderById {
  final OrderRepository repository;
  const GetOrderById(this.repository);

  Future<Order?> call(String orderId) {
    return repository.getOrderById(orderId);
  }
}
