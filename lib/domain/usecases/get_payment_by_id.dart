import '../repositories/payment_repository.dart';
import '../entities/payment.dart';

class GetPaymentById {
  final PaymentRepository repository;
  const GetPaymentById(this.repository);

  Future<Payment?> call(String id) {
    return repository.getPaymentById(id);
  }
}
