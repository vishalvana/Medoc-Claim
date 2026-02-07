import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/claim.dart';
import '../models/bill.dart';
import '../providers/claim_provider.dart';

class ClaimFormScreen extends StatefulWidget {
  const ClaimFormScreen({super.key});

  @override
  State<ClaimFormScreen> createState() => _ClaimFormScreenState();
}

class _ClaimFormScreenState extends State<ClaimFormScreen> {
  final _patientCtrl = TextEditingController();
  final _billTitleCtrl = TextEditingController();
  final _billAmountCtrl = TextEditingController();

  @override
  void dispose() {
    _patientCtrl.dispose();
    _billTitleCtrl.dispose();
    _billAmountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Claim'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- PATIENT DETAILS ----------------
            const Text(
              'Patient Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _patientCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Patient Name',
                    hintText: 'Enter patient name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ---------------- OPTIONAL BILL ----------------
            const Text(
              'Initial Bill (Optional)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _billTitleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Bill Title',
                        hintText: 'e.g. Consultation Fee',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _billAmountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Bill Amount',
                        hintText: '₹ Amount',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ---------------- CTA BUTTON ----------------
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _createClaim,
                child: const Text(
                  'Create Claim',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createClaim() {
    final name = _patientCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patient name is required')),
      );
      return;
    }

    final provider = context.read<ClaimProvider>();

    final billTitle = _billTitleCtrl.text.trim();
    final amount = double.tryParse(_billAmountCtrl.text) ?? 0;

    final claim = Claim(patientName: name);

    if (billTitle.isNotEmpty && amount > 0) {
      claim.addBill(
        Bill(title: billTitle, amount: amount),
      );
    }

    provider.addClaim(claim);
    Navigator.pop(context);
  }
}
