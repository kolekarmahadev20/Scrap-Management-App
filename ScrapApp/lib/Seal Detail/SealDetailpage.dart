import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'add_seal_page.dart';
import 'edit_seal_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scrapapp/AppClass/AppDrawer.dart';
import 'package:scrapapp/AppClass/appBar.dart';
import '../URL_CONSTANT.dart';

class SealDataScreen extends StatefulWidget {
  final int currentPage;
  SealDataScreen({required this.currentPage});

  @override
  _SealDataScreenState createState() => _SealDataScreenState();
}

class _SealDataScreenState extends State<SealDataScreen> {
  List<dynamic> allSealData = [];
  List<dynamic> sealData = [];
  DateTime? _selectedDate; // add this in your State class
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _materialController = TextEditingController();
  final TextEditingController _plantController = TextEditingController();
  final TextEditingController _vehicleController = TextEditingController();
  String clean(String text) {
    return text
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^\w\s]'), ' ') // remove everything except letters/numbers
        .replaceAll(RegExp(r'[()–—−]'), '')   // remove brackets & long dashes
        .replaceAll(RegExp(r'\s*-\s*'), '-') // normalize hyphens
        .replaceAll(RegExp(r'\s+'), ' ');    // collapse multiple spaces
  }



  @override
  void initState() {
    super.initState();
    fetchSealData();
  }

  Future<void> fetchSealData({DateTime? selectedDate}) async {
    setState(() => isLoading = true);

    try {

      final prefs = await SharedPreferences.getInstance();
      final uuid = prefs.getString("uuid") ?? "";
      final userId = prefs.getString("username") ?? "";
      final password = prefs.getString("password") ?? "";
      final userType = prefs.getString("userType") ?? "";

      final url = Uri.parse("${URL}get_seal_data");

      final body = {
        "uuid": uuid,
        "user_id": userId,
        "user_pass": password,
        "user_type": userType,
      };

      if (selectedDate != null) {
        final formattedDate =
            "${selectedDate.day.toString().padLeft(2, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.year}";
        body["seal_date"] = formattedDate;
        print("📅 Fetching seals for seal_date: $formattedDate");
      }

      final response = await http.post(url, body: body);
      print("🔹 Response status: ${response.statusCode}");
      print("🔹 Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["status"] == "1") {
          List<dynamic> fetchedSeals = data["seal_data"] ?? [];

          // 🔹 Apply client-side date filter without removing time
          if (selectedDate != null) {
            final filterDate =
                "${selectedDate.day.toString().padLeft(2, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.year}";
            fetchedSeals = fetchedSeals.where((seal) {
              final sealDate = seal["seal_date"]?.toString().split(" ").first ?? "";
              return sealDate == filterDate;
            }).toList();
          }

          setState(() {
            allSealData = fetchedSeals;
            sealData = allSealData;
          });
        } else {
          setState(() {
            allSealData = [];
            sealData = [];
          });
        }
      } else {
        print("❌ Server error: ${response.statusCode}");
        setState(() {
          allSealData = [];
          sealData = [];
        });
      }
    } catch (e) {
      print("❌ Error fetching seal data: $e");
      setState(() {
        allSealData = [];
        sealData = [];
      });
    } finally {
      setState(() => isLoading = false);
    }
  }


  Future<void> deleteSealRecord(String sealTransactionId) async {
    final prefs = await SharedPreferences.getInstance();
    final uuid = prefs.getString("uuid") ?? "";
    final userId = prefs.getString("username") ?? "";
    final password = prefs.getString("password") ?? "";
    final userType = prefs.getString("userType") ?? "";

    final url = Uri.parse("${URL}delete_seal_record");

    try {
      final response = await http.post(url, body: {
        "uuid": uuid,
        "user_id": userId,
        "user_pass": password,
        "user_type": userType,
        "id": sealTransactionId, // 👈 dynamic id
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String msg = data["msg"] ?? "Something went wrong";
        if (data["status"] == "1") {
          // ✅ Delete from local list
          setState(() {
            allSealData.removeWhere(
                    (item) => item["seal_transaction_id"] == sealTransactionId);
            sealData = allSealData;
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Server error")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }
  Future<void> applyFilter() async {
    final loc = clean(_locationController.text);
    final mat = clean(_materialController.text);
    final plantQuery = clean(_plantController.text);
    final vehicle = clean(_vehicleController.text);

    // If a date is selected, fetch data again
    if (_selectedDate != null) {
      await fetchSealData(selectedDate: _selectedDate);
    }

    setState(() {
      sealData = allSealData.where((seal) {
        final location = clean(seal["location_name"] ?? "");
        final material = clean(seal["material_name"] ?? "");
        final plant = clean(seal["plant_name"] ?? "");
        final vehicleNo = clean(seal["vehicle_no"] ?? "");

        final matchesLocation =
            loc.isEmpty || location.contains(loc);
        final matchesMaterial =
            mat.isEmpty || material.contains(mat);
        final matchesPlant =
            plantQuery.isEmpty || plant.contains(plantQuery);
        final matchesVehicle =
            vehicle.isEmpty || vehicleNo.contains(vehicle);

        return matchesLocation &&
            matchesMaterial &&
            matchesPlant &&
            matchesVehicle;
      }).toList();
    });

    Navigator.pop(context);
  }









  void openFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Filter Seals",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 16),

                // Location
                TextField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: "Search by Location",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.location_on),
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                ),
                const SizedBox(height: 12),

                // Material
                TextField(
                  controller: _materialController,
                  decoration: InputDecoration(
                    labelText: "Search by Material",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.category),
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                ),
                const SizedBox(height: 12),

                // Plant
                TextField(
                  controller: _plantController,
                  decoration: InputDecoration(
                    labelText: "Search by Plant",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.apartment),
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                ),
                const SizedBox(height: 12),

                // Vehicle
                TextField(
                  controller: _vehicleController,
                  decoration: InputDecoration(
                    labelText: "Search by Vehicle",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.directions_car),
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                ),
                const SizedBox(height: 12),

                // Date Picker
                // Date Picker
                InkWell(
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _selectedDate = pickedDate;
                      });

                      // ✅ Fetch filtered data
                      await fetchSealData(selectedDate: _selectedDate);

                      // ✅ Close the filter dialog immediately
                      if (mounted) Navigator.pop(context);
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.date_range),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                    child: Text(
                      _selectedDate != null
                          ? "${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}"
                          : "Choose Date",
                      style: TextStyle(
                        color: _selectedDate != null ? Colors.black87 : Colors.grey[600],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          _locationController.clear();
                          _materialController.clear();
                          _plantController.clear();
                          _vehicleController.clear();
                          _selectedDate = null;

                          // 🔹 Fetch all seal data from server
                          await fetchSealData();

                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.blueGrey),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          "Clear",
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: applyFilter,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          "Apply",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }


  void searchData(String query) {
    final cleanedQuery = clean(query);

    if (cleanedQuery.isEmpty) {
      setState(() => sealData = allSealData);
      return;
    }

    final filtered = allSealData.where((seal) {
      final plant = clean(seal['plant_name'] ?? '');
      final location = clean(seal['location_name'] ?? '');
      final material = clean(seal['material_name'] ?? '');
      final vehicle = clean(seal['vehicle_no'] ?? '');

      return plant.contains(cleanedQuery) ||
          location.contains(cleanedQuery) ||
          material.contains(cleanedQuery) ||
          vehicle.contains(cleanedQuery);
    }).toList();

    setState(() => sealData = filtered);
  }




  Widget buildField(String label, String? value) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 2),
            Text(
              value ?? "-",
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRow(int index, List<Widget> children) {
    return Container(
      color: index.isEven ? Colors.white : Colors.grey[200],
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(children: children),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(currentPage: widget.currentPage),
      appBar: CustomAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "View Seals",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: openFilterDialog,
                  icon: const Icon(Icons.filter_alt, color: Colors.white),
                  label: const Text("Filter", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),



          // 🔍 Search Box
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   // child: TextField(
          //   //   controller: _searchController,
          //   //   textInputAction: TextInputAction.search,
          //   //   decoration: InputDecoration(
          //   //     hintText: "Search Data",
          //   //     border: OutlineInputBorder(
          //   //       borderRadius: BorderRadius.circular(10),
          //   //     ),
          //   //     prefixIcon: const Icon(Icons.search),
          //   //   ),
          //   //   onChanged: searchData,
          //   //   onSubmitted: searchData,
          //   // ),
          // ),

          // 🔹 Seal Data List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : sealData.isEmpty
                ? const Center(child: Text("No Seal Data Found"))
                : ListView.builder(
              itemCount: sealData.length,
              itemBuilder: (context, index) {
                final seal = sealData[index] as Map<String, dynamic>;
                return Card(
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        // 🔹 Header Row
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey[500],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              // Seal Number
                              Expanded(
                                child: Text(
                                  seal["sr_no"] ?? "",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow
                                      .ellipsis, // prevents overflow
                                ),
                              ),

                              // Icons row
                              Flexible(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      (seal["pics"] != null &&
                                          (seal["pics"] as List)
                                              .isNotEmpty)
                                          ? IconButton(
                                        icon: const Icon(
                                            Icons.image,
                                            color:
                                            Colors.white),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  ImageViewPage(
                                                    pics: (seal[
                                                    "pics"] ??
                                                        []) as List,
                                                    currentPage: widget
                                                        .currentPage,
                                                  ),
                                            ),
                                          );
                                        },
                                      )
                                          : IconButton(
                                        icon: const Icon(
                                            Icons
                                                .image_not_supported,
                                            color: Colors.grey),
                                        onPressed: () {
                                          ScaffoldMessenger.of(
                                              context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    "No images available")),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.white),
                                        onPressed: () {
                                          final sealId = seal[
                                          "seal_transaction_id"]
                                              .toString();
                                          final imgUrls =
                                          List<String>.from(
                                              seal["img_url"] ??
                                                  []);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  EditSealPage(
                                                    currentPage: widget
                                                        .currentPage,
                                                    sealTransactionId:
                                                    sealId,
                                                    serverImages: imgUrls,
                                                  ),
                                            ),
                                          ).then((value) {
                                            setState(() {
                                              fetchSealData();
                                            });
                                          });
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.white),
                                        onPressed: () async {
                                          final sealId = seal[
                                          "seal_transaction_id"]
                                              .toString();
                                          final confirm =
                                          await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) =>
                                                AlertDialog(
                                                  title: const Text(
                                                      "Confirm Delete"),
                                                  content: const Text(
                                                      "Are you sure you want to delete this record?"),
                                                  actions: [
                                                    TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                ctx,
                                                                false),
                                                        child: const Text(
                                                            "Cancel")),
                                                    TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                ctx,
                                                                true),
                                                        child: const Text(
                                                            "Delete")),
                                                  ],
                                                ),
                                          );
                                          if (confirm == true) {
                                            await deleteSealRecord(
                                                sealId);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 6),

                        // 🔹 Alternating Rows
                        buildRow(0, [
                          buildField("Location",
                              seal["location_name"]?.toString()),
                          buildField(
                              "Plant", seal["plant_name"]?.toString())
                        ]),
                        buildRow(1, [
                          buildField("Material",
                              seal["material_name"]?.toString()),
                          buildField("Vessel",
                              seal["vessel_name"]?.toString())
                        ]),
                        buildRow(2, [
                          buildField("Start Seal No",
                              seal["start_seal_no"]?.toString()),
                          buildField("End Seal No",
                              seal["end_seal_no"]?.toString())
                        ]),
                        buildRow(3, [
                          buildField(
                              "Extra Start Seal No",
                              seal["extra_start_seal_no"]
                                  ?.toString()),
                          buildField("Extra End Seal No",
                              seal["extra_end_seal_no"]?.toString())
                        ]),
                        buildRow(4, [
                          buildField("No of Seals",
                              seal["no_of_seal"]?.toString()),
                          buildField("Extra No of Seals",
                              seal["extra_no_of_seal"]?.toString())
                        ]),
                        buildRow(5, [
                          buildField("Rejected Seal",
                              seal["rejected_seal_no"]?.toString()),
                          buildField("New Seal",
                              seal["new_seal_no"]?.toString())
                        ]),
                        buildRow(6, [
                          buildField("Net Weight",
                              seal["net_weight"]?.toString()),
                          buildField("Seal Color",
                              seal["seal_color"]?.toString())
                        ]),
                        buildRow(7, [
                          buildField("Vehicle No",
                              seal["vehicle_no"]?.toString()),
                          buildField("Allow Slip No",
                              seal["allow_slip_no"]?.toString())
                        ]),
                        buildRow(8, [
                          buildField(
                            "Seal Date",
                            seal["seal_date"] != null
                                ? seal["seal_date"].toString() // full date + time
                                : "-",
                          ),
                        ]),


                        buildRow(9, [
                          buildField(
                              "Vehicle Reached Date",
                              seal["seal_unloading_date"]
                                  ?.toString()),
                        ]),
                        buildRow(10, [
                          buildField("GPS Seal No",
                              seal["gps_seal_no"]?.toString()),
                        ]),
                        buildRow(11, [
                          buildField("Sender Remarks",
                              seal["remarks"]?.toString()),
                        ]),
                        buildRow(12, [
                          buildField("Receiver Remarks",
                              seal["rev_remarks"]?.toString()),
                        ]),

                        const SizedBox(height: 12),

                        // 🔹 View Images Button
                        // 🔹 View Images Button
                        // SizedBox(
                        //   width: double.infinity,
                        //   child: ElevatedButton(
                        //     onPressed: () {
                        //       Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //           builder: (_) => ImageViewPage(
                        //             pics: (seal["pics"] ?? []) as List,
                        //             currentPage: widget.currentPage, // ✅ pass currentPage here
                        //           ),
                        //         ),
                        //       );
                        //     },
                        //     child: const Text("View Images"),
                        //   ),
                        // )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // 🔹 Floating Action Button (+ button)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddSealPage(currentPage: widget.currentPage),
            ),
          ).then((value) {
            setState(() {
              fetchSealData();
            });
          });
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blueGrey,
      ),
    );
  }
}

class ImageViewPage extends StatelessWidget {
  final List pics;

  const ImageViewPage({required this.pics, required int currentPage});

  // ✅ URL se timestamp extract karne ka function
  String extractTimestamp(String url) {
    // URL last segment le lo
    final filename = url.split('/').last;
    // filename me last "_" ke baad extension se pehle wala part le lo
    final parts = filename.split('_');
    if (parts.length >= 3) {
      return "${parts[1]}_${parts[2].split('.').first}";
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: pics.isEmpty
          ? const Center(child: Text("No Image Found"))
          : ListView.builder(
          itemCount: pics.length,
          itemBuilder: (context, index) {
            final timestamp = extractTimestamp(pics[index]);
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  Image.network(pics[index]),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      color: Colors.black54,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      child: Text(
                        timestamp,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}

