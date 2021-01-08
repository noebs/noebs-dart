# noebs

A simple way to integrate with noebs apis and add payment to your applications.


### How to use noebs dart sdk


```dart
import 'package:noebs/noebs.dart';
import 'package:noebs/types.dart';

final payment = Noebs(
    apiKey: "1233232",
    pan: "912341234421234112",
    ipin: "1234",
    expDate: "2402",
    client: client);
    
// payment.client = client;

//TODO fix the ipin block shit
final i = await payment.init();

if (i is Successful) {
    // successful transaction
}else if (i is PaymentError) {
    // process payment errors here
    print(i.getErrorMessage());
}

// you can also make a new payment request, through the same api

final payment = Noebs(
    apiKey: "1233232",
    pan: "912341234421234112",
    ipin: "1234",
    expDate: "2402",
    client: client);

final i = await payment.init() // initiale the library here

final res = await payment.specialPayment(32.32); 

// check and handle errors here

```


For more information go to [our api docs website](https://docs.noebs.dev). 