import 'package:flutter/material.dart';

class PopularSpecialties extends StatelessWidget {
  const PopularSpecialties({super.key});

  @override
  Widget build(BuildContext context) {
    final specialties = [
      {'icon': Icons.back_hand, 'label': 'Ortho'},
      {'icon': Icons.favorite, 'label': 'Cardio'},
      {'icon': Icons.face, 'label': 'Derma'},
      {'icon': Icons.psychology, 'label': 'Mental'},
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Popular Specialties',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'See All',
                style: TextStyle(color: Color(0xFF2F1193), fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: specialties.map((s) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0ECF9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    s['icon'] as IconData,
                    color: const Color(0xFF2F1193),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  s['label'] as String,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
