class DashboardAlert {
  String? text;
  String? link;

  DashboardAlert({this.text, this.link});

  DashboardAlert.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    link = json['link'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['text'] = this.text;
    data['link'] = this.link;
    return data;
  }
}
