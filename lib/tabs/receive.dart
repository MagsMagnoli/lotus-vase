import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';

import 'package:cashew/constants.dart';
import 'package:cashew/components/calculator_keyboard/keyboard.dart';
import '../viewmodel.dart';
import 'component/payment_amount_display.dart';

class ReceiveTab extends StatelessWidget {
  final ValueNotifier<CalculatorData> keyboardNotifier;

  ReceiveTab({Key key})
      : keyboardNotifier = ValueNotifier<CalculatorData>(
            CalculatorData(amount: 0, function: '')),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<WalletModel>(context);
    if (viewModel.wallet == null) {
      return Container();
    }

    final keys = viewModel.wallet.keys.keys.sublist(0);
    keys.shuffle();

    final keyInfo = keys.firstWhere((keyInfo) =>
        keyInfo.isChange == false && keyInfo.isDeprecated == false);
    final strAddress = keyInfo.address.toCashAddress();
    final _controller = TextEditingController(text: strAddress);

    final createAddressUri = (CalculatorData data) {
      if (data.amount == 0) {
        return strAddress;
      }
      // Can't mutate the URI, so need a way to add query strings.
      final parsedAddress = Uri.parse(strAddress);
      return Uri(
          scheme: parsedAddress.scheme,
          path: parsedAddress.path,
          queryParameters: {'amount': data.amount.toString()}).toString();
    };

    keyboardNotifier.addListener(() {
      _controller.text = createAddressUri(keyboardNotifier.value);
    });

    final manualCard = Card(
      child: ValueListenableBuilder(
          valueListenable: keyboardNotifier,
          builder: (context, CalculatorData balance, child) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _controller,
                        readOnly: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Container(
                      height: 60.0,
                      child: OutlinedButton(
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(
                              text: createAddressUri(balance),
                            ),
                          );

                          Scaffold.of(context).showSnackBar(
                            copiedAd,
                          );
                        },
                        child: Icon(Icons.copy),
                      ),
                    ),
                  ),
                ],
              )),
      elevation: stdElevation,
    );

    final qrCard = Card(
      child: ValueListenableBuilder(
          valueListenable: keyboardNotifier,
          builder: (context, CalculatorData balance, child) => QrImage(
                data: createAddressUri(balance),
                version: QrVersions.auto,
              )),
      elevation: stdElevation,
    );

    final calculatorKeyboard =
        CalculatorKeyboard(dataNotifier: keyboardNotifier, initialValue: '');
    // Confirm Amount button widget writes to global SendModel
    // and then switches to Slide to send button:

    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Receive Funds',
            style: Theme.of(context).textTheme.headline6,
          ),
          Expanded(child: qrCard),
          manualCard,
          ValueListenableBuilder(
              valueListenable: keyboardNotifier,
              builder: (context, CalculatorData balance, child) =>
                  PaymentAmountDisplay(
                      amount: balance.amount.toString(),
                      function: balance.function)),
          calculatorKeyboard,
        ],
      ),
    );
  }
}
