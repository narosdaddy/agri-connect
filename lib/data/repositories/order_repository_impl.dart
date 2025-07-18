import '../../domain/repositories/order_repository.dart';
import '../../domain/entities/order.dart';
import '../models/order_model.dart';
import '../sources/order_service.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderService service;
  OrderRepositoryImpl(this.service);

  @override
  Future<Order> createOrder(Order order) async {
    final model = await service.createOrder(
      OrderModel(
        id: order.id,
        statut: order.statut,
        acheteurId: order.acheteurId,
        producteurId: order.producteurId,
        elements: order.elements,
        total: order.total,
        dateCreation: order.dateCreation,
      ),
    );
    return model;
  }

  @override
  Future<Order?> getOrderById(String orderId) async {
    return await service.getOrderById(orderId);
  }

  @override
  Future<List<Order>> getOrdersByAcheteur(
    String acheteurId, {
    int? page,
    int? size,
  }) async {
    // À adapter selon l'API
    return await service.getOrders();
  }

  @override
  Future<List<Order>> getOrdersByProducteur(
    String producteurId, {
    int? page,
    int? size,
  }) async {
    // À adapter selon l'API
    return await service.getOrders();
  }

  @override
  Future<Order> updateOrderStatus(
    String orderId,
    String nouveauStatut,
    String producteurId,
  ) async {
    // À implémenter selon l'API
    throw UnimplementedError();
  }

  @override
  Future<List<Order>> searchOrders({
    String? statut,
    String? numeroCommande,
    String? acheteurId,
    String? producteurId,
    int? page,
    int? size,
  }) async {
    // À adapter selon l'API
    return await service.getOrders();
  }

  @override
  Future<List<Order>> getRecentOrders({int? page, int? size}) async {
    // À adapter selon l'API
    return await service.getOrders();
  }

  @override
  Future<void> cancelOrder(String orderId, String acheteurId) async {
    // À implémenter selon l'API
    throw UnimplementedError();
  }
}
