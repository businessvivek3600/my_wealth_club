import 'package:mycarclub/database/functions.dart';

class MWC_Content {
  Cancellation? cancellation;
  Cancellation? privacy;
  Cancellation? termCondition;
  Cancellation? returnPolicy;

  MWC_Content(
      {this.cancellation, this.privacy, this.termCondition, this.returnPolicy});

  MWC_Content.fromJson(Map<String, dynamic> json) {
    cancellation = json['cancellation'] != null
        ? new Cancellation.fromJson(json['cancellation'])
        : null;
    privacy = json['privacy'] != null
        ? new Cancellation.fromJson(json['privacy'])
        : null;
    termCondition = json['term_condition'] != null
        ? new Cancellation.fromJson(json['term_condition'])
        : null;
    returnPolicy = json['return'] != null
        ? new Cancellation.fromJson(json['return'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.cancellation != null) {
      data['cancellation'] = this.cancellation!.toJson();
    }
    if (this.privacy != null) {
      data['privacy'] = this.privacy!.toJson();
    }
    if (this.termCondition != null) {
      data['term_condition'] = this.termCondition!.toJson();
    }
    if (this.returnPolicy != null) {
      data['return'] = this.returnPolicy!.toJson();
    }
    return data;
  }
}
// {
//   'cancellation':{},
//   'privacy':{},
//   'term_condition':{},
//   'return':{}
// }

class Cancellation {
  String? linkPageId;
  String? pageId;
  String? languageId;
  String? headlines;
  String? image;
  String? details;
  String? status;

  Cancellation(
      {this.linkPageId,
      this.pageId,
      this.languageId,
      this.headlines,
      this.image,
      this.details,
      this.status});

  Cancellation.fromJson(Map<String, dynamic> json) {
    linkPageId = json['link_page_id'];
    pageId = json['page_id'];
    languageId = json['language_id'];
    headlines = parseHtmlString(json['headlines'] ?? '');
    image = json['image'];
    details = json['details'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['link_page_id'] = this.linkPageId;
    data['page_id'] = this.pageId;
    data['language_id'] = this.languageId;
    data['headlines'] = this.headlines;
    data['image'] = this.image;
    data['details'] = this.details;
    data['status'] = this.status;
    return data;
  }
}
