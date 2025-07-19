import 'package:flutter/material.dart';

class ProducerDashboardOrderItem extends StatelessWidget {
  final Map<String, dynamic> order;
  const ProducerDashboardOrderItem({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final status = order['status'] ?? 'En cours';
    final total = order['total']?.toString() ?? '0';
    final date = order['orderDate'] ?? 'Date inconnue';
    final id = order['id'] ?? 'N/A';

    Color statusColor;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'livré':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'en cours':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case 'annulé':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(statusIcon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Commande #$id',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$total €',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                status,
                style: TextStyle(
                  fontSize: 12,
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
