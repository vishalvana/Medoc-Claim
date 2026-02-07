import 'package:flutter/material.dart';

class AmountTile extends StatelessWidget {
  final String label;
  final double value;

  const AmountTile({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: Text("₹${value.toStringAsFixed(2)}"),
    );
  }
}
