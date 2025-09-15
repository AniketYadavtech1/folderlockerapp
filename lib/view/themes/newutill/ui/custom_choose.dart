import 'package:flutter/material.dart';

class CustomChoiceChip extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final String label;
  final Color? textColor;

  const CustomChoiceChip({
    super.key,
    required this.selected,
    required this.onTap,
    required this.label,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(color: textColor ?? Colors.black),
        ),
      ),
    );
  }
}
