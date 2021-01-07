import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:noebs/noebs.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:noebs/types.dart';

// Create a MockClient using the Mock class provided by the Mockito package.
// Create new instances of this class in each test.
class MockClient extends Mock implements http.Client {}

main() {
  group('fetchPost', () {
    test('key value', () async {
      final client = MockClient();

      when(client.post("https://beta.soluspay.net/api/v1/key")).thenAnswer(
          (_) async => http.Response(
              '{ "pubKeyValue": "3232", "ebs_response": { "pubKeyValue": "MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBANx4gKYSMv3CrWWsxdPfxDxFvl+Is/0kc1dvMI1yNWDXI3AgdI4127KMUOv7gmwZ6SnRsHX/KAM0IPRe0+Sa0vMCAwEAAQ==", "UUID": "8d77c8d5-4c5b-4c3c-bf83-d7722fc1e444", "responseMessage": "Approved", "responseStatus": "Successful", "responseCode": 0, "tranDateTime": "200222113700" } }',
              200));
      final payment = Noebs(
          apiKey: "1233232",
          pan: "9222081700176714465",
          ipin: "0009",
          expDate: "2203",
          client: client);
      // payment.client = client;

      //TODO fix the ipin block shit
      final i = await payment.init();
      expect(i, isA<Successful>());
      expect(i.getResponseMessage(), "Approved");

      expect(payment.pubKey,
          "MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBANx4gKYSMv3CrWWsxdPfxDxFvl+Is/0kc1dvMI1yNWDXI3AgdI4127KMUOv7gmwZ6SnRsHX/KAM0IPRe0+Sa0vMCAwEAAQ==");

      // Use Mockito to return a successful response when it calls the
      // provided http.Client.
      final b = await payment.balance();

      // expect(b, isA<PaymentError>());
      expect(b.getResponseMessage(), "Approved");
      // final a = b as Successful;
      expect((b as Successful).balance, 1.48);
    });

    test('testing payment err', () async {
      final client = MockClient();

      when(client.post("https://beta.soluspay.net/api/v1/key")).thenAnswer(
          (_) async => http.Response(
              '{ "pubKeyValue": "3232", "ebs_response": { "pubKeyValue": "MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBANx4gKYSMv3CrWWsxdPfxDxFvl+Is/0kc1dvMI1yNWDXI3AgdI4127KMUOv7gmwZ6SnRsHX/KAM0IPRe0+Sa0vMCAwEAAQ==", "UUID": "8d77c8d5-4c5b-4c3c-bf83-d7722fc1e444", "responseMessage": "Approved", "responseStatus": "Successful", "responseCode": 0, "tranDateTime": "200222113700" } }',
              200));

      final payment = Noebs(
          apiKey: "1233232",
          pan: "9222081700176714465",
          ipin: "0009",
          expDate: "2203",
          client: client);

      await payment.init();
      // payment.init();

      // await payment.init();
      // expect(await payment.balance(), isA<PaymentError>());
      // expect(payment.ipin, "2222");

      // expect(payment.pubKey,
      //     "MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBANx4gKYSMv3CrWWsxdPfxDxFvl+Is/0kc1dvMI1yNWDXI3AgdI4127KMUOv7gmwZ6SnRsHX/KAM0IPRe0+Sa0vMCAwEAAQ==");

      // Use Mockito to return a successful response when it calls the
      // provided http.Client.

      // expect(await payment.balance(), isA<Response>());
    });

    // new test
    test('returns a Post if the http call completes successfully', () async {
      final client = MockClient();

      final payment = Noebs(
          apiKey: "1233232",
          pan: "9222081700176714465",
          ipin: "0009",
          expDate: "2203",
          client: client);
      payment.init();

      // Use Mockito to return a successful response when it calls the
      // provided http.Client.
      when(client.post("https://beta.soluspay.net/api/v1/balance")).thenAnswer(
          (_) async => http.Response(
              '{ "ebs_response": { "pubKeyValue": "MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBANx4gKYSMv3CrWWsxdPfxDxFvl+Is/0kc1dvMI1yNWDXI3AgdI4127KMUOv7gmwZ6SnRsHX/KAM0IPRe0+Sa0vMCAwEAAQ==", "UUID": "8d77c8d5-4c5b-4c3c-bf83-d7722fc1e444", "responseMessage": "Approved", "responseStatus": "Successful", "responseCode": 0, "tranDateTime": "200222113700" } }',
              200));

      expect(await payment.balance(), isA<Response>());
    });
  });
}
