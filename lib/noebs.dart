library noebs;

import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import "package:ipin/ipin.dart" as noebsIpin;
import 'package:uuid/uuid.dart';

import 'package:noebs/types.dart';

/// [Noebs] is the main entry to access all noebs service including charging users [Noebs.specialPayment],
/// card transfer and cashouts [Noebs.cashout], and balance inquiry [Noebs.balance], through a simple and direct api.
/// [pan] is the personal account number, or card holder atm's card number, usually it is printed out in the card
/// it's usually between 16 or 19 digit.
/// [pin] or actually ipin is the user's _internet pin_, we process it from the user's entered data and
/// encrypt it there.
/// [expDate] is the card expiration date, in **YYmm** format, or two last of year and month with *0* paddings
/// if not available.
///
/// noebs sdk does all of the heavy lifting, including encryption, retrials, error handling and transactions.
///
/// noebs sdk has three interfaces that the library user needs to be aware of:
/// - [Response]: for successful transactions
/// - [PaymentError]: for payment specific errors (e.g., insufficient funds, etc)
/// - [Error]: for generic errors such as network errors, etc
/// You can get the response message and the response code from each one using [Response.getResponseMessage()], and so on for
/// [Error.getErrorMessage()] and [PaymentError.getPaymentError()].
///
class Noebs {
  String pan;
  String ipin;
  String expDate;
  String pubKey;
  String apiKey;
  String ipinBlock;
  String uuid;
  String serviceProviderId;
  http.Client client;

  Noebs({this.apiKey, this.pan, this.expDate, this.ipin, this.client}) {
    uuid = Uuid().v4();
    client = http.Client();
  }

  /// initalizes and creates a new payment request. Also caches keys and handle
  /// the necessary encryption
  Future<Response> init() async {
    final req = new Payment(
        apiKey: apiKey,
        expDate: expDate,
        ipin: ipin,
        pan: pan,
        uuid: Uuid().v4());

    final res = await _getKey(req, "key", client);
    if (res is Successful) {
      // handle the other cases here...
      pubKey = res.pubKey;
      log(pubKey, name: "pubkey");
    } else {
      log(res.getResponseMessage());
      this.ipin = "22223";
    }
    return res;
  }

  /// [specialPayment] is used to perform online purchase.
  /// the callee should check for Response and handle errors accordingly.
  Future<Response> specialPayment(double amount) async {
    ipinBlock =
        noebsIpin.Ipin(clearIpin: ipin, pubKey: pubKey, uuid: uuid).encrypt();

    final pay = new Payment(
        apiKey: apiKey,
        expDate: expDate,
        ipin: ipinBlock,
        pan: pan,
        uuid: uuid,
        tranAmount: amount,
        serviceProviderId: "12345678",
        currencyCode: "SDG");
    final req = await _getKey(pay, "purchase", this.client);
    return req;
  }

  /// [cashout] performs a card to card transfer to [toCard]
  Future<Response> cashout(double amount, String toCard) async {
    ipinBlock =
        noebsIpin.Ipin(clearIpin: ipin, pubKey: pubKey, uuid: uuid).encrypt();

    final pay = new Payment(
        apiKey: apiKey,
        expDate: expDate,
        ipin: ipinBlock,
        pan: pan,
        uuid: uuid,
        tranAmount: amount,
        toCard: toCard,
        currencyCode: "SDG");

    final req = await _getKey(pay, "p2p", this.client);

    return req;
  }

  /// [balance] make an inquiry about a card's balance
  Future<Response> balance() async {
    ipinBlock =
        noebsIpin.Ipin(clearIpin: ipin, pubKey: pubKey, uuid: uuid).encrypt();

    final pay = new Payment(
        apiKey: apiKey,
        expDate: expDate,
        ipin: ipinBlock,
        pan: pan,
        uuid: uuid,
        currencyCode: "SDG");

    final req = await _getKey(pay, "balance", this.client);
    return req;
  }

  Future<Response> _getKey(Payment p, String uri, http.Client client) async {
    final req = p.toJson();
    final res = await client.post("https://beta.soluspay.net/api/v1/$uri",
        body: req, headers: {"content-type": "application/json"});
    try {
      if (res.statusCode == 200) {
        return Successful.fromJson(res.body);
      } else if (res.statusCode == 400) {
        //FIXME
        return Error.fromJson(res.body);
      } else if (res.statusCode == 502) {
        return PaymentError.fromJson(res.body);
      } else {
        return Error(code: 69, message: res.body);
      }
    } catch (e) {
      log(e.toString(), name: "error_message");
      return Error(code: 69, message: e.toString());
    }
  }
}
