class EventTicketsRequests {
  String? id;
  String? orderId;
  String? customerId;
  String? username;
  String? customerName;
  String? name;
  String? image;
  String? amount;
  String? bizz;
  String? member;
  String? paymentType;
  String? transactionId;
  String? paymentUrl;
  String? paymentStatus;
  String? paypalArr;
  String? status;
  String? createdAt;

  EventTicketsRequests(
      {this.id,
      this.orderId,
      this.customerId,
      this.username,
      this.customerName,
      this.name,
      this.image,
      this.amount,
      this.bizz,
      this.member,
      this.paymentType,
      this.transactionId,
      this.paymentUrl,
      this.paymentStatus,
      this.paypalArr,
      this.status,
      this.createdAt});

  EventTicketsRequests.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    customerId = json['customer_id'];
    username = json['username'];
    customerName = json['customer_name'];
    name = json['name'];
    image = json['image'];
    amount = json['amount'];
    bizz = json['bizz'];
    member = json['member'];
    paymentType = json['payment_type'];
    transactionId = json['transaction_id'];
    paymentUrl = json['payment_url'];
    paymentStatus = json['payment_status'];
    paypalArr = json['paypal_arr'];
    status = json['status'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['order_id'] = this.orderId;
    data['customer_id'] = this.customerId;
    data['username'] = this.username;
    data['customer_name'] = this.customerName;
    data['name'] = this.name;
    data['image'] = this.image;
    data['amount'] = this.amount;
    data['bizz'] = this.bizz;
    data['member'] = this.member;
    data['payment_type'] = this.paymentType;
    data['transaction_id'] = this.transactionId;
    data['payment_url'] = this.paymentUrl;
    data['payment_status'] = this.paymentStatus;
    data['paypal_arr'] = this.paypalArr;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    return data;
  }
}
