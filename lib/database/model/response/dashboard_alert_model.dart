class DashboardAlert {
  String? info;
  String? action;
  int? status;

  DashboardAlert({this.info, this.action, this.status});

  DashboardAlert.fromJson(Map<String, dynamic> json) {
    info = json['info'];
    action = json['action'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['info'] = this.info;
    data['action'] = this.action;
    data['status'] = this.status;
    return data;
  }
}
