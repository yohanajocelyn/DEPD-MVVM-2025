part of 'pages.dart';

class InternationalHomePage extends StatefulWidget {
  const InternationalHomePage({super.key});

  @override
  State<InternationalHomePage> createState() => _InternationalHomePageState();
}

class _InternationalHomePageState extends State<InternationalHomePage> {
  late InternationalHomeViewModel homeViewModel;

  Country? selectedCountry;

  // Controller
  final weightController = TextEditingController();

  // Courier Options (Note: POS is usually the primary one for International via RajaOngkir Basic)
  final List<String> courierOptions = ["pos", "tiki", "jne"];
  String selectedCourier = "pos";

  // ORIGIN VARIABLES (Still uses Indonesian City IDs)
  int? selectedProvinceOriginId;
  int? selectedCityOriginId;

  // DESTINATION VARIABLES (Uses Country ID - String)
  String? selectedDestinationCountryId;

  @override
  void initState() {
    super.initState();
    homeViewModel = Provider.of<InternationalHomeViewModel>(context, listen: false);
    
    // 1. Load Origin Data (Provinces)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (homeViewModel.provinceList.status == Status.notStarted) {
        homeViewModel.getProvinceList();
      }
    });
  }

  @override
  void dispose() {
    weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cek Ongkir Internasional")),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // === INPUT FORM CARD ===
                Card(
                  color: Colors.white,
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Courier & Weight ---
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: selectedCourier,
                                items: courierOptions
                                    .map((c) => DropdownMenuItem(
                                          value: c,
                                          child: Text(c.toUpperCase()),
                                        ))
                                    .toList(),
                                onChanged: (v) => setState(() => selectedCourier = v ?? "pos"),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: weightController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Berat (gr)'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // --- SECTION: ORIGIN (Indonesia) ---
                        const Text("Origin (Indonesia)", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            // 1. Origin Province Dropdown
                            Expanded(
                              child: Consumer<InternationalHomeViewModel>(
                                builder: (context, vm, _) {
                                  if (vm.provinceList.status == Status.loading) {
                                    return const Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)));
                                  }
                                  final provinces = vm.provinceList.data ?? [];
                                  return DropdownButton<int>(
                                    isExpanded: true,
                                    value: selectedProvinceOriginId,
                                    hint: const Text('Provinsi'),
                                    items: provinces.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name ?? ''))).toList(),
                                    onChanged: (newId) {
                                      setState(() {
                                        selectedProvinceOriginId = newId;
                                        selectedCityOriginId = null;
                                      });
                                      if (newId != null) vm.getCityOriginList(newId);
                                    },
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            // 2. Origin City Dropdown
                            Expanded(
                              child: Consumer<InternationalHomeViewModel>(
                                builder: (context, vm, _) {
                                  if (vm.cityOriginList.status == Status.loading) {
                                    return const Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)));
                                  }
                                  final cities = vm.cityOriginList.data ?? [];
                                  
                                  // Validation to ensure selected ID exists in list
                                  final validValue = cities.any((c) => c.id == selectedCityOriginId) ? selectedCityOriginId : null;

                                  return DropdownButton<int>(
                                    isExpanded: true,
                                    value: validValue,
                                    hint: const Text('Kota Asal'),
                                    items: cities.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name ?? ''))).toList(),
                                    onChanged: (newId) => setState(() => selectedCityOriginId = newId),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),

                        // --- SECTION: DESTINATION (International) ---
                        const Text("Destination (International)", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        
                        Autocomplete<Country>(
                          // 1. This function is called when user types
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text == '') {
                              return const Iterable<Country>.empty();
                            }
                            // Call ViewModel to search API
                            return homeViewModel.searchCountries(textEditingValue.text);
                          },
                          
                          // 2. How to display the option in the list
                          displayStringForOption: (Country option) => option.countryName ?? '-',
                          
                          // 3. What happens when user selects an item
                          onSelected: (Country selection) {
                            setState(() {
                              selectedCountry = selection;
                              selectedDestinationCountryId = selection.countryId;
                            });
                          },

                          // 4. Customizing the Input Field (Optional)
                          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                            return TextField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: const InputDecoration(
                                hintText: "Ketik Negara (min 3 huruf)...",
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.search),
                              ),
                            );
                          },
                        ),
                        
                        // Helper text to show what is selected
                        if (selectedCountry != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              "Selected: ${selectedCountry!.countryName}", 
                              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                            ),
                          ),

                        const SizedBox(height: 24),

                        // --- CALCULATE BUTTON ---
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.all(16)),
                            onPressed: () {
                              if (selectedCityOriginId != null &&
                                  selectedDestinationCountryId != null &&
                                  weightController.text.isNotEmpty) {
                                
                                int weight = int.tryParse(weightController.text) ?? 0;
                                
                                homeViewModel.checkShipmentCost(
                                  selectedCityOriginId.toString(), // Origin City ID
                                  selectedDestinationCountryId.toString(),   // Destination Country ID
                                  weight,
                                  selectedCourier,
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Mohon lengkapi data')),
                                );
                              }
                            },
                            child: const Text("Hitung Ongkir International", style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // === RESULTS LIST ===
                Consumer<InternationalHomeViewModel>(
                  builder: (context, vm, _) {
                    if (vm.costList.status == Status.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (vm.costList.status == Status.error) {
                      return Center(child: Text(vm.costList.message ?? "Error"));
                    }
                    if (vm.costList.status == Status.completed) {
                      final costs = vm.costList.data ?? [];
                      if (costs.isEmpty) return const Text("Tidak ada layanan tersedia.");

                      return ListView.builder(
                            shrinkWrap:
                                true, // Membuat ListView hanya sebesar kontennya
                            physics:
                                const NeverScrollableScrollPhysics(), // Nonaktifkan scroll pada ListView agar mengikuti scroll parent
                            itemCount:
                                vm.costList.data?.length ??
                                0, // Jumlah item berdasarkan data ongkir
                            itemBuilder: (context, index) => CardCost(
                              vm.costList.data!.elementAt(index),
                            ), // Gunakan CardCost untuk setiap item
                          );
                    }
                    return const SizedBox.shrink();
                  },
                )
              ],
            ),
          ),

          // === LOADING OVERLAY ===
          Consumer<InternationalHomeViewModel>(
            builder: (context, vm, _) {
              if (vm.isLoading) {
                return Container(
                  color: Colors.black45,
                  child: const Center(child: CircularProgressIndicator()),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}