import 'package:flutter/material.dart';
import '../models/claim.dart';
import '../core/constants.dart';

class StatusChip extends StatelessWidget {
  final ClaimStatus status;
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = AppConstants.statusColor(status);

    return Chip(
      label: Text(
        AppConstants.statusText[status]!,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    );
  }
}
