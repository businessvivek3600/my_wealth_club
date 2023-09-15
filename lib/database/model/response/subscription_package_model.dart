class SubscriptionPackage {
  String? id;
  String? name;
  String? packageId;
  String? amount;
  String? offerPrice;
  String? joiningFee;
  String? pv;
  String? productId;
  String? joiningId;
  String? capping;
  String? status;
  String? image;
  String? priceId;

  SubscriptionPackage(
      {this.id,
      this.name,
      this.packageId,
      this.amount,
      this.offerPrice,
      this.joiningFee,
      this.pv,
      this.productId,
      this.joiningId,
      this.capping,
      this.status,
      this.image});

  SubscriptionPackage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    packageId = json['package_id'];
    amount = json['amount'];
    offerPrice = json['offer_price'];
    joiningFee = json['joining_fee'];
    pv = json['pv'];
    productId = json['product_id'];
    joiningId = json['joining_id'];
    capping = json['capping'];
    status = json['status'];
    image = json['image'];
    priceId = json['price_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['package_id'] = this.packageId;
    data['amount'] = this.amount;
    data['offer_price'] = this.offerPrice;
    data['joining_fee'] = this.joiningFee;
    data['pv'] = this.pv;
    data['product_id'] = this.productId;
    data['joining_id'] = this.joiningId;
    data['capping'] = this.capping;
    data['status'] = this.status;
    data['image'] = this.image;
    data['price_id'] = this.priceId;
    return data;
  }
}
