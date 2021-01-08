import 'dart:convert';
import 'package:intl/intl.dart';

/// A Payment class is the request body for all noebs fields
class Payment {
  String pan;
  String ipin;
  String expDate;
  String apiKey;
  double tranAmount;
  String currencyCode;
  String serviceProviderId;
  String toCard;
  String uuid;
  String tranDateTime;
  String applicationId;
  Payment(
      {this.apiKey,
      this.pan,
      this.ipin,
      this.expDate,
      this.tranAmount,
      this.serviceProviderId,
      this.currencyCode,
      this.tranDateTime,
      this.toCard,
      this.uuid}) {
    this.applicationId = "ACTSCon";
    this.tranDateTime = _timeFormatter();
  }

  String _timeFormatter() {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('ddMMyyHHmmss');
    final String formatted = formatter.format(now);
    return formatted;
  }

  Map<String, dynamic> toMap() {
    return {
      'PAN': pan,
      'IPIN': ipin,
      'expDate': expDate,
      'tranAmount': tranAmount,
      'currencyCode': currencyCode,
      'applicationId': applicationId,
      "UUID": uuid,
      "tranDateTime": tranDateTime,
      "toCard": toCard,
      "serviceProviderId": serviceProviderId
    };
  }

  String toJson() => json.encode(toMap());
}

/// [Error] represents any generic noebs error
class Error implements Response {
  String message;
  int code;

  Error({
    this.message,
    this.code,
  });

  factory Error.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Error(
      message: map['message'],
      code: map['code'],
    );
  }

  factory Error.fromJson(String source) => Error.fromMap(json.decode(source));

  @override
  bool IsError() {
    // TODO: implement IsError
    return true;
  }

  @override
  bool IsPaymentError() {
    // TODO: implement IsPaymentError
    return false;
  }

  @override
  bool IsSuccessfull() {
    // TODO: implement IsSuccessfull
    return false;
  }

  @override
  int getResponseCode() {
    // TODO: implement getResponseCode
    return this.code;
  }

  @override
  String getResponseMessage() {
    // TODO: implement getResponseMessage
    return this.message;
  }
}

/// [PaymentError] is for payment specific errors, unlike client errors and network errors
/// Errors such as response error and etc.
class PaymentError implements Response {
  String message;
  int code;

  PaymentError({
    this.message,
    this.code,
  });

  factory PaymentError.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return PaymentError(
      message: map['responseMessage'],
      code: map['responseCode'],
    );
  }

  factory PaymentError.fromJson(String source) =>
      PaymentError.fromMap(json.decode(source)["details"]);

  @override
  bool IsError() {
    // TODO: implement IsError
    return true;
  }

  @override
  bool IsPaymentError() {
    // TODO: implement IsPaymentError
    return true;
  }

  @override
  bool IsSuccessfull() {
    // TODO: implement IsSuccessfull
    return false;
  }

  @override
  int getResponseCode() {
    // TODO: implement getResponseCode
    return this.code;
  }

  @override
  String getResponseMessage() {
    // TODO: implement getResponseMessage
    return this.message;
  }
}

/// [Successful] is noebs successful response
class Successful implements Response {
  String message;
  int code;
  String pubKey;
  double balance;

  Successful({this.message, this.code, this.pubKey, this.balance});

  factory Successful.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
    double available = 0;

    if (map.containsKey("balance")) {
      available = map["balance"]["available"];
    }
    return Successful(
        message: map['responseMessage'],
        code: map['responseCode'],
        pubKey: map["pubKeyValue"] ?? "",
        balance: available);
  }

  factory Successful.fromJson(String source) =>
      Successful.fromMap(json.decode(source)["ebs_response"]);

  @override
  bool IsError() {
    // TODO: implement IsError
    return false;
  }

  @override
  bool IsPaymentError() {
    // TODO: implement IsPaymentError
    return false;
  }

  @override
  bool IsSuccessfull() {
    // TODO: implement IsSuccessfull
    return true;
  }

  @override
  int getResponseCode() {
    // TODO: implement getResponseCode
    return code;
  }

  @override
  String getResponseMessage() {
    // TODO: implement getResponseMessage
    return message;
  }
}

/// [Response] is the base interface for all noebs response messages
/// [Response.IsSuccessful] and [Response.IsError] can be used
/// to check for successful responses and failure responses accordingly.
/// [Response.getResponseMessage] is used to get user friendly response messages
/// [Response.getResponseCode] is for a technical info about the response.
/// means successful transactions.
abstract class Response {
  bool IsSuccessfull();
  bool IsError();
  bool IsPaymentError();
  String getResponseMessage();
  int getResponseCode();
}
