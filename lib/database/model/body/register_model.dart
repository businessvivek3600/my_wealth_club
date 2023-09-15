class RegisterModel {
  String? device_id;
  String? username;
  String? email;
  String? password;
  String? fName;
  String? lName;
  String? phone;
  String? spassword;
  String? confirm_password;
  String? sponser_username;
  String? placement_username;
  String? country_code;

  RegisterModel({
    this.device_id,
    this.username,
    this.email,
    this.password,
    this.fName,
    this.lName,
    this.phone,
    this.spassword,
    this.confirm_password,
    this.sponser_username,
    this.placement_username,
    this.country_code,
  });

  RegisterModel.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    email = json['customer_email'];
    fName = json['first_name'];
    lName = json['last_name'];
    spassword = json['spassword'];
    confirm_password = json['confirm_password'];
    phone = json['customer_mobile'];
    email = json['customer_email'];
    sponser_username = json['sponser_username'];
    placement_username = json['placement_username'];
    country_code = json['country_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['device_id'] = this.device_id;
    data['customer_email'] = this.email;
    data['username'] = this.username;
    data['spassword'] = this.password;
    data['first_name'] = this.fName;
    data['last_name'] = this.lName;
    data['customer_mobile'] = this.phone;
    data['spassword'] = this.spassword;
    data['confirm_password'] = this.confirm_password;
    data['sponser_username'] = this.sponser_username;
    data['placement_username'] = this.placement_username;
    data['country_code'] = this.country_code ?? '';
    return data;
  }
}
