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
  String code;

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
  String getResponseCode() {
    // TODO: implement getResponseCode
    return this.message;
  }

  @override
  String getResponseMessage() {
    // TODO: implement getResponseMessage
    return this.code;
  }
}

/// PaymentError is for payment specific errors, unlike client errors and network errors
/// Errors such as response error and etc.
class PaymentError implements Response {
  String message;
  String code;

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
      PaymentError.fromMap(json.decode(source));

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
  String getResponseCode() {
    // TODO: implement getResponseCode
    return this.code;
  }

  @override
  String getResponseMessage() {
    // TODO: implement getResponseMessage
    return this.code;
  }
}

/// [Successful] is noebs successful response
class Successful implements Response {
  String message;
  String code;
  String pubKey;

  Successful({
    this.message,
    this.code,
    this.pubKey,
  });

  factory Successful.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Successful(
        message: map['responseMessage'],
        code: map['responseCode'],
        pubKey: map["pubKeyValue"] ?? "");
  }

  factory Successful.fromJson(String source) =>
      Successful.fromMap(json.decode(source));

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
  String getResponseCode() {
    // TODO: implement getResponseCode
    return code;
  }

  @override
  String getResponseMessage() {
    // TODO: implement getResponseMessage
    return message;
  }
}

abstract class Response {
  bool IsSuccessfull();
  bool IsError();
  bool IsPaymentError();
  String getResponseMessage();
  String getResponseCode();
}