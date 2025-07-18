import '../entities/order.dart';

abstract class OrderRepository {
  Future<Order> createOrder(Order order);
  Future<Order?> getOrderById(String orderId);
  Future<List<Order>> getOrdersByAcheteur(
    String acheteurId, {
    int? page,
    int? size,
  });
  Future<List<Order>> getOrdersByProducteur(
    String producteurId, {
    int? page,
    int? size,
  });
  Future<Order> updateOrderStatus(
    String orderId,
    String nouveauStatut,
    String producteurId,
  );
  Future<List<Order>> searchOrders({
    String? statut,
    String? numeroCommande,
    String? acheteurId,
    String? producteurId,
    int? page,
    int? size,
  });
  Future<List<Order>> getRecentOrders({int? page, int? size});
  Future<void> cancelOrder(String orderId, String acheteurId);
}
