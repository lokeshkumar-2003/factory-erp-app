import 'package:cd_automation/model/NotificationItem.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationCard extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback? onClose;

  const NotificationCard({
    super.key,
    required this.item,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isAlert = item.status == "Warning";
    final color = isAlert ? Colors.red : Colors.green;

    String formattedDate = item.date;
    try {
      final parsedDate = DateTime.parse(item.date);
      formattedDate = DateFormat('dd-MM-yyyy HH:mm').format(parsedDate);
    } catch (_) {}

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: isAlert ? Colors.red[50] : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isAlert ? Icons.warning : Icons.verified,
                color: color,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 16,
                        color: color,
                        fontWeight: isAlert ? FontWeight.bold : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    if (item.message.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        item.message,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              GestureDetector(
                onTap: onClose ??
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Close tapped')),
                      );
                    },
                child: const Icon(Icons.close, color: Color(0xFF00536E)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
