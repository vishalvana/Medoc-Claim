import 'package:flutter/material.dart';
import '../models/claim.dart';
import '../screens/claim_detail_screen.dart';
import 'amount_title.dart';
import 'status_chip.dart';

class ClaimCard extends StatelessWidget {
  final Claim claim;
  const ClaimCard({super.key, required this.claim});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ClaimDetailScreen(claim: claim)),
        );
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    claim.patientName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  StatusChip(status: claim.status),
                ],
              ),
              const SizedBox(height: 6),
              const Divider(),
              AmountTile(label: "Bills", value: claim.totalBills),
              AmountTile(label: "Pending", value: claim.pendingAmount),
            ],
          ),
        ),
      ),
    );
  }
}
