import 'package:flutter/material.dart';
import '../models/claim.dart';

class AppConstants {
  static const appName = 'Insurance Claims';

  static const statusText = {
    ClaimStatus.draft: 'Draft',
    ClaimStatus.submitted: 'Submitted',
    ClaimStatus.approved: 'Approved',
    ClaimStatus.rejected: 'Rejected',
    ClaimStatus.partiallySettled: 'Partially Settled',
  };

  static Color statusColor(ClaimStatus status) {
    switch (status) {
      case ClaimStatus.approved:
        return Colors.green;
      case ClaimStatus.rejected:
        return Colors.red;
      case ClaimStatus.partiallySettled:
        return Colors.orange;
      case ClaimStatus.submitted:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
