
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../../core/provider/address_provider.dart';
import '../../home/home_screenn.dart';
import '../../home/main_navigation_screen.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  static const CameraPosition initialPosition = CameraPosition(
    target: LatLng(31.5204, 74.3587),
    zoom: 14,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressProvider>().getCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddressProvider>();

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: initialPosition,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            compassEnabled: true,

            onMapCreated: (controller) async {
              provider.mapController = controller;
            },

            onCameraMove: (CameraPosition position) {
              provider.latitude = position.target.latitude;
              provider.longitude = position.target.longitude;
            },

            onCameraIdle: () async {
              await provider.getAddressFromLatLng();
            },
          ),

          const Center(
            child: IgnorePointer(
              child: Icon(
                Icons.location_pin,
                color: Colors.red,
                size: 45,
              ),
            ),
      ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 12)
                      ],
                    ),
                    child: TextField(
                      controller: provider.searchController,
                      onChanged: provider.searchAddress,
                      decoration: const InputDecoration(
                        hintText: "Search your location",
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  if (provider.searchResults.isNotEmpty)
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 10)
                        ],
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: provider.searchResults.length,
                        itemBuilder: (context, index) {
                          final place = provider.searchResults[index];
                          return ListTile(
                            leading: const Icon(Icons.location_on, color: Colors.red),
                            title: Text(
                              place["description"],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () async {
                              await provider.selectPlace(place["place_id"]);
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 200,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: () async {
                await provider.getCurrentLocation();
              },
              child: const Icon(
                Icons.my_location,
                color: Colors.black,
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 15,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 15,
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          provider.selectedAddress.isEmpty
                              ? "Select your delivery address"
                              : provider.selectedAddress,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  if (provider.searchResults.isEmpty)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () async {
                          await provider.saveAddress();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MainNavigationScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Continue",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}