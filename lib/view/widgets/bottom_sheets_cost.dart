part of 'widgets.dart';

class BottomSheetsCost extends StatefulWidget {
  final ShippingCosts data;

  const BottomSheetsCost({
    super.key,
    required this.data,
  });

  /// Static method to show the bottom sheet
  static void show(BuildContext context, ShippingCosts data) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (context) => BottomSheetsCost(data: data),
    );
  }

  @override
  State<BottomSheetsCost> createState() => _BottomSheetsCostState();
}

class _BottomSheetsCostState extends State<BottomSheetsCost> {
  String _formatCurrency(double? value, String currencyCode) {
    if (value == null) return "-";
    
    // Determine locale and symbol
    String locale = 'en_US';
    String symbol = currencyCode;

    if (currencyCode == 'IDR') {
      locale = 'id_ID';
      symbol = 'Rp';
    } else if (currencyCode == 'USD') {
      symbol = '\$';
    }

    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: 2, // International usually has cents
    );
    
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data; // Access the model

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and title
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.blue[50],
                child: Icon(
                  Icons.local_shipping,
                  color: Colors.blue[800],
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.displayName ?? '-',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    Text(
                      // We don't have 'code' in the interface, 
                      // but usually 'displayName' covers the courier name.
                      // If you strictly need code, add it to the interface.
                      data.displayService?.toUpperCase() ?? '-',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 20),
          
          // Details section
          _buildDetailRow('Nama Kurir', data.displayName ?? '-'),
          const SizedBox(height: 16),
          _buildDetailRow('Kode', data.displayCode!.toUpperCase() ?? '-'),
          const SizedBox(height: 16),
          _buildDetailRow('Layanan', data.displayService ?? '-'),
          const SizedBox(height: 16),
          _buildDetailRow('Deskripsi', data.description ?? '-'),
          const SizedBox(height: 16),
          _buildDetailRow('Biaya', _formatCurrency(data.displayCost, data.currencyCode ?? 'IDR')),
          const SizedBox(height: 16),
          _buildDetailRow(
            'Estimasi Pengiriman',
            data.displayEtd != null ? '${data.displayEtd}' : '-',
          ),
          
          const SizedBox(height: 24),
          
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Text(': ', style: TextStyle(fontSize: 14)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}