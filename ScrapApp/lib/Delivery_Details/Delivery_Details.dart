import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scrapapp/AppClass/AppDrawer.dart';
import 'package:scrapapp/AppClass/appBar.dart';
import '../URL_CONSTANT.dart';



class SealDeliveryDetails extends StatefulWidget {
  final int currentPage;
  SealDeliveryDetails({required this.currentPage});
  @override
  SealDeliveryDetailsState createState() => SealDeliveryDetailsState();
}

class SealDeliveryDetailsState extends State<SealDeliveryDetails> {
  List<dynamic> deliveryNotes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDeliveryNotes();
  }

  Future<void> fetchDeliveryNotes() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();

    final uuid = prefs.getString("uuid") ?? "";
    final userId = prefs.getString("username") ?? "";
    final password = prefs.getString("password") ?? "";
    final userType = prefs.getString("userType") ?? "";

    print("🔑 Using credentials:");
    print("uuid=$uuid, userId=$userId, password=$password, userType=$userType");

    final url = Uri.parse(
      "${URL}get_seal_delivery_data",
    );

    final response = await http.post(url, body: {
      "uuid": uuid,
      "user_id": userId,
      "user_pass": password,
      "user_type": userType,
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data["status"] == "1") {
        setState(() {
          deliveryNotes = data["user_data"];
          deliveryNotes.sort((a, b) => int.parse(b["seal_delivery_note_id"].toString())
              .compareTo(int.parse(a["seal_delivery_note_id"].toString())));
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print("❌ API returned status 0 or error: ${data['msg']}");
      }
    } else {
      setState(() {
        isLoading = false;
      });
      print("❌ HTTP error: ${response.statusCode}");
    }
  }

  Future<void> updateDeliveryNote(String sealDeliveryNoteId, String receiveDate,
      String receiveBags) async {
    final prefs = await SharedPreferences.getInstance();

    final uuid = prefs.getString("uuid") ?? "";
    final userId = prefs.getString("username") ?? "";
    final password = prefs.getString("password") ?? "";
    final userType = prefs.getString("userType") ?? "";

    final url = Uri.parse(
      "${URL}update_delivery_data",
    );

    final response = await http.post(url, body: {
      "uuid": uuid,
      "user_id": userId,
      "user_pass": password,
      "user_type": userType,
      "seal_delivery_note_id": sealDeliveryNoteId,
      "recieve_date": receiveDate,
      "receive_bags": receiveBags,
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data["status"] == "1") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(
              data["msg"].toString(), style: TextStyle(color: Colors.white))),
        );

        // refresh list
        fetchDeliveryNotes();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(
              data["msg"].toString(), style: TextStyle(color: Colors.red))),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("HTTP Error: ${response.statusCode}",
            style: TextStyle(color: Colors.red))),
      );
    }
  }


  void openFileInApp(String url) {
    final cleanedUrl = url.replaceAll("./", "");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            Scaffold(
              appBar: AppBar(
                title: Text("Delivery Note",style: TextStyle(color:Colors.white)),
                backgroundColor: Colors.blueGrey[700],
              ),
              body: InteractiveViewer(
                child: Image.network(
                  cleanedUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      Text("Failed to load image"),
                ),
              ),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(currentPage: widget.currentPage),
      appBar: CustomAppBar(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Title at top-left corner
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              "View Delivery Notes",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          // 🔹 Expanded List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: deliveryNotes.length,
              itemBuilder: (context, index) {
                final note = deliveryNotes[index];
                final rows = [
                  ["Send on", note["send_date"]],
                  ["Sender Name", note["sender_name"]],
                  ["Seal Start", note["seal_start"]],
                  ["Seal End", note["seal_end"]],
                  ["Send via", note["mode_of_transport"]],
                  ["Transporter Name", note["transport_name"]],
                  ["Ref No", note["ref_no"]],
                  ["Received Date", note["receive_date"]],
                  ["Received Bags", note["receive_bags"]],
                  ["Received By", note["receive_by"]],
                ];

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔹 Location header
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey[500],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Location: ${note['location_name'] ?? ''}",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.white),
                                onPressed: () {
                                  // 🔹 Controllers for dialog fields
                                  TextEditingController dateCtrl =
                                  TextEditingController(
                                    text: note["receive_date"] ?? "",
                                  );
                                  TextEditingController bagsCtrl =
                                  TextEditingController(
                                    text: note["receive_bags"]
                                        ?.toString() ??
                                        "0",
                                  );

                                  showDialog(
                                    context: context,
                                    builder: (context) =>
                                        AlertDialog(
                                          title:
                                          Text("Update Delivery Note"),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              // 🔹 Receive Date with DatePicker
                                              TextField(
                                                controller: dateCtrl,
                                                readOnly: true,
                                                decoration: InputDecoration(
                                                  labelText:
                                                  "Receive Date (dd-MM-yyyy)",
                                                  suffixIcon: Icon(
                                                      Icons.calendar_today),
                                                ),
                                                onTap: () async {
                                                  DateTime initialDate =
                                                  DateTime.now();

                                                  // try to parse existing date
                                                  if (note["receive_date"] !=
                                                      null &&
                                                      note["receive_date"]
                                                          .toString()
                                                          .contains("-")) {
                                                    try {
                                                      final parts = note[
                                                      "receive_date"]
                                                          .toString()
                                                          .split("-");
                                                      if (parts.length == 3) {
                                                        initialDate = DateTime(
                                                          int.parse(parts[2]),
                                                          int.parse(parts[1]),
                                                          int.parse(parts[0]),
                                                        );
                                                      }
                                                    } catch (_) {}
                                                  }

                                                  DateTime? pickedDate =
                                                  await showDatePicker(
                                                    context: context,
                                                    initialDate: initialDate,
                                                    firstDate: DateTime(2000),
                                                    lastDate: DateTime(2100),
                                                  );
                                                  if (pickedDate != null) {
                                                    String formattedDate =
                                                        "${pickedDate.day
                                                        .toString().padLeft(
                                                        2, '0')}-${pickedDate
                                                        .month.toString()
                                                        .padLeft(
                                                        2, '0')}-${pickedDate
                                                        .year}";
                                                    dateCtrl.text =
                                                        formattedDate;
                                                  }
                                                },
                                              ),

                                              // 🔹 Receive Bags
                                              TextField(
                                                controller: bagsCtrl,
                                                keyboardType:
                                                TextInputType.number,
                                                decoration: InputDecoration(
                                                    labelText: "Receive Bags"),
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: Text("Cancel"),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                updateDeliveryNote(
                                                  note["seal_delivery_note_id"]
                                                      .toString(),
                                                  dateCtrl.text.isEmpty
                                                      ? "null"
                                                      : dateCtrl.text,
                                                  bagsCtrl.text.isEmpty
                                                      ? "0"
                                                      : bagsCtrl.text,
                                                );
                                              },
                                              child: Text("Update"),
                                            ),
                                          ],
                                        ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12),

                        // 🔹 Alternate background rows
                        ...rows
                            .asMap()
                            .entries
                            .map((entry) {
                          int i = entry.key;
                          var row = entry.value;
                          return Container(
                            width: double.infinity,
                            color: i % 2 == 0
                                ? Colors.white
                                : Colors.grey.shade200,
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 12),
                            child: Text(
                              "${row[0]}: ${row[1] ?? '-'}",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          );
                        }).toList(),

                        SizedBox(height: 10),

                        // 🔹 View File button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey[700],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          onPressed: () =>
                              openFileInApp(note["scan_copy"].toString()),
                          child: Text(
                            "View File",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),

                        SizedBox(height: 8),

                        // 🔹 Bags Difference
                        Text(
                          "Bags Difference: ${note['difference_bags'] == '0'
                              ? 'No missing bags'
                              : note['difference_bags']}",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
