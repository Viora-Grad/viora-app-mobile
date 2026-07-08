import 'package:flutter/material.dart';

class DisclaimerBar extends StatelessWidget {
  const DisclaimerBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 7),
      color: Colors.white,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline_rounded,
              size: 13, color: Colors.black54),
          SizedBox(width: 6),
          Flexible(
            child: Text(
              'Vivi is AI and can make mistakes. Please double-check responses.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
