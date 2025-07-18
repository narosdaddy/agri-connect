import '../entities/payment.dart';

abstract class PaymentRepository {
  Future<Payment> createPayment(Payment payment);
  Future<Payment?> getPaymentById(String id);
  Future<List<Payment>> getAllPayments();
}
