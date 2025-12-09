import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';       // for json.decode
import 'package:http/http.dart' as http; // for http.post
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scrapapp/AppClass/AppDrawer.dart';
import 'package:scrapapp/AppClass/appBar.dart';

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as Img;
import 'package:path/path.dart' as p;


import '../URL_CONSTANT.dart';


class AddSealPage extends StatefulWidget {
  final int currentPage;

  const AddSealPage({
    Key? key,
    required this.currentPage,
  }) : super(key: key);

  @override
  State<AddSealPage> createState() => _AddSealPageState();
}


class _AddSealPageState extends State<AddSealPage> {
  final TextEditingController allowSlipController = TextEditingController();
  final TextEditingController vehiclenoController = TextEditingController();
  final TextEditingController SealDateController = TextEditingController();
  final TextEditingController SealTimeController = TextEditingController();
  final TextEditingController FirstweightController = TextEditingController();
  final TextEditingController SecondweightController = TextEditingController();
  final TextEditingController NetweightController = TextEditingController();
  final TextEditingController StartSealnoController = TextEditingController();
  final TextEditingController EndSealnoController = TextEditingController();
  final TextEditingController NoofSealsController = TextEditingController();
  final TextEditingController SealColorController = TextEditingController();
  final TextEditingController ExtraStartSealNoController = TextEditingController();
  final TextEditingController ExtraEndSealNoController = TextEditingController();
  final TextEditingController ExtraNoofSealController = TextEditingController();
  final TextEditingController OtherExtraSealNoController = TextEditingController();
  final TextEditingController GPSSealNoController = TextEditingController();
  final TextEditingController TarpaulinConditionController = TextEditingController();

  final TextEditingController SenderRemarksController = TextEditingController();
  final TextEditingController RecievedbyController = TextEditingController();
  final TextEditingController VehicleReachedDateController  =  TextEditingController();
  final TextEditingController VehicleReachedTimeController  =  TextEditingController();
  final TextEditingController ReceiverRemarksController  =  TextEditingController();


  List<String> locationList = [];
  List<String> plantList = [];
  List<String> materialList = [];
  List<String> colorList = [];   // ✅ added
  List<String> reasonList = [];
  List<String> usersList = [];
  Map<String, String> locationDataMap = {}; // name -> id
  Map<String, String> plantDataMap = {};
  Map<String, String> materialDataMap = {};
  Map<String, String> usersDataMap = {}; // add this at class level
  String? username = '';
  String uuid = '';
  String? password = '';
  String? loginType = '';
  String? userType = '';
  String? readonly = '';
  String? attendonly = '';
  String? acces_payment = '';
  String? acces_dispatch = '';
  String? selectedColor;
  String? selectedReason;
  String? selectedusers;

  String? selectedLocationId;  // branch_id
  String? selectedPlantId;     // plant_id
  String? selectedMaterialId;  // material_id
  String? selectedColorId;     // color_id
  String? selectedUserId;      // receiver_admin_id
  String? selectedVessel;      // vessel_id (if applicable)
  String? selectedMaterial;
  String? selectedLocationName;
  String? selectedPlantName;
  String? selectedVesselId;

  Map<String, List<Map<String, String>>> vesselDataMap = {}; // location_id -> list of vessels
  List<String> vesselList = [];

  bool _isLoading = false;
  bool _uploading = false;
  final List<File> _images = [];
  bool isLoading = false;
  // NEW lists for Vessel and Material


  List<Map<String, TextEditingController>> sealInputs = [];


  @override
  void initState() {
    super.initState();
    fetchDropdownData();
    final now = DateTime.now();
    SealDateController.text = DateFormat('yyyy-MM-dd').format(now);
    SealTimeController.text = DateFormat('HH:mm:ss').format(now);
    TarpaulinConditionController.text = "Intact";
  }


  void _addSealRow() {
    setState(() {
      sealInputs.add({
        "rejected": TextEditingController(),
        "new": TextEditingController(),
      });
    });
  }
  void _calculateNetWeight() {
    final first = double.tryParse(FirstweightController.text.trim()) ?? 0.0;
    final second = double.tryParse(SecondweightController.text.trim()) ?? 0.0;

    // ✅ Always positive difference
    double net = (first - second).abs();

    setState(() {
      NetweightController.text = net.toStringAsFixed(2);
    });

    debugPrint("First=$first Second=$second Net=$net");
  }



  // ✅ Calculate normal seals
// ✅ Calculate normal seals
  void _calculateNoOfSeals() {
    final startSeal = StartSealnoController.text.trim();
    final endSeal = EndSealnoController.text.trim();

    final startMatch = RegExp(r'\d+').firstMatch(startSeal);
    final endMatch = RegExp(r'\d+').firstMatch(endSeal);

    int? startNum = int.tryParse(startMatch?.group(0) ?? "");
    int? endNum = int.tryParse(endMatch?.group(0) ?? "");

    debugPrint("Start Seal = $startSeal → $startNum");
    debugPrint("End Seal = $endSeal → $endNum");

    if (startNum != null && endNum != null) {
      final noOfSeals = (endNum - startNum).abs() + 1; // ✅ Absolute difference + 1
      debugPrint("No of Seals = $noOfSeals");
      setState(() {
        NoofSealsController.text = noOfSeals.toString();
      });
    } else {
      setState(() {
        NoofSealsController.text = "";
      });
    }
  }

// ✅ Calculate extra seals
  void _calculateNoOfExtraSeals() {
    final startSeal = ExtraStartSealNoController.text.trim();
    final endSeal = ExtraEndSealNoController.text.trim();

    final startMatch = RegExp(r'\d+').firstMatch(startSeal);
    final endMatch = RegExp(r'\d+').firstMatch(endSeal);

    int? startNum = int.tryParse(startMatch?.group(0) ?? "");
    int? endNum = int.tryParse(endMatch?.group(0) ?? "");

    debugPrint("Extra Start Seal = $startSeal → $startNum");
    debugPrint("Extra End Seal = $endSeal → $endNum");

    if (startNum != null && endNum != null) {
      final noOfSeals = (endNum - startNum).abs() + 1; // ✅ Absolute difference + 1
      debugPrint("Extra No of Seals = $noOfSeals");
      setState(() {
        ExtraNoofSealController.text = noOfSeals.toString();
      });
    } else {
      setState(() {
        ExtraNoofSealController.text = "";
      });
    }
  }
  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username");
    uuid = prefs.getString("uuid")!;
    uuid = prefs.getString("uuid")!;
    password = prefs.getString("password");
    loginType = prefs.getString("loginType");
    userType = prefs.getString("userType");
    readonly = prefs.getString("readonly");
    attendonly = prefs.getString("attendonly");
    acces_payment = prefs.getString("acces_payment");
    acces_dispatch = prefs.getString("acces_dispatch");
  }
  bool validateForm() {
    if (vehiclenoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Vehicle Number is required")),
      );
      return false;
    }

    // if (vehiclenoController.text.trim().length != 10) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text("❌ Vehicle Number must be exactly 10 characters")),
    //   );
    //   return false;
    // }

    // if (NetweightController.text.trim().isEmpty ||
    //     double.tryParse(NetweightController.text) == null ||
    //     double.parse(NetweightController.text) <= 0) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text("❌ Net Weight must be greater than 0")),
    //   );
    //   return false;
    // }

    if (StartSealnoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Start Seal No is required")),
      );
      return false;
    }

    if (EndSealnoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ End Seal No is required")),
      );
      return false;
    }

    if (NoofSealsController.text.trim().isEmpty ||
        int.tryParse(NoofSealsController.text) == null ||
        int.parse(NoofSealsController.text) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ No of Seals must be greater than 0")),
      );
      return false;
    }

    if (selectedLocationId == null || selectedLocationId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Please select a Location")),
      );
      return false;
    }

    if (selectedPlantId == null || selectedPlantId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Please select a Plant")),
      );
      return false;
    }

    if (selectedMaterialId == null || selectedMaterialId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Please select a Material")),
      );
      return false;
    }

    return true; // ✅ All checks passed
  }


  bool canShowSubmitButton() {
    return vehiclenoController.text.trim().isNotEmpty &&
        allowSlipController.text.trim().isNotEmpty &&
        NetweightController.text.trim().isNotEmpty &&
        NoofSealsController.text.trim().isNotEmpty &&
        selectedLocationId != null &&
        selectedPlantId != null &&
        selectedMaterialId != null &&
        selectedColor != null;
  }

  Future<void> fetchDropdownData() async {
    final prefs = await SharedPreferences.getInstance();

    final uuid = prefs.getString("uuid") ?? "";
    final userId = prefs.getString("username") ?? "";
    final password = prefs.getString("password") ?? "";
    final userType = prefs.getString("userType") ?? "";

    print("🔑 Using credentials:");
    print("uuid=$uuid, userId=$userId, password=$password, userType=$userType");


    final url = '${URL}get_dropdown';

    final body = {
      "uuid": uuid,
      "user_id": userId,
      "user_pass": password,
    };

    try {
      final response = await http.post(Uri.parse(url), body: body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["status"] == "1") {
          setState(() {
            // 🔹 Build location list & map
            locationList = (data["location_port"] as List)
                .where((loc) => loc["is_available_for_seal"] == "1") // ✅ filter
                .map<String>((loc) {
              locationDataMap[loc["location_name"]] = loc["location_id"].toString();
              return loc["location_name"].toString();
            }).toList();

            // ✅ Sort alphabetically
            // ✅ Sort alphabetically
            locationList.sort((a, b) => a.compareTo(b));

            // 🔹 Build plant list & map
            plantList = (data["plant"] as List).map<String>((p) {
              plantDataMap[p["plant_name"]] = p["plant_id"].toString();
              return p["plant_name"].toString();
            }).toList();
            plantList.sort((a, b) => a.compareTo(b));

            // 🔹 Build material list & map
            materialList = (data["material_port"] as List).map<String>((m) {
              materialDataMap[m["material_name"]] = m["material_id"].toString();
              return m["material_name"].toString();
            }).toList();
            materialList.sort((a, b) => a.compareTo(b));

            // 🔹 Build color list
            colorList = (data["color"] as List)
                .map<String>((c) => c["color_name"].toString())
                .toSet()
                .toList();
            colorList.sort((a, b) => a.compareTo(b));

            // 🔹 Build reason list
            reasonList = (data["reason"] as List)
                .map<String>((c) => c["reason"].toString())
                .toList();
            reasonList.sort((a, b) => a.compareTo(b));

            // 🔹 Build users list & map
            usersList = (data["users"] as List).map<String>((c) {
              usersDataMap[c["person_name"].toString()] = c["person_id"].toString();
              return c["person_name"].toString();
            }).toList();
            usersList.sort((a, b) => a.compareTo(b));

            // 🔹 Build vessel map (location_id → list of vessels)
            vesselDataMap.clear();
            (data["vessel"] as Map<String, dynamic>).forEach((locationId, vesselArray) {
              vesselDataMap[locationId] = (vesselArray as List)
                  .where((v) => v["is_active"].toString() == "1") // ✅ only active vessels
                  .map<Map<String, String>>((v) {
                return {
                  "id": v["vessel_id"].toString(),
                  "name": v["vessel_name"].toString(),
                };
              }).toList();
            });
            vesselList.sort((a, b) => a.compareTo(b));


            // ✅ Restore selected IDs after maps are ready
            if (selectedLocationName != null) {
              selectedLocationId = locationDataMap[selectedLocationName];
              debugPrint("Restored Location: $selectedLocationName → $selectedLocationId");
            }
            if (selectedPlantName != null) {
              selectedPlantId = plantDataMap[selectedPlantName];
              debugPrint("Restored Plant: $selectedPlantName → $selectedPlantId");
            }
            if (selectedMaterial != null) {
              selectedMaterialId = materialDataMap[selectedMaterial];
              debugPrint("Restored Material: $selectedMaterial → $selectedMaterialId");
            }

            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching dropdowns: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> submitSealData() async {
    if (!validateForm()) {
      return; // 🚫 Stop submission if form invalid
    }

    final prefs = await SharedPreferences.getInstance();
    final uuid = prefs.getString("uuid") ?? "";
    final userId = prefs.getString("username") ?? "";
    final password = prefs.getString("password") ?? "";
    final userType = prefs.getString("userType") ?? "";

    var url = Uri.parse(
      "${URL}add_edit_seal_data_test",
    );
    var request = http.MultipartRequest("POST", url);

    // 🔑 Required fields
    request.fields['uuid'] = uuid;
    request.fields['user_id'] = userId;
    request.fields['user_pass'] = password;

    // 🔹 Dropdown selections
    request.fields['from_location'] = selectedLocationId ?? "";
    request.fields['to_location'] = selectedPlantId ?? "";
    request.fields['material_id'] = selectedMaterialId ?? "";

    // 🔹 Seal date & time
    request.fields['seal_date'] = SealDateController.text;
    request.fields['start_time'] = SealTimeController.text;

    // 🔹 Basic inputs
    request.fields['allow_slip_no'] = allowSlipController.text;
    request.fields['vehicle_no'] = vehiclenoController.text;
    request.fields['first_weight'] = FirstweightController.text;
    request.fields['second_weight'] = SecondweightController.text;
    request.fields['net_weight'] = NetweightController.text;
    request.fields['tarpaulin_condition'] = TarpaulinConditionController.text;
    request.fields['seal_remarks'] = SenderRemarksController.text??'';

    // 🔹 Receiver person
    if (userType == 'S' || userType == 'A') {
      if (selectedUserId != null && selectedUserId!.isNotEmpty) {
        request.fields['receiver_admin_id'] = selectedUserId!;
      }
    }

    // 🔹 Seal fields
    request.fields['start_seal_no'] = StartSealnoController.text;
    request.fields['end_seal_no'] = EndSealnoController.text;
    request.fields['no_of_seal'] = NoofSealsController.text;
    request.fields['gps_seal_no'] = GPSSealNoController.text;
    request.fields['extra_start_seal_no'] = ExtraStartSealNoController.text;
    request.fields['extra_end_seal_no'] = ExtraEndSealNoController.text;
    request.fields['extra_no_of_seal'] = ExtraNoofSealController.text;
    request.fields['other_extra_seal'] = OtherExtraSealNoController.text;

    // 🔹 Seal color
    request.fields['seal_color'] = selectedColor ?? "";

    // 🔹 Vehicle reached (unloading) date & time
    if (userType == 'S' || userType == 'A') {
      if (VehicleReachedDateController.text.isNotEmpty) {
        request.fields['seal_unloading_date'] = VehicleReachedDateController.text;
      }
      if (VehicleReachedTimeController.text.isNotEmpty) {
        request.fields['seal_unloading_time'] = VehicleReachedTimeController.text;
      }
      if (selectedReason != null && selectedReason!.isNotEmpty) {
        request.fields['receiver_remarks'] = selectedReason!;
      }
    }

    // 🔹 Vessel
// 🔹 Vessel
    request.fields['vessel_id'] = selectedVesselId ?? "";


    // 🔹 Rejected & New Seals
    request.fields['rejected[rejected_seal_no]'] =
        sealInputs.map((row) => row["rejected"]!.text).toList().join(",");
    request.fields['rejected[new_seal_no]'] =
        sealInputs.map((row) => row["new"]!.text).toList().join(",");

    // 🔹 Attach images
    for (var img in _images) {
      request.files.add(await http.MultipartFile.fromPath('pics[]', img.path));
    }

    // 🔹 Attach images
    for (var img in _images) {
      request.files.add(await http.MultipartFile.fromPath('pics[]', img.path));
    }

    try {
      // 📝 Debug logs
      debugPrint("======= Seal Data Request Fields =======");
      request.fields.forEach((key, value) {
        debugPrint("$key : $value");
      });

      // 🔍 PRINT COMPLETE JSON BODY
      debugPrint("======= FINAL JSON BODY SENT =======");
      debugPrint(jsonEncode(request.fields));

      if (request.files.isNotEmpty) {
        debugPrint("======= Attached Images =======");
        for (var file in request.files) {
          debugPrint("${file.field} -> ${file.filename}");
        }
      } else {
        debugPrint("No images attached.");
      }

      // 🔹 Send request
      var response = await request.send();

      var responseBody = await response.stream.bytesToString();

      debugPrint("======= Raw API Response =======");
      debugPrint(responseBody);

      Map<String, dynamic> jsonData = {};
      try {
        // 🔥 Clean HTML + JSON → keep only JSON part
        int jsonStart = responseBody.indexOf("{");
        if (jsonStart != -1) {
          String cleanJson = responseBody.substring(jsonStart).trim();
          jsonData = json.decode(cleanJson);
        } else {
          throw const FormatException("No JSON found in response");
        }
      } catch (e) {
        debugPrint("JSON decode error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Invalid response from server")),
        );
        return;
      }

      debugPrint("======= Parsed API Response =======");
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response Body: $jsonData");

      if (response.statusCode == 200 && jsonData["status"] == "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ ${jsonData["msg"]}")),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed: ${jsonData["msg"] ?? "Unknown error"}")),
        );
      }
    } catch (e) {
      debugPrint("Error while submitting Seal Data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }


  Widget buildLabel(String label, {bool isMandatory = false}) {
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        children: isMandatory
            ? const [
          TextSpan(
            text: ' *',
            style: TextStyle(color: Colors.red),
          ),
        ]
            : [],
      ),
    );
  }


  Widget buildRowDropdown(
      String label,
      String hint,
      List<String> items,
      String? selectedValue,
      Function(String?) onChanged, {
        bool isMandatory = false,
      }) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: buildLabel(label, isMandatory: isMandatory),
        ),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: selectedValue,
            hint: Text(hint),
            isExpanded: true,
            onChanged: onChanged,
            items: items
                .map((val) => DropdownMenuItem(
              value: val,
              child: Text(val.toUpperCase()),
            ))
                .toList(),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
      ],
    );
  }


  Widget buildRowTextField(
      String label,
      String hint,
      TextEditingController controller, {
        Function(String)? onChanged,
        bool isNumeric = false,
        bool readOnly = false,
        VoidCallback? onTap,
        bool isMandatory = false,
        int? maxLength,
      }) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: buildLabel(label, isMandatory: isMandatory),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
            readOnly: readOnly,     // ✔ FIXED — don't force read-only
            onTap: onTap,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
          ),
        ),
      ],
    );
  }



  // Widget buildRowDatePicker(String label, DateTime? date) {
  //   return Row(
  //     children: [
  //       SizedBox(
  //         width: 100,
  //         child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
  //       ),
  //       Expanded(
  //         child: InkWell(
  //           onTap: () async {
  //             final picked = await showDatePicker(
  //               context: context,
  //               initialDate: DateTime.now(),
  //               firstDate: DateTime(2000),
  //               lastDate: DateTime(2100),
  //             );
  //             if (picked != null) {
  //               setState(() => sealDate = picked);
  //             }
  //           },
  //           child: InputDecorator(
  //             decoration: InputDecoration(
  //               filled: true,
  //               fillColor: Colors.grey[100],
  //               border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  //               contentPadding:
  //               const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  //             ),
  //             child: Text(
  //               date != null
  //                   ? DateFormat('yyyy-MM-dd').format(date)
  //                   : 'Select Date',
  //               style: const TextStyle(color: Colors.black87),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Future<void> _pickImagesFromGallery() async {
  //   final picker = ImagePicker();
  //   final pickedFiles = await picker.pickMultiImage();
  //   if (pickedFiles.isNotEmpty) {
  //     setState(() {
  //       _images.addAll(pickedFiles.map((e) => File(e.path)));
  //     });
  //   }
  // }
  Future<void> _pickImagesFromGallery() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      for (var file in pickedFiles) {
        await _compressAndAddImage(file.path);
      }
    }
  }

  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      await _compressAndAddImage(pickedFile.path);
    }
  }


  Future<File?> _compressAndAddImage(String imagePath) async {
    File imageFile = File(imagePath);

    try {
      // 🔹 Original size
      int originalSize = await imageFile.length();
      print("📷 Original Size: ${(originalSize / 1024 / 1024).toStringAsFixed(2)} MB");

      // 🔹 Decode
      List<int> imageBytes = await imageFile.readAsBytes();
      Img.Image? image = Img.decodeImage(Uint8List.fromList(imageBytes));
      if (image == null) throw Exception("Image decode failed");

      // 🔹 Resize (max width 1024)
      Img.Image resized = Img.copyResize(image, width: 1024);

      // 🔹 Encode
      List<int> compressedBytes;
      String extension = p.extension(imagePath).replaceFirst('.', '').toLowerCase(); // jpg, png, etc.

      if (extension == 'jpg' || extension == 'jpeg') {
        compressedBytes = Img.encodeJpg(resized, quality: 70); // reduce quality
      } else if (extension == 'png') {
        compressedBytes = Img.encodePng(resized, level: 6); // compress PNG
      } else {
        throw UnsupportedError('Unsupported image format: $extension');
      }

      // 🔹 Create clean filename
      String dir = p.dirname(imagePath);
      String timestamp = _formattedTimestamp(); // e.g. 2025-10-02_10-54-57
      String newFileName = "image_$timestamp.$extension"; // always starts with "image_"
      String newPath = p.join(dir, newFileName);

      // 🔹 Save compressed file
      File compressedFile = File(newPath);
      await compressedFile.writeAsBytes(compressedBytes);

      // 🔹 Compressed size
      int compressedSize = await compressedFile.length();
      print("✅ Compressed Size: ${(compressedSize / 1024 / 1024).toStringAsFixed(2)} MB");
      print("🔖 Saved as: $newFileName");

      setState(() {
        _images.add(compressedFile); // add in your list
      });

      return compressedFile;
    } catch (e) {
      print('❌ Error during image compression: $e');
      return null;
    }
  }

  /// Returns timestamp string in local time: YYYY-MM-DD_HH-MM-SS
  String _formattedTimestamp() {
    final now = DateTime.now().toLocal();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    final ss = now.second.toString().padLeft(2, '0');

    return "${y}-${m}-${d}_${hh}-${mm}-${ss}";
  }


  // Future<File?> _compressAndAddImage(String imagePath) async {
  //   File imageFile = File(imagePath);
  //
  //   try {
  //     // 🔹 Original size
  //     int originalSize = await imageFile.length();
  //     print("📷 Original Size: ${(originalSize / 1024 / 1024).toStringAsFixed(2)} MB");
  //
  //     // 🔹 Decode
  //     List<int> imageBytes = await imageFile.readAsBytes();
  //     Img.Image? image = Img.decodeImage(Uint8List.fromList(imageBytes));
  //     if (image == null) throw Exception("Image decode failed");
  //
  //     // 🔹 Resize (max width 1024)
  //     Img.Image resized = Img.copyResize(image, width: 1024);
  //
  //     // 🔹 Encode
  //     List<int> compressedBytes;
  //     String extension = imagePath.split('.').last.toLowerCase();
  //
  //     if (extension == 'jpg' || extension == 'jpeg') {
  //       compressedBytes = Img.encodeJpg(resized, quality: 70); // reduce quality
  //     } else if (extension == 'png') {
  //       compressedBytes = Img.encodePng(resized, level: 6); // compress PNG
  //     } else {
  //       throw UnsupportedError('Unsupported image format: $extension');
  //     }
  //
  //     // 🔹 Save compressed file
  //     String newPath = imagePath.replaceAll(RegExp(r'\.\w+$'), '_compressed.$extension');
  //     File compressedFile = File(newPath);
  //     await compressedFile.writeAsBytes(compressedBytes);
  //
  //     // 🔹 Compressed size
  //     int compressedSize = await compressedFile.length();
  //     print("✅ Compressed Size: ${(compressedSize / 1024 / 1024).toStringAsFixed(2)} MB");
  //
  //     setState(() {
  //       _images.add(compressedFile); // add in your list
  //     });
  //
  //     return compressedFile;
  //   } catch (e) {
  //     print('❌ Error during image compression: $e');
  //     return null;
  //   }
  // }


  // Future<void> _pickImageFromCamera() async {
  //   final picker = ImagePicker();
  //   final pickedFile = await picker.pickImage(source: ImageSource.camera);
  //   if (pickedFile != null) {
  //     setState(() {
  //       _images.add(File(pickedFile.path));
  //     });
  //   }
  // }


  bool areRequiredFieldsFilled() {
    return allowSlipController.text.isNotEmpty &&
        vehiclenoController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey[50],
      drawer: AppDrawer(currentPage: widget.currentPage),
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              // Inside your Column(children: [...]) before first form field
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: const [
                    Icon(Icons.verified, color: Colors.blueGrey, size: 28), // 🔹 Seal icon
                    SizedBox(width: 8),
                    Text(
                      "Add Seal",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                        decoration: TextDecoration.underline, // optional underline
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              buildRowDropdown(
                "Location Port :",
                "Select Location Port",
                locationList,
                selectedLocationName,
                    (val) {
                  setState(() {
                    selectedLocationName = val;
                    selectedLocationId = locationDataMap[val];

                    // ✅ Refresh vessel list for this location
                    vesselList = vesselDataMap[selectedLocationId]
                        ?.map((v) => v["name"]!)
                        .toList() ??
                        [];

                    selectedVessel = null;
                    selectedVesselId = null;

                    debugPrint("Location selected: $val → $selectedLocationId");
                    debugPrint("Vessel list for this location: $vesselList");
                  });
                },
                isMandatory: true, // 🔹 shows red * in label
              ),




              const SizedBox(height: 20),

              // Plant Dropdown
              buildRowDropdown(
                "Plant :",
                "Select Plant",
                plantList,
                selectedPlantName,
                    (val) {
                  setState(() {
                    selectedPlantName = val;
                    selectedPlantId = plantDataMap[val] ?? ""; // map name → id
                  });
                },
                isMandatory: true,
              ),


              const SizedBox(height: 20),

              // Material Dropdown
              buildRowDropdown(
                "Material :",
                "Select Material",
                materialList,
                selectedMaterial,
                    (val) {
                  setState(() {
                    selectedMaterial = val;
                    selectedMaterialId = materialDataMap[val] ?? ""; // map name → id
                  });
                },
                isMandatory: true,
              ),


              const SizedBox(height: 20),

// Vessel Dropdown
              buildRowDropdown(
                "Vessel :",
                "Select Vessel",
                vesselList,
                selectedVessel,
                    (val) {
                  setState(() {
                    selectedVessel = val;

                    // ✅ Get vessel_id from vesselDataMap
                    selectedVesselId = vesselDataMap[selectedLocationId]
                        ?.firstWhere((v) => v["name"] == val)["id"];

                    debugPrint("Vessel selected: $selectedVessel → $selectedVesselId");
                  });
                },
              ),


              const SizedBox(height: 20),

              buildRowTextField(
                "Allow Slip No:",
                "Enter Allow Slip No",
                allowSlipController,
                onChanged: (_) {},   // 👈 keeps it editable but does nothing
                isNumeric: false,
              ),

              const SizedBox(height: 20),
              // Vehicle No field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildRowTextField(
                    "Vehicle No:",
                    "Enter Vehicle Number",
                    vehiclenoController,
                    onChanged: (_) => setState(() {}), // ✅ keeps UI updated
                    isNumeric: false,
                    isMandatory: true,
                    maxLength: 10, // ⬅️ prevents typing more than 10
                  ),
                  const SizedBox(height: 4),
                  // if (vehiclenoController.text.isNotEmpty &&
                  //     vehiclenoController.text.length != 10) // ✅ validation
                  //   const Padding(
                  //     padding: EdgeInsets.only(left: 110), // 👈 aligns under input
                  //     child: Text(
                  //       "Vehicle Number must be exactly 10 characters",
                  //       style: TextStyle(
                  //         fontSize: 12,
                  //         color: Colors.red,
                  //         fontWeight: FontWeight.w500,
                  //       ),
                  //     ),
                  //   ),
                ],
              ),



              const SizedBox(height: 20),
              buildRowTextField(
                "Seal Date:",
                "",
                SealDateController,
                onChanged: null,
                readOnly: true, // 🔹 Make non-editable
              ),
              const SizedBox(height: 20),
              buildRowTextField(
                "Seal Time:",
                "",
                SealTimeController,
                onChanged: null,
                readOnly: true, // 🔹 Make non-editable
              ),


              const SizedBox(height: 20),
              // First Weight field
              buildRowTextField(
                "First Weight:",
                "Enter First Weight",
                FirstweightController,
                onChanged: (_) => _calculateNetWeight(),
                isNumeric: true,   // 👈 only numbers
              ),
              const SizedBox(height: 20),
              buildRowTextField(
                "Second Weight:",
                "Enter Second Weight",
                SecondweightController,
                onChanged: (_) => _calculateNetWeight(),
                isNumeric: true,   // 👈 only numbers
              ),

              const SizedBox(height: 20),

// Net Weight field (Read-only)
              Row(
                children: [
                  const SizedBox(
                    width: 110,
                    child: Row(
                      children: [
                        Text(
                          "Net Weight:",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),

                      ],
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: NetweightController,
                      readOnly: true, // 👈 Prevent manual editing
                      validator: (value) {
                        return null; // ✅ Not mandatory anymore
                      },

                      decoration: InputDecoration(
                        hintText: "0.0",
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),



              const SizedBox(height: 20),
              buildRowTextField(
                "Start Seal No:",
                "Enter Start Seal No",
                StartSealnoController,
                onChanged: (_) {
                  _calculateNoOfSeals();   // 🔹 your calculation logic
                  setState(() {});         // 🔹 refresh UI after calculation
                },
                isNumeric: false,
              ),


              const SizedBox(height: 20),
              buildRowTextField(
                "End Seal No:",
                "Enter End Seal No",
                EndSealnoController,
                onChanged: (_) {
                  _calculateNoOfSeals();   // 🔹 update seal count
                  setState(() {});         // 🔹 refresh UI after change
                },
                isNumeric: false,
              ),

              const SizedBox(height: 20),
              buildRowTextField(
                "No of Seals:",
                "",
                NoofSealsController,
                onChanged: (_) {},   // no manual input
                isNumeric: true,
                readOnly: true,      // ✅ makes the field non-editable
              ),



              const SizedBox(height: 20),
              buildRowDropdown(
                "Color :",
                "Select Color",
                colorList,
                selectedColor,
                    (val) {
                  setState(() {
                    selectedColor = val; // ✅ directly store the name
                  });
                },
              ),


              const SizedBox(height: 20),
              buildRowTextField(
                "Extra Start Seal No :",
                "Enter Extra Start Seal No",
                ExtraStartSealNoController,
                onChanged: (_) => _calculateNoOfExtraSeals(),
                isNumeric: false,
              ),
              const SizedBox(height: 20),   buildRowTextField(
                "Extra End Seal No :",
                "Enter Extra End Seal No",
                ExtraEndSealNoController,
                onChanged: (_) => _calculateNoOfExtraSeals(),
                isNumeric: false,
              ),
              const SizedBox(height: 20),
              buildRowTextField(
                "Extra No of Seals :",
                "",
                ExtraNoofSealController,

                onChanged: null, // 👈 read-only
              ),
              const SizedBox(height: 20),
              buildRowTextField(
                "Other Extra Seal No:",
                "Add other extra seal by",
                OtherExtraSealNoController,
              ),
              const SizedBox(height: 20),
              buildRowTextField(
                "GPS Seal No:",
                "Enter GPS Seal No",
                GPSSealNoController,
                onChanged: (_) {},   // 👈 keeps it editable but does nothing
                isNumeric: false,
              ),
              const SizedBox(height: 20),
              buildRowTextField(
                "Tarpaulin Condition:",
                "Intact",
                TarpaulinConditionController,
                onChanged: (val) {},
                isNumeric: false,
                readOnly: false,   //  🚨 THIS MAKES CONTROLLER EMPTY
              ),

              const SizedBox(height: 20),
              buildRowTextField(
                "Sender Remarks:",
                "Enter Sender Remarks",
                SenderRemarksController,
                onChanged: (_) {},   // 👈 keeps it editable but does nothing
                isNumeric: false,
              ),
              const SizedBox(height: 20),
              buildRowDropdown(
                "Received by :",
                "Select Receiver",
                usersList,
                selectedusers,
                    (val) {
                  setState(() {
                    selectedusers = val;
                    selectedUserId = usersDataMap[val] ?? "";  // ✅ Now stores person_id
                    debugPrint("Selected User = $selectedusers → ID = $selectedUserId");
                  });
                },
              ),
              const SizedBox(height: 20),
              buildRowTextField(
                "Vehicle Reached Date:",
                "Select Date",
                VehicleReachedDateController,
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      VehicleReachedDateController.text =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                    });
                  }
                },
              ),

              const SizedBox(height: 20),

              buildRowTextField(
                "Vehicle Reached Time:",
                "Select Time",
                VehicleReachedTimeController,
                readOnly: true,
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    final now = DateTime.now();
                    final dt = DateTime(
                        now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);
                    setState(() {
                      VehicleReachedTimeController.text =
                          DateFormat('HH:mm:ss').format(dt); // 24h format
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              buildRowDropdown(
                "Reciever Remarks :",
                "Select Reciever",
                reasonList,
                selectedReason,
                    (val) => setState(() => selectedReason = val),
              ),
              const SizedBox(height: 20),
              // Row with 3 boxes
              // Row with 3 joined boxes
              // Row with 3 joined boxes
              Row(
                children: [
                  // Add Seal
                  Expanded(
                    child: GestureDetector(
                      onTap: _addSealRow, // 👈 Adds a new row when tapped
                      child: Container(
                        height: 100, // slightly taller to fit icon
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.grey),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            SizedBox(height: 6),
                            Text(
                              "Add Seal",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 6),
                            Icon(Icons.add_circle, color: Colors.blue, size: 20), // small + icon
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Rejected Seal
                  Expanded(
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border(
                          top: BorderSide(color: Colors.grey),
                          bottom: BorderSide(color: Colors.grey),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          SizedBox(height: 6),
                          Text(
                            "Rejected Seal",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 6),
                          Icon(Icons.remove_circle, color: Colors.red, size: 20), // small - icon
                        ],
                      ),
                    ),
                  ),

                  // New Seal
                  Expanded(
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.grey),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          SizedBox(height: 6),
                          Text(
                            "New Seal",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 6),
                          Icon(Icons.check_circle, color: Colors.green, size: 20), // small tick icon
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Column(
                children: List.generate(sealInputs.length, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: Row(
                      children: [
                        // 1. Remove Button ("-")
                        SizedBox(
                          width: 40, // fixed width for dash
                          child: Center(
                            child: IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  sealInputs.removeAt(index);
                                });
                              },
                            ),
                          ),
                        ),

                        // Divider
                        Container(width: 1, height: 50, color: Colors.grey),

                        // 2. Rejected Seal
                        Expanded(
                          child: TextField(
                            controller: sealInputs[index]["rejected"],
                            decoration: const InputDecoration(
                              hintText: "Enter Rejected Seal",
                              hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12),
                            ),
                          ),
                        ),

                        // Divider
                        Container(width: 1, height: 50, color: Colors.grey),

                        // 3. New Seal
                        Expanded(
                          child: TextField(
                            controller: sealInputs[index]["new"],
                            decoration: const InputDecoration(
                              hintText: "Enter New Seal",
                              hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),


              // 📷 Pick from Camera
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Blue background
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _uploading ? null : _pickImageFromCamera,
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                label: const Text(
                  "Take Photo with Camera",
                  style: TextStyle(color: Colors.white),
                ),
              ),

              const SizedBox(height: 10),

              // 🖼️ Pick from Gallery
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _uploading ? null : _pickImagesFromGallery,
                icon: const Icon(Icons.photo_library, color: Colors.white),
                label: const Text(
                  "Add Photos from Gallery",
                  style: TextStyle(color: Colors.white),
                ),
              ),


              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _images
                    .map((img) => Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(img,
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.close,
                              size: 18, color: Colors.red),
                          onPressed: () =>
                              setState(() => _images.remove(img)),
                        ),
                      ),
                    ),
                  ],
                ))
                    .toList(),
              ),

              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                width: 200,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey, // 🔹 Grey background
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    if (!validateForm()) return; // ✅ stop & show error if validation fails

                    debugPrint("Submitting form...");
                    setState(() => isLoading = true);

                    await submitSealData();

                    setState(() => isLoading = false);
                  },
                  child: isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    "Submit",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white, // 🔹 White text
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
