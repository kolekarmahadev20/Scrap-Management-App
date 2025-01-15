import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../AppClass/AppDrawer.dart';
import '../AppClass/appBar.dart';
import '../URL_CONSTANT.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

import 'Buyer_DomInterForm.dart';


class Buyer_Form extends StatefulWidget {
  @override
  _Buyer_FormState createState() => _Buyer_FormState();
}

class _Buyer_FormState extends State<Buyer_Form> {

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      initialIndex: 0,
      child: Scaffold(
        drawer: AppDrawer(currentPage: 0),
        appBar: CustomAppBar(),
        body: Container(
          color:Colors.white,
          width:double.infinity,
          height:double.infinity,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Buyer",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const TabBar(
                isScrollable: true, // Makes the tabs scrollable
                tabs: [
                  Tab(text: "Domestic Details"),
                  Tab(text: "International Details"),
                ],
              ),
              Expanded(
                child:TabBarView(
                  children: [
                    Buyer_DomInterForm(details : "Add Domestic Details"),
                    Buyer_DomInterForm(details : "Add International Details" ),
                  ],
                ),
              ),
            ],
          ),
        ),


      ),
    );
  }

}
