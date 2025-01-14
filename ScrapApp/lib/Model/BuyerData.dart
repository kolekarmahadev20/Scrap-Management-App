class BuyerData {
  final String srNo;
  final String name;
  final String companyName;
  final String email;
  final String phone;
  final String address;
  final String gstNumber;
  final String entityType;
  final String activeStatus;
  final String businessType;
  final String contactPerson;

  BuyerData({
    required this.srNo,
    required this.name,
    required this.companyName,
    required this.email,
    required this.phone,
    required this.address,
    required this.gstNumber,
    required this.entityType,
    required this.activeStatus,
    required this.businessType,
    required this.contactPerson,
  });

  // Factory method to create SealData from JSON
  factory BuyerData.fromJson(Map<String, dynamic> json) {
    return BuyerData(
      srNo: json['srNo'],
      name: json['name'],
      companyName: json['companyName'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      gstNumber: json['gstNumber'],
      entityType: json['entityType'],
      activeStatus: json['activeStatus'],
      businessType: json['businessType'],
      contactPerson: json['contactPerson'],
      // contactPerson: json['contactPerson'],
      // Vendor_id: json['Vendor_id'],
      // Active: json['Active'],
    );
  }

}
