import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert'; // for json.decode
import 'package:http/http.dart' as http; // for http.post
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scrapapp/AppClass/AppDrawer.dart';
import 'package:scrapapp/AppClass/appBar.dart';
import '../URL_CONSTANT.dart';

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as Img;
import 'package:path/path.dart' as p;

class EditSealPage extends StatefulWidget {
  final int currentPage;
  final List<String> serverImages;
  final String sealTransactionId;

  const EditSealPage({
    Key? key,
    required this.currentPage,
    required this.sealTransactionId,
    required this.serverImages,
  }) : super(key: key);

  // const EditSealPage({Key? key, required this.seal}) : super(key: key);

  @override
  State<EditSealPage> createState() => _EditSealPageState();
}

class _EditSealPageState extends State<EditSealPage> {
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
  final TextEditingController ExtraStartSealNoController =
  TextEditingController();
  final TextEditingController ExtraEndSealNoController =
  TextEditingController();
  final TextEditingController ExtraNoofSealController = TextEditingController();
  final TextEditingController OtherExtraSealNoController =
  TextEditingController();
  final TextEditingController GPSSealNoController = TextEditingController();
  final TextEditingController TarpaulinConditionController =
  TextEditingController();
  final TextEditingController SenderRemarksController = TextEditingController();
  final TextEditingController RecievedbyController = TextEditingController();
  final TextEditingController VehicleReachedDateController =
  TextEditingController();
  final TextEditingController VehicleReachedTimeController =
  TextEditingController();
  final TextEditingController ReceiverRemarksController =
  TextEditingController();

  List<String> locationList = [];
  List<String> plantList = [];
  List<String> materialList = [];
  List<String> colorList = []; // ✅ added
  List<String> reasonList = [];
  List<String> usersList = [];
  List<String> serverImages = []; // holds uploaded images for this seal
  Map<String, String> locationDataMap = {}; // name -> id
  Map<String, String> plantDataMap = {};
  Map<String, String> materialDataMap = {};
  Map<String, String> usersDataMap = {}; // add this at class level

  String? selectedLocationId; // branch_id
  String? selectedPlantId; // plant_id
  String? selectedMaterialId; // material_id
  String? selectedColorId; // color_id
  String? selectedUserId; // receiver_admin_id
  String? selectedVessel; // vessel_id (if applicable)
  String? selectedColor;
  String? selectedReason;
  String? selectedusers;
  String? selectedLocationName;
  String? selectedPlantName;
  String? selectedVesselId;

  String? selectedMaterial;
  DateTime? sealDate;
  Map<String, List<Map<String, String>>> vesselDataMap =
  {}; // location_id -> list of vessels
  List<String> vesselList = [];
  bool _isLoading = false;
  bool _uploading = false;
  final List<File> _images = [];
  // NEW lists for Vessel and Material

  bool isLoading = false;

  List<Map<String, TextEditingController>> sealInputs = [];

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    SealDateController.text = DateFormat('yyyy-MM-dd').format(now);
    SealTimeController.text = DateFormat('HH:mm:ss').format(now);
    // TarpaulinConditionController.text = "Intact";
    // Make sure async calls happen after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await fetchDropdownData(); // fetch dropdown options first
      await fetchSealData();     // then fetch seal data to prefill
    });
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
    final first = double.tryParse(FirstweightController.text) ?? 0.0;
    final second = double.tryParse(SecondweightController.text) ?? 0.0;

    // ✅ Net weight = Second - First
    double net = second - first;

    // 🚫 Prevent negative net weight
    if (net < 0) net = 0.0;

    setState(() {
      NetweightController.text = net.toStringAsFixed(2);
    });
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


  bool validateForm() {
    // Vehicle No validations
    if (vehiclenoController.text.trim().isEmpty) {
      debugPrint("❌ Vehicle Number is empty");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Vehicle Number is required")),
      );
      return false;
    }

    // if (vehiclenoController.text.trim().length != 10) {
    //   debugPrint("❌ Vehicle Number length invalid → ${vehiclenoController.text}");
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text("❌ Vehicle Number must be exactly 10 characters")),
    //   );
    //   return false;
    // }

    // Net Weight validation
    // if (NetweightController.text.trim().isEmpty ||
    //     double.tryParse(NetweightController.text) == null ||
    //     double.parse(NetweightController.text) <= 0) {
    //   debugPrint("❌ Net Weight invalid → ${NetweightController.text}");
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text("❌ Net Weight must be greater than 0")),
    //   );
    //   return false;
    // }

    // Seal numbers validation
    if (StartSealnoController.text.trim().isEmpty) {
      debugPrint("❌ Start Seal No is empty");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Start Seal No is required")),
      );
      return false;
    }

    if (EndSealnoController.text.trim().isEmpty) {
      debugPrint("❌ End Seal No is empty");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ End Seal No is required")),
      );
      return false;
    }

    // No of Seals validation
    if (NoofSealsController.text.trim().isEmpty ||
        int.tryParse(NoofSealsController.text) == null ||
        int.parse(NoofSealsController.text) <= 0) {
      debugPrint("❌ No of Seals invalid → ${NoofSealsController.text}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ No of Seals must be greater than 0")),
      );
      return false;
    }

    // Dropdown validations
    if (selectedLocationId == null || selectedLocationId!.isEmpty) {
      debugPrint("❌ Location not selected → $selectedLocationId");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Please select a Location")),
      );
      return false;
    }

    if (selectedPlantId == null || selectedPlantId!.isEmpty) {
      debugPrint("❌ Plant not selected → $selectedPlantId");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Please select a Plant")),
      );
      return false;
    }

    if (selectedMaterialId == null || selectedMaterialId!.isEmpty) {
      debugPrint("❌ Material not selected → $selectedMaterialId");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Please select a Material")),
      );
      return false;
    }

    // ✅ Success
    debugPrint("🎯 Validation passed");
    debugPrint(
        "📌 Location=$selectedLocationId, Plant=$selectedPlantId, Material=$selectedMaterialId");

    return true;
  }



  Future<void> fetchSealData() async {
    final prefs = await SharedPreferences.getInstance();

    final uuid = prefs.getString("uuid") ?? "";
    final userId = prefs.getString("username") ?? "";
    final password = prefs.getString("password") ?? "";
    final userType = prefs.getString("userType") ?? "";

    const url = "${URL}fetch_data";

    final body = {
      "uuid": uuid,
      "user_id": userId,
      "user_pass": password,
      "user_type": userType,
      "seal_transaction_id": widget.sealTransactionId,
    };

    try {
      final response = await http.post(Uri.parse(url), body: body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        const JsonEncoder encoder = JsonEncoder.withIndent('  ');
        final prettyString = encoder.convert(data);
        debugPrint("📦 API Response:\n$prettyString");

        if (data["fetch_data"] != null && data["fetch_data"]["seal_data"] != null) {
          final sealData = data["fetch_data"]["seal_data"];
          final rejSeal = data["fetch_data"]["rejected_seal"];

          setState(() {
            final rejectedSeals = data["fetch_data"]["rejected_seal"] ?? [];
            _initializeSealInputs(rejectedSeals);

            // Controllers
            allowSlipController.text = sealData["allow_slip_no"]?.toString() ?? "";
            vehiclenoController.text = sealData["vehicle_no"]?.toString() ?? "";
            SealDateController.text = sealData["seal_date"]?.toString() ?? "";
            SealTimeController.text = sealData["seal_start_time"]?.toString() ?? "";
            FirstweightController.text = sealData["first_weight"]?.toString() ?? "";
            SecondweightController.text = sealData["second_weight"]?.toString() ?? "";
            NetweightController.text = sealData["net_weight"]?.toString() ?? "";
            StartSealnoController.text = sealData["start_seal_no"]?.toString() ?? "";
            EndSealnoController.text = sealData["end_seal_no"]?.toString() ?? "";
            NoofSealsController.text = sealData["no_of_seal"]?.toString() ?? "";
            ExtraStartSealNoController.text = sealData["extra_start_seal_no"]?.toString() ?? "";
            ExtraEndSealNoController.text = sealData["extra_end_seal_no"]?.toString() ?? "";
            ExtraNoofSealController.text = sealData["extra_no_of_seal"]?.toString() ?? "";
            OtherExtraSealNoController.text = sealData["other_extra_seal_no"]?.toString() ?? "";
            GPSSealNoController.text = sealData["gps_seal_no"]?.toString() ?? "";
            TarpaulinConditionController.text = sealData["tarpaulin_condition"]?.toString() ?? "";
            SenderRemarksController.text = sealData["seal_remarks"]?.toString() ?? "";
            ReceiverRemarksController.text = sealData["receiver_remarks"]?.toString() ?? "";
            VehicleReachedDateController.text = sealData["seal_unloading_date"]?.toString() ?? "";
            VehicleReachedTimeController.text = sealData["seal_unloading_time"]?.toString() ?? "";

            // Dropdowns
            selectedVesselId = sealData["vessel_id"]?.toString();
            selectedColor = sealData["seal_color"]?.toString();
            selectedusers = sealData["person_name"]?.toString();
            selectedReason = sealData["receiver_remarks"]?.toString();

            // IDs
            selectedLocationId = sealData["location_id"]?.toString();
            selectedPlantId = sealData["plant_id"]?.toString();
            selectedMaterialId = sealData["material_id"]?.toString();

            // Lookup names
            selectedLocationName = locationDataMap.entries
                .firstWhere(
                  (entry) => entry.value.toString() == selectedLocationId,
              orElse: () => MapEntry("UNKNOWN LOCATION", ""),
            )
                .key;


            print("Bharatr:$locationDataMap");

            selectedPlantName = plantDataMap.entries
                .firstWhere(
                  (entry) => entry.value.toString() == selectedPlantId,
              orElse: () => MapEntry("Unknown Plant", ""),
            )
                .key;

            selectedMaterial = materialDataMap.entries
                .firstWhere(
                  (entry) => entry.value.toString() == selectedMaterialId,
              orElse: () => MapEntry("Unknown Material", ""),
            )
                .key;

            vesselList = vesselDataMap[selectedLocationId]
                ?.map((v) => v["name"]!)
                .toList() ??
                [];

            selectedVessel = vesselDataMap[selectedLocationId]
                ?.firstWhere(
                  (v) => v["id"].toString() == selectedVesselId,
              orElse: () => {"id": "", "name": "Unknown Vessel"},
            )["name"];

            // Server images
            serverImages = [];
            if (data["fetch_data"]["pics"] != null) {
              serverImages.addAll((data["fetch_data"]["pics"] as List)
                  .map<String>((pic) => pic["img"].toString()));
            }
            serverImages = serverImages.toSet().toList();

            // ✅ Debug prints for prefill
            debugPrint("🎯 Prefilled Data:");
            debugPrint("  Allow Slip No        : ${allowSlipController.text}");
            debugPrint("  Vehicle No           : ${vehiclenoController.text}");
            debugPrint("  Seal Date            : ${SealDateController.text}");
            debugPrint("  Seal Time            : ${SealTimeController.text}");
            debugPrint("  First Weight         : ${FirstweightController.text}");
            debugPrint("  Second Weight        : ${SecondweightController.text}");
            debugPrint("  Net Weight           : ${NetweightController.text}");
            debugPrint("  Start Seal No        : ${StartSealnoController.text}");
            debugPrint("  End Seal No          : ${EndSealnoController.text}");
            debugPrint("  No of Seals          : ${NoofSealsController.text}");
            debugPrint("  Extra Start Seal No  : ${ExtraStartSealNoController.text}");
            debugPrint("  Extra End Seal No    : ${ExtraEndSealNoController.text}");
            debugPrint("  Extra No of Seal     : ${ExtraNoofSealController.text}");
            debugPrint("  Other Extra Seal No  : ${OtherExtraSealNoController.text}");
            debugPrint("  GPS Seal No          : ${GPSSealNoController.text}");
            debugPrint("  Tarpaulin Condition  : ${TarpaulinConditionController.text}");
            debugPrint("  Sender Remarks       : ${SenderRemarksController.text}");
            debugPrint("  Receiver Remarks     : ${ReceiverRemarksController.text}");
            debugPrint("  Vehicle Reached Date : ${VehicleReachedDateController.text}");
            debugPrint("  Vehicle Reached Time : ${VehicleReachedTimeController.text}");

            debugPrint("  Selected Location ID : $selectedLocationId");
            debugPrint("  Selected Location    : $selectedLocationName");
            debugPrint("  Selected Plant ID    : $selectedPlantId");
            debugPrint("  Selected Plant Name  : $selectedPlantName");
            debugPrint("  Selected Material ID : $selectedMaterialId");
            debugPrint("  Selected Material    : $selectedMaterial");
            debugPrint("  Selected Vessel ID   : $selectedVesselId");
            debugPrint("  Selected Vessel Name : $selectedVessel");
            debugPrint("  Selected Color       : $selectedColor");
            debugPrint("  Selected User        : $selectedusers");
            debugPrint("  Selected Reason      : $selectedReason");
            debugPrint("  Server Images Count  : ${serverImages.length}");
            debugPrint("  Vessel List          : $vesselList");
          });

          debugPrint("🎯 Controllers & dropdowns updated successfully.");
        } else {
          debugPrint("⚠️ No 'seal_data' found inside 'fetch_data'.");
        }
      } else {
        debugPrint("❌ Request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Error fetching seal data: $e");
    }
  }


  void _initializeSealInputs(List<dynamic> rejectedSeals) {
    sealInputs.clear();
    print("Initializing Seal Inputs...");

    for (var i = 0; i < rejectedSeals.length; i++) {
      var seal = rejectedSeals[i];

      sealInputs.add({
        "rejected": TextEditingController(text: seal["rejected_seal_no"]?.toString() ?? ""),
        "new": TextEditingController(text: seal["new_seal_no"]?.toString() ?? ""),
      });
    }

    setState(() {}); // UI refresh
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
    request.fields['seal_transaction_id'] = widget.sealTransactionId;

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
    request.fields['seal_remarks'] = SenderRemarksController.text;

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
        request.fields['seal_unloading_date'] =
            VehicleReachedDateController.text;
      }
      if (VehicleReachedTimeController.text.isNotEmpty) {
        request.fields['seal_unloading_time'] =
            VehicleReachedTimeController.text;
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

    try {
      // 📝 Debug logs
      debugPrint("======= Seal Data Request Fields =======");
      request.fields.forEach((key, value) {
        debugPrint("$key : $value");
      });

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
          SnackBar(
              content: Text("❌ Failed: ${jsonData["msg"] ?? "Unknown error"}")),
        );
      }
    } catch (e) {
      debugPrint("Error while submitting Seal Data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> fetchDropdownData() async {
    final prefs = await SharedPreferences.getInstance();

    final uuid = prefs.getString("uuid") ?? "";
    final userId = prefs.getString("username") ?? "";
    final password = prefs.getString("password") ?? "";
    final userType = prefs.getString("userType") ?? "";

    print("🔑 Using credentials:");
    print("uuid=$uuid, userId=$userId, password=$password, userType=$userType");

    final String url = "${URL}get_dropdown"; // ✅ interpolated URL


    final body = {
      "uuid": uuid,
      "user_id": userId,
      "user_pass": password,
      "user_type": userType,
    };

    try {
      final response = await http.post(Uri.parse(url), body: body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["status"] == "1") {
          setState(() {
            // 🔹 Build location list & map
            locationList = (data["location_port"] as List)
                .where((loc) => loc["is_available_for_seal"] == "1")
                .map<String>((loc) {
              final name = loc["location_name"].toString().trim().toUpperCase();
              locationDataMap[name] = loc["location_id"].toString();
              return name;
            }).toList();
            locationList.sort((a, b) => a.compareTo(b));


            // 🔹 Build plant list & map
            plantList = (data["plant"] as List).map<String>((pl) {
              final name = pl["plant_name"].toString().trim().toUpperCase();
              plantDataMap[name] = pl["plant_id"].toString();
              return name;
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
                .map<String>((c) => c["color_name"].toString().toUpperCase())
                .toSet()
                .toList();
            colorList.sort((a, b) => a.compareTo(b));

            // 🔹 Build reason list
            reasonList = (data["reason"] as List)
                .map<String>((c) => c["reason"].toString())
                .toList();
            reasonList.sort((a, b) => a.compareTo(b));


            usersList = (data["users"] as List).map<String>((c) {
              usersDataMap[c["person_name"].toString()] = c["person_id"].toString();
              return c["person_name"].toString();
            }).toList();
            usersList.sort((a, b) => a.compareTo(b));

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

            //✅ Restore selected IDs after maps are ready
            if (selectedLocationName != null) {
              selectedLocationId =
              locationDataMap[selectedLocationName!.trim().toUpperCase()];
              debugPrint(
                  "Restored Location: $selectedLocationName → $selectedLocationId");
            }
            if (selectedPlantName != null) {
              selectedPlantId =
              plantDataMap[selectedPlantName!.trim().toUpperCase()];
              debugPrint("Restored Plant: $selectedPlantName → $selectedPlantId");
            }
            if (selectedMaterial != null) {
              selectedMaterialId =
              materialDataMap[selectedMaterial!.trim().toUpperCase()];
              debugPrint("Restored Material: $selectedMaterial → $selectedMaterialId");
            }
            if (selectedVessel != null && selectedLocationId != null) {
              final vesselsForLocation = vesselDataMap[selectedLocationId] ?? [];
              final match = vesselsForLocation.firstWhere(
                    (v) => v["name"]?.trim().toUpperCase() ==
                    selectedVessel!.trim().toUpperCase(),
                orElse: () => {},
              );

              if (match.isNotEmpty) {
                selectedVesselId = match["id"];
                selectedVessel = match["name"]; // 👈 ensure dropdown displays vessel
                debugPrint("Restored Vessel: $selectedVessel → $selectedVesselId");
              } else {
                debugPrint("⚠️ Vessel $selectedVessel not found in dropdown list for location $selectedLocationId");
              }
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

  Future<void> deleteSealImage(String imageUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final uuid = prefs.getString("uuid") ?? "";
      final userId = prefs.getString("username") ?? "";
      final password = prefs.getString("password") ?? "";

      const url =
          "${URL}delete_seal_images";

      final body = {
        "uuid": uuid,
        "user_id": userId,
        "user_pass": password,
        "seal_transaction_id": widget.sealTransactionId,
        "image_data": imageUrl, // ✅ pass image URL dynamically
      };

      // 🔹 Print body to debug
      debugPrint("📤 Deleting image with body: $body");

      final response = await http.post(Uri.parse(url), body: body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final msg = data["msg"] ?? "Unexpected response";

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)), // ✅ show server message
        );

        if (data["status"] == "1") {
          setState(() {
            serverImages.remove(imageUrl); // ✅ remove deleted image from UI
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Server error while deleting image")),
        );
      }
    } catch (e) {
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
    // ✅ Normalize items: trim spaces and convert to uppercase, remove duplicates
    final cleanItems =
    items.map((c) => c.trim().toUpperCase()).toSet().toList();

    // ✅ Ensure selectedValue exists in the list; otherwise null
    final safeSelectedValue =
    cleanItems.contains(selectedValue?.trim().toUpperCase())
        ? selectedValue?.trim().toUpperCase()
        : null;

    return Row(
      children: [
        SizedBox(
          width: 110,
          child: buildLabel(label, isMandatory: isMandatory),
        ),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: safeSelectedValue,
            hint: Text(hint),
            isExpanded: true,
            onChanged: onChanged,
            items: cleanItems
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
            readOnly: readOnly || onTap != null, // disable typing if picker
            onTap: onTap,
            decoration: InputDecoration(
              hintText: hint,
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
                    Icon(Icons.verified,
                        color: Colors.blueGrey, size: 28), // 🔹 Seal icon
                    SizedBox(width: 8),
                    Text(
                      "Edit Seal",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                        decoration:
                        TextDecoration.underline, // optional underline
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              buildRowDropdown(
                "Location port:",
                "Select Location port",
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
                    selectedMaterialId =
                        materialDataMap[val] ?? ""; // map name → id
                  });
                },
                isMandatory: true,
              ),

              const SizedBox(height: 20),
              buildRowDropdown(
                "Vessel :",
                "Select Vessel",
                (vesselDataMap[selectedLocationId] ?? [])
                    .map((v) => v["name"] as String)
                    .toList(),
                // ✅ only set value if it exists in items
                (vesselDataMap[selectedLocationId] ?? [])
                    .any((v) => v["name"].toString().trim() == selectedVessel?.trim())
                    ? selectedVessel?.trim()
                    : null,
                    (val) {
                  setState(() {
                    selectedVessel = val;

                    final vessels = vesselDataMap[selectedLocationId] ?? [];
                    final match = vessels.firstWhere(
                          (v) => v["name"].toString().trim() == val?.trim(),
                      orElse: () => {},
                    );

                    if (match.isNotEmpty) {
                      selectedVesselId = match["id"];
                      debugPrint("✅ Vessel selected: $selectedVessel → $selectedVesselId");
                    } else {
                      selectedVesselId = null;
                      debugPrint("⚠️ Vessel not found for $selectedVessel");
                    }
                  });
                },
              ),

              const SizedBox(height: 20),

              buildRowTextField(
                "Allow Slip No:",
                "Enter Allow Slip No",
                allowSlipController,
                onChanged: (_) {}, // 👈 keeps it editable but does nothing
                isNumeric: false,
              ),

              const SizedBox(height: 20),
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
              buildRowTextField("Seal Date:", "", SealDateController,
                  onChanged: null, readOnly: true),
              const SizedBox(height: 20),
              buildRowTextField("Seal Time:", "", SealTimeController,
                  onChanged: null, readOnly: true),

              const SizedBox(height: 20),
              // First Weight field
              buildRowTextField(
                "First Weight:",
                "Enter First Weight",
                FirstweightController,
                onChanged: (_) => _calculateNetWeight(),
                isNumeric: true, // 👈 only numbers
              ),
              const SizedBox(height: 20),
              buildRowTextField(
                "Second Weight:",
                "Enter Second Weight",
                SecondweightController,
                onChanged: (_) => _calculateNetWeight(),
                isNumeric: true, // 👈 only numbers
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
                        // Text(
                        //   " *",
                        //   style: TextStyle(
                        //       color: Colors.red), // 👈 Mandatory indicator
                        // ),
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
                " Start Seal No :",
                "Enter  Start Seal No",
                StartSealnoController,
                onChanged: (_) => _calculateNoOfSeals(),
                isNumeric: false,
              ),
              const SizedBox(height: 20),
              buildRowTextField(
                "End Seal No :",
                "Enter  End Seal No",
                EndSealnoController,
                onChanged: (_) => _calculateNoOfSeals(),
                isNumeric: false,
              ),
              const SizedBox(height: 20),
              buildRowTextField(
                "No of Seals :",
                "",
                NoofSealsController,
                onChanged: null, // 👈 read-only
              ),

              const SizedBox(height: 20),
              buildRowDropdown(
                "Color :",
                "Select Color",
                colorList,
                selectedColor,
                    (val) {
                  setState(() {
                    selectedColor = val;
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
              const SizedBox(height: 20),
              buildRowTextField(
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
                onChanged: (_) {}, // 👈 keeps it editable but does nothing
                isNumeric: false,
              ),
              const SizedBox(height: 20),
              buildRowTextField(
                "Tarpaulin Condition:",
                "Intact",
                TarpaulinConditionController,
                onChanged: (_) {}, // 👈 keeps it editable but does nothing
                isNumeric: false,
                readOnly: true,
              ),
              const SizedBox(height: 20),
              buildRowTextField(
                "Sender Remarks:",
                "Enter Sender Remarks",
                SenderRemarksController,
                onChanged: (_) {}, // 👈 keeps it editable but does nothing
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
                    selectedUserId =
                        usersDataMap[val] ?? ""; // ✅ Now stores person_id
                    debugPrint(
                        "Selected User = $selectedusers → ID = $selectedUserId");
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
                    final dt = DateTime(now.year, now.month, now.day,
                        pickedTime.hour, pickedTime.minute);
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
                            Icon(Icons.add_circle,
                                color: Colors.blue, size: 20), // small + icon
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
                          Icon(Icons.remove_circle,
                              color: Colors.red, size: 20), // small - icon
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
                          Icon(Icons.check_circle,
                              color: Colors.green, size: 20), // small tick icon
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
                              icon: const Icon(Icons.remove_circle,
                                  color: Colors.red),
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
                              hintStyle:
                              TextStyle(fontSize: 14, color: Colors.grey),
                              border: InputBorder.none,
                              contentPadding:
                              EdgeInsets.symmetric(horizontal: 12),
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
                              hintStyle:
                              TextStyle(fontSize: 14, color: Colors.grey),
                              border: InputBorder.none,
                              contentPadding:
                              EdgeInsets.symmetric(horizontal: 12),
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
              // Show existing server images
              // 🔹 Show existing server images
              if (serverImages.isNotEmpty) ...[
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: serverImages.map((imgUrl) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imgUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () async {
                              // Only call delete function, let it update UI
                              await deleteSealImage(imgUrl);
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black54,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],


              const SizedBox(height: 20),

              // 🔹 Show newly added local images
              if (_images.isNotEmpty) ...[
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _images.map((img) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            img,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
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
                              icon: const Icon(Icons.close, size: 18, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _images.remove(img);
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                width: 200,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    Colors.blueGrey, // 🔹 Grey background
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
