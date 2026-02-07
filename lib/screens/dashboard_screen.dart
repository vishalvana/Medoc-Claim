import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/claim_provider.dart';
import '../core/constants.dart';
import '../models/claim.dart';
import 'claim_form_screen.dart';
import 'claim_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // --- COLORS ---
  final Color _bgColor = const Color(0xFFF6F8FA);
  final Color _accentColor = const Color(0xFFDFF7F4);
  final Color _primaryDark = const Color(0xFF0F3C4C);
  final Color _iconTeal = const Color(0xFF2B797A);

  // --- SEARCH ---
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  bool _showSystemUpdate = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ClaimProvider>().addDummyClaimsIfEmpty();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClaimProvider>();
    final allClaims = provider.claims;

    // 🔍 FILTERED CLAIMS
    final claims = allClaims.where((c) {
      return c.patientName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    final total = allClaims.length;
    final approved =
        allClaims.where((c) => c.status == ClaimStatus.approved).length;
    final pending =
        allClaims.where((c) => c.status == ClaimStatus.submitted).length;
    final partial = allClaims
        .where((c) => c.status.name.toLowerCase().contains('partial'))
        .length;

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            Image.asset('assets/logo.png',
                height: 120, width: 120, fit: BoxFit.contain),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(AppConstants.appName,
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.black)),
                Text('Medoc Claim',
                    style: TextStyle(fontSize: 12, color: Colors.black)),
              ],
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _primaryDark,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ClaimFormScreen()),
          );
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Claim', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTopSection(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_showSystemUpdate) ...[
                    _buildNotificationCard(),
                    const SizedBox(height: 20),
                  ],
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _statBox('Total', total, Icons.folder_copy, _iconTeal),
                      _statBox('Pending', pending, Icons.hourglass_top,
                          Colors.orange),
                      _statBox('Approved', approved, Icons.check_circle,
                          Colors.green),
                      _statBox(
                          'Partial', partial, Icons.pie_chart, Colors.blueGrey),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildActivitySection(total, approved),
                  const SizedBox(height: 24),
                  const Text(
                    'Recent Claims',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F3C4C)),
                  ),
                  const SizedBox(height: 12),
                  if (claims.isEmpty && _searchQuery.isNotEmpty)
                    const Center(child: Text('No matching claims found'))
                  else if (claims.isEmpty)
                    const _EmptyState()
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: claims.length,
                      itemBuilder: (_, index) {
                        final claim = claims[index];
                        final avatarUrl =
                            "https://ui-avatars.com/api/?name=${claim.patientName}&background=random";

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Dismissible(
                            key: ValueKey('${claim.patientName}_$index'),
                            direction: DismissDirection.endToStart,
                            background: _deleteBg(),
                            confirmDismiss: (_) => _confirmDelete(context),
                            onDismissed: (_) => provider.deleteClaim(claim),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ClaimDetailScreen(claim: claim),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 8)
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                        radius: 24,
                                        backgroundImage:
                                            NetworkImage(avatarUrl)),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(claim.patientName,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 4),
                                          Text(
                                            claim.status.name.toUpperCase(),
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey.shade600),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Total: ₹${claim.totalBills.toStringAsFixed(0)}  |  Pending: ₹${claim.pendingAmount.toStringAsFixed(0)}',
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.arrow_forward_ios,
                                        size: 16, color: Colors.grey),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= UI HELPERS =================

  Widget _buildTopSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
      decoration: BoxDecoration(
        color: _accentColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(25)),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: const InputDecoration(
                        hintText: 'Search claims...', border: InputBorder.none),
                  ),
                ),
                const Icon(Icons.settings_outlined, color: Colors.grey),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Hi,',
                    style: TextStyle(fontSize: 18, color: Colors.black54)),
                Text('Vishal Vana',
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: _iconTeal)),
              ]),
              // const CircleAvatar(
              //     radius: 35,
              //     backgroundImage:
              //         NetworkImage('https://i.pravatar.cc/300?img=11')),
            ],
          )
        ],
      ),
    );
  }

  Widget _statBox(String label, int value, IconData icon, Color color) {
    return Container(
      width: MediaQuery.of(context).size.width / 2 - 26,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
          ]),
      child: Column(children: [
        Icon(icon, size: 28, color: color),
        const SizedBox(height: 10),
        Text('$value',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _primaryDark)),
        Text(label, style: const TextStyle(fontSize: 12)),
      ]),
    );
  }

  Widget _buildNotificationCard() {
    return Dismissible(
      key: const ValueKey('sys'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => setState(() => _showSystemUpdate = false),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Row(children: [
          Icon(Icons.notifications, color: _primaryDark),
          const SizedBox(width: 12),
          const Expanded(
              child: Text('System Update: Sync completed successfully')),
          IconButton(
              onPressed: () => setState(() => _showSystemUpdate = false),
              icon: const Icon(Icons.close))
        ]),
      ),
    );
  }

  Widget _buildActivitySection(int total, int approved) {
    final p = total == 0 ? 0.0 : approved / total;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('ACTIVITY',
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold, color: _iconTeal)),
          const SizedBox(height: 8),
          Text('$approved/$total',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _primaryDark)),
          const Text('Approved Claims',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
        ]),
        const Spacer(),
        SizedBox(
          height: 60,
          width: 60,
          child: CircularProgressIndicator(
              value: p,
              color: _iconTeal,
              backgroundColor: _bgColor,
              strokeWidth: 8),
        )
      ]),
    );
  }

  Widget _deleteBg() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
          color: Colors.red.shade400, borderRadius: BorderRadius.circular(16)),
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete Claim'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel')),
              ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Delete')),
            ],
          ),
        ) ??
        false;
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(40),
      child: Center(child: Text('No claims found.')),
    );
  }
}
