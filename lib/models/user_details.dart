class UserDetails {
  String? imgUrl;
  String? firstName;
  String? lastName;
  String? address;
  String? emailId;
  String? mobileNo;

  UserDetails(
      {this.imgUrl,
      this.firstName,
      this.lastName,
      this.address,
      this.emailId,
      this.mobileNo});

  UserDetails.fromJson(Map<String, dynamic> json) {
    this.imgUrl = json["imgUrl"];
    this.firstName = json["firstName"];
    this.lastName = json["lastName"];
    this.address = json["address"];
    this.emailId = json["emailID"];
    this.mobileNo = json["mobileNo"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["imgUrl"] = this.imgUrl;
    data["firstName"] = this.firstName;
    data["lastName"] = this.lastName;
    data["address"] = this.address;
    data["emailID"] = this.emailId;
    data["mobileNo"] = this.mobileNo;
    return data;
  }
}
