import '../repositories/order_repository.dart';
import '../entities/order.dart';

class CreateOrder {
  final OrderRepository repository;
  const CreateOrder(this.repository);

  Future<Order> call(Order order) {
    return repository.createOrder(order);
  }
}
