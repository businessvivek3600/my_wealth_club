class LoginModel {
  String? device_id;
  String? username;
  String? password;

  LoginModel({
    required this.device_id,
    required this.username,
    required this.password,
  });

  LoginModel.fromJson(Map<String, dynamic> json) {
    device_id = json['device_id'];
    username = json['username'];
    password = json['password'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['device_id'] = this.device_id;
    data['username'] = this.username;
    data['password'] = this.password;
    return data;
  }
}
