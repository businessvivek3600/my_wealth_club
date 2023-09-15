class VoucherModel {
  String? id;
  String? epin;
  String? packageType;
  String? packageId;
  String? packageName;
  String? packageAmt;
  String? allotedBy;
  String? usedBy;
  String? block;
  String? note;
  String? createdBy;
  String? createdAt;
  String? updatedAt;

  VoucherModel(
      {this.id,
      this.epin,
      this.packageType,
      this.packageId,
      this.packageName,
      this.packageAmt,
      this.allotedBy,
      this.usedBy,
      this.block,
      this.note,
      this.createdBy,
      this.createdAt,
      this.updatedAt});

  VoucherModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    epin = json['epin'];
    packageType = json['package_type'];
    packageId = json['package_id'];
    packageName = json['package_name'];
    packageAmt = json['package_amt'];
    allotedBy = json['alloted_by'];
    usedBy = json['used_by'];
    block = json['block'];
    note = json['note'];
    createdBy = json['created_by'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['epin'] = this.epin;
    data['package_type'] = this.packageType;
    data['package_id'] = this.packageId;
    data['package_name'] = this.packageName;
    data['package_amt'] = this.packageAmt;
    data['alloted_by'] = this.allotedBy;
    data['used_by'] = this.usedBy;
    data['block'] = this.block;
    data['note'] = this.note;
    data['created_by'] = this.createdBy;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
