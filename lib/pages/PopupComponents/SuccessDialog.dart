import 'package:flutter/material.dart';

class SuccessDialog extends StatelessWidget {
  final String message;
  final bool isButton;
  final String routeName;

  const SuccessDialog({
    super.key,
    required this.message,
    required this.isButton,
    this.routeName = "",
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      backgroundColor: Colors.green.shade100,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 60),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          isButton
              ? ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);

                    if (routeName.isNotEmpty) {
                      Navigator.pushNamed(context, routeName);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text("Upload Successfully"),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
