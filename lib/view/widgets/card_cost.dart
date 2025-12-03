part of 'widgets.dart';

class CardCost extends StatefulWidget {
  // Accept the interface instead of specific implementation
  final ShippingCosts cost; 
  
  const CardCost(this.cost, {super.key});

  @override
  State<CardCost> createState() => _CardCostState();
}

class _CardCostState extends State<CardCost> {
  
  // Dynamic Currency Formatter
  String currencyFormatter(double? value, String currencyCode) {
    if (value == null) return "-";
    
    // Determine symbol based on code
    // You can expand this logic or use a library for auto-symbols
    String symbol = currencyCode;
    if (currencyCode == 'IDR') symbol = 'Rp';
    else if (currencyCode == 'USD') symbol = '\$';

    final formatter = NumberFormat.currency(
      locale: currencyCode == 'IDR' ? 'id_ID' : 'en_US',
      symbol: symbol,
      decimalDigits: 2,
    );
    
    return formatter.format(value);
  }

  String formatEtd(String? etd) {
    if (etd == null || etd.isEmpty) return '-';
    // Handle "3 days" vs "3-4 hari" logic if needed
    return etd.replaceAll('day', 'hari').replaceAll('days', 'hari');
  }

  @override
  Widget build(BuildContext context) {
    // Access via the interface
    final cost = widget.cost;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.blue[800]!),
      ),
      margin: const EdgeInsetsDirectional.symmetric(
        vertical: 8,
        horizontal: 16,
      ),
      color: Colors.white,
      child: InkWell(
        onTap: () {
          BottomSheetsCost.show(context, cost);
        },
        child: ListTile(
          title: Text(
            style: TextStyle(
              color: Colors.blue[800],
              fontWeight: FontWeight.w700,
            ),
            "${cost.displayName}: ${cost.displayService}",
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
                // Use dynamic formatter
                "Biaya: ${currencyFormatter(cost.displayCost, cost.currencyCode ?? 'IDR')}",
              ),
              const SizedBox(height: 4),
              Text(
                style: TextStyle(color: Colors.green[800]),
                "Estimasi sampai: ${formatEtd(cost.displayEtd)}",
              ),
            ],
          ),
          leading: CircleAvatar(
            backgroundColor: Colors.blue[50],
            child: Icon(Icons.local_shipping, color: Colors.blue[800]),
          ),
        ),
      ),
    );
  }
}