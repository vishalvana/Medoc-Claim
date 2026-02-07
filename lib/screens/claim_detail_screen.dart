import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/claim.dart';
import '../models/bill.dart';
import '../models/payment.dart';
import '../providers/claim_provider.dart';
import '../widgets/amount_title.dart';
import '../widgets/status_chip.dart';

class ClaimDetailScreen extends StatelessWidget {
  final Claim claim;

  const ClaimDetailScreen({super.key, required this.claim});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClaimProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: const Text('Claim Details'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerCard(),
            const SizedBox(height: 16),
            _summaryCard(),
            const SizedBox(height: 20),
            _section(
              title: 'Bills',
              onAdd: () => _showBillDialog(context, provider),
              children: _buildBillList(context, provider),
            ),
            const SizedBox(height: 20),
            _section(
              title: 'Advances',
              onAdd: () =>
                  _showPaymentDialog(context, provider, isAdvance: true),
              children: _buildAdvanceList(context, provider),
            ),
            const SizedBox(height: 20),
            _section(
              title: 'Settlements',
              onAdd: () =>
                  _showPaymentDialog(context, provider, isAdvance: false),
              children: _buildSettlementList(context, provider),
            ),
            const SizedBox(height: 24),
            _statusActions(context, provider),
          ],
        ),
      ),
    );
  }

  /* ================= HEADER ================= */

  Widget _headerCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: Colors.teal.shade100,
              child: const Icon(Icons.person, color: Colors.teal),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    claim.patientName,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  StatusChip(status: claim.status),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* ================= SUMMARY ================= */

  Widget _summaryCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AmountTile(label: 'Total Bills', value: claim.totalBills),
            AmountTile(label: 'Total Advances', value: claim.totalAdvances),
            AmountTile(
                label: 'Total Settlements', value: claim.totalSettlements),
            const Divider(),
            AmountTile(label: 'Pending Amount', value: claim.pendingAmount),
          ],
        ),
      ),
    );
  }

  /* ================= SECTION ================= */

  Widget _section({
    required String title,
    required VoidCallback onAdd,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (children.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('No records', style: TextStyle(color: Colors.grey)),
              )
            else
              ...children,
          ],
        ),
      ),
    );
  }

  /* ================= STATUS ACTIONS ================= */

  Widget _statusActions(BuildContext context, ClaimProvider provider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _statusButton(provider, ClaimStatus.submitted, 'Submit'),
            _statusButton(provider, ClaimStatus.approved, 'Approve'),
            _statusButton(provider, ClaimStatus.partiallySettled, 'Partial'),
            _statusButton(provider, ClaimStatus.rejected, 'Reject'),
          ],
        ),
      ),
    );
  }

  /* ================= LIST BUILDERS ================= */

  List<Widget> _buildBillList(BuildContext context, ClaimProvider provider) {
    return List.generate(claim.bills.length, (i) {
      final bill = claim.bills[i];
      return _listTile(
        title: bill.title,
        subtitle: '₹${bill.amount.toStringAsFixed(2)}',
        onEdit: () => _showBillDialog(context, provider, editIndex: i),
        onDelete: () => provider.removeBill(claim, i),
      );
    });
  }

  List<Widget> _buildAdvanceList(BuildContext context, ClaimProvider provider) {
    return List.generate(claim.advances.length, (i) {
      final adv = claim.advances[i];
      return _listTile(
        title: 'Advance ${i + 1}',
        subtitle: '₹${adv.amount.toStringAsFixed(2)}',
        onDelete: () => provider.removeAdvance(claim, i),
      );
    });
  }

  List<Widget> _buildSettlementList(
      BuildContext context, ClaimProvider provider) {
    return List.generate(claim.settlements.length, (i) {
      final set = claim.settlements[i];
      return _listTile(
        title: 'Settlement ${i + 1}',
        subtitle: '₹${set.amount.toStringAsFixed(2)}',
        onDelete: () => provider.removeSettlement(claim, i),
      );
    });
  }

  Widget _listTile({
    required String title,
    required String subtitle,
    VoidCallback? onEdit,
    required VoidCallback onDelete,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  /* ================= DIALOGS ================= */

  Future<void> _showBillDialog(
    BuildContext context,
    ClaimProvider provider, {
    int? editIndex,
  }) async {
    final titleCtrl = TextEditingController(
        text: editIndex != null ? claim.bills[editIndex].title : '');
    final amtCtrl = TextEditingController(
        text:
            editIndex != null ? claim.bills[editIndex].amount.toString() : '');

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(editIndex == null ? 'Add Bill' : 'Edit Bill'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Title')),
            TextField(
                controller: amtCtrl,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final title = titleCtrl.text.trim();
              final amt = double.tryParse(amtCtrl.text) ?? 0;
              if (title.isEmpty || amt <= 0) return;

              editIndex != null
                  ? provider.updateBill(
                      claim, editIndex, Bill(title: title, amount: amt))
                  : provider.addBill(claim, Bill(title: title, amount: amt));

              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showPaymentDialog(
    BuildContext context,
    ClaimProvider provider, {
    required bool isAdvance,
  }) async {
    final amtCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isAdvance ? 'Add Advance' : 'Add Settlement'),
        content: TextField(
            controller: amtCtrl,
            decoration: const InputDecoration(labelText: 'Amount'),
            keyboardType: TextInputType.number),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final amt = double.tryParse(amtCtrl.text) ?? 0;
              if (amt <= 0) return;

              isAdvance
                  ? provider.addAdvance(claim, Payment(amt))
                  : provider.addSettlement(claim, Payment(amt));

              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _statusButton(
      ClaimProvider provider, ClaimStatus status, String label) {
    return ElevatedButton(
      onPressed: () => provider.updateStatus(claim, status),
      child: Text(label),
    );
  }
}
