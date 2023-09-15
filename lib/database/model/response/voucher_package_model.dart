class VoucherPackageModel {
  String? id;
  String? currency;
  String? saleType;
  String? packageId;
  String? name;
  String? packAmt;
  String? amount;
  String? productId;
  String? joiningId;
  String? status;
  String? image;
  String? giftImg;

  VoucherPackageModel(
      {this.id,
        this.currency,
        this.saleType,
        this.packageId,
        this.name,
        this.packAmt,
        this.amount,
        this.productId,
        this.joiningId,
        this.status,
        this.image,
        this.giftImg});

  VoucherPackageModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    currency = json['currency'];
    saleType = json['sale_type'];
    packageId = json['package_id'];
    name = json['name'];
    packAmt = json['pack_amt'];
    amount = json['amount'];
    productId = json['product_id'];
    joiningId = json['joining_id'];
    status = json['status'];
    image = json['image'];
    giftImg = json['gift_img'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['currency'] = this.currency;
    data['sale_type'] = this.saleType;
    data['package_id'] = this.packageId;
    data['name'] = this.name;
    data['pack_amt'] = this.packAmt;
    data['amount'] = this.amount;
    data['product_id'] = this.productId;
    data['joining_id'] = this.joiningId;
    data['status'] = this.status;
    data['image'] = this.image;
    data['gift_img'] = this.giftImg;
    return data;
  }
}
