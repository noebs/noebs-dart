library noebs;

import 'package:http/http.dart' as http;
import "package:ipin/ipin.dart" as noebsIpin;
import 'package:uuid/uuid.dart';

import 'package:noebs/types.dart';

class Noebs {
  String pan;
  String ipin;
  String expDate;
  String pubKey;
  String apiKey;
  String ipinBlock;
  String uuid;
  String serviceProviderId;

  Noebs({this.apiKey, this.pan, this.expDate, this.ipin}) {
    uuid = Uuid().v4();
  }

  /// initalizes and creates a new payment request. Also caches keys and handle
  /// the necessary encryption
  init() async {
    final req = new Payment(
        apiKey: apiKey,
        expDate: expDate,
        ipin: ipin,
        pan: pan,
        uuid: Uuid().v4());

    final res = await _getKey(req, "key");
    if (res is Successful) {
      // handle the other cases here...
      pubKey = res.pubKey;
    }
  }

  /// [specialPayment] is used to perform online purchase.
  /// the callee should check for Response and handle errors accordingly.
  Future<Response> specialPayment(double amount) async {
    final id = Uuid().v4();

    ipinBlock =
        noebsIpin.Ipin(clearIpin: ipin, pubKey: pubKey, uuid: uuid).encrypt();

    final pay = new Payment(
        apiKey: apiKey,
        expDate: expDate,
        ipin: ipinBlock,
        pan: pan,
        uuid: id,
        tranAmount: amount,
        serviceProviderId: "12345678",
        currencyCode: "SDG");
    final req = await _getKey(pay, "purchase");
    return req;
  }

  /// [cashout] performs a card to card transfer to [toCard]
  Future<Response> cashout(double amount, String toCard) async {
    final id = Uuid().v4();

    ipinBlock =
        noebsIpin.Ipin(clearIpin: ipin, pubKey: pubKey, uuid: uuid).encrypt();

    final pay = new Payment(
        apiKey: apiKey,
        expDate: expDate,
        ipin: ipinBlock,
        pan: pan,
        uuid: id,
        tranAmount: amount,
        toCard: toCard,
        currencyCode: "SDG");
    final req = await _getKey(pay, "p2p");

    return req;
  }

  Future<Response> _getKey(Payment p, String uri) async {
    final req = p.toJson();
    final res = await http.post("https://beta.soluspay.net/api/v1/$uri",
        body: req, headers: {"content-type": "application/json"});
    if (res.statusCode == 200) {
      return Successful.fromJson(res.body);
    } else if (res.statusCode == 400) {
      return Error.fromJson(res.body);
    } else if (res.statusCode == 502) {
      return PaymentError.fromJson(res.body);
    } else {
      return Error(code: "Exception", message: res.body);
    }
  }
}
