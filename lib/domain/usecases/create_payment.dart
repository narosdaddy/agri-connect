import '../repositories/payment_repository.dart';
import '../entities/payment.dart';

class CreatePayment {
  final PaymentRepository repository;
  const CreatePayment(this.repository);

  Future<Payment> call(Payment payment) {
    return repository.createPayment(payment);
  }
}
