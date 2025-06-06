import 'package:cd_automation/pages/PopupComponents/SuccessDialog.dart';
import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final String reminderMessage;
  final String successMessage;

  const ConfirmDialog(
      {super.key,
      required this.onConfirm,
      required this.onCancel,
      required this.reminderMessage,
      required this.successMessage});

  void showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return SuccessDialog(
          message: message,
          isButton: false,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.green.shade50,
      title: Row(
        children: [
          Icon(Icons.info, color: const Color.fromARGB(255, 47, 119, 49)),
          SizedBox(width: 8),
          Text("Confirm",
              style: TextStyle(color: const Color.fromARGB(255, 32, 95, 34))),
        ],
      ),
      content: Text(reminderMessage, style: TextStyle(fontSize: 16)),
      actions: [
        TextButton(
          onPressed: onCancel,
          style: TextButton.styleFrom(
            backgroundColor: Colors.green.shade300,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          child: Text("NO", style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            showSuccessDialog(context, successMessage);
          },
          style: TextButton.styleFrom(
            backgroundColor: Colors.green.shade700,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          child: Text("Yes", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
