class VendorData {
  final String srNo;
  final String name;
  final String email;
  final String phone;
  final String addressLine1;
  final String addressLine2;
  final String state;
  final String country;
  final String postalCode;
  final String gstNumber;
  final String remarks;
  final String contactPerson;
  final String Vendor_id;
  final String Active;



  VendorData({
    required this.srNo,
    required this.name,
    required this.email,
    required this.phone,
    required this.addressLine1,
    required this.addressLine2,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.gstNumber,
    required this.remarks,
    required this.contactPerson,
    required this.Vendor_id,
    required this.Active,


  });

  // Factory method to create SealData from JSON
  factory VendorData.fromJson(Map<String, dynamic> json) {
    return VendorData(
      srNo: json['srNo'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      addressLine1: json['addressLine1'],
      addressLine2: json['addressLine2'],
      state: json['state'],
      country: json['country'],
      postalCode: json['postalCode'],
      gstNumber: json['gstNumber'],
      remarks: json['remarks'],
      contactPerson: json['contactPerson'],
      Vendor_id: json['Vendor_id'],
      Active: json['Active'],


    );
  }
}
