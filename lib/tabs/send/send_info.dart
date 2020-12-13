import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'sendModel.dart';
import '../../wallet/wallet.dart';
import '../../viewmodel.dart';
import '../../bitcoincash/address.dart';
import '../../bitcoincash/transaction/transaction.dart';
import '../../constants.dart';

Future showReceipt(BuildContext context, Transaction transaction) {
  // TODO: Create nice looking receipt dialog.
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Transaction sent'),
          content: Text(transaction.id),
        );
      });
}

Future showError(BuildContext context, String errMessage) {
  // TODO: Create nice looking receipt dialog.
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error sending...'),
          content: Text(errMessage),
        );
      });
}

class SendInfo extends StatelessWidget {
  final ValueNotifier<bool> visible;
  final Wallet wallet;

  SendInfo({this.visible, @required this.wallet});

  void sendButtonClicked(BuildContext context, String address, int amount) {
    final primaryValidation = (amount != null && amount > 0);
    if (!primaryValidation) {
      return;
    }
    // TODO: Need address validation here. Should attach to entry field
    // somehow to indicate the address is bad.
    wallet
        .sendTransaction(Address(address), BigInt.from(amount))
        .then((transaction) => showReceipt(context, transaction))
        .catchError((error) => showError(context, error.toString()));
  }

  @override
  Widget build(context) {
    final balanceNotifier =
        Provider.of<WalletModel>(context, listen: false).balance;
    final viewModel = Provider.of<SendModel>(context, listen: false);

    final addressController =
        TextEditingController(text: viewModel.sendToAddress);

    addressController.addListener(() {
      viewModel.sendToAddress = addressController.text;
    });

    final amountController = TextEditingController(
        text: viewModel.sendAmount == null
            ? ''
            : viewModel.sendAmount.toString());

    amountController.addListener(() {
      viewModel.sendAmount = int.tryParse(amountController.text);
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Card(
              child: Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Balance'),
                      subtitle: const Text('in satoshis'),
                    ),
                  ),
                  Expanded(
                    child: ValueListenableBuilder(
                        valueListenable: balanceNotifier,
                        builder: (context, balance, child) {
                          if (balance == null) {
                            return Text(
                              'Loading...',
                              style: TextStyle(
                                  color: Colors.red.withOpacity(.8),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                            );
                          }
                          return Text.rich(TextSpan(
                            text: '${balance}',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                            children: [
                              TextSpan(
                                text: ' sats',
                                style: TextStyle(
                                    color: Colors.black.withOpacity(.8),
                                    fontSize: 15),
                              ),
                            ],
                          ));
                        }),
                  ),
                ],
              ),
            ),
            Padding(
              padding: stdPadding,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      autocorrect: false,
                      enableInteractiveSelection: true,
                      autofocus: true,
                      toolbarOptions: ToolbarOptions(
                        paste: true,
                        cut: true,
                        copy: true,
                        selectAll: true,
                      ),
                      readOnly: false,
                      focusNode: FocusNode(),
                      controller: addressController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter recipient address',
                      ),
                    ),
                  )
                ],
              ),
            ),
            Row(children: [
              Expanded(
                child: Padding(
                  padding: stdPadding,
                  child: TextField(
                    autocorrect: false,
                    enableInteractiveSelection: true,
                    autofocus: false,
                    toolbarOptions: ToolbarOptions(
                      paste: true,
                      cut: true,
                      copy: true,
                      selectAll: true,
                    ),
                    readOnly: false,
                    focusNode: FocusNode(),
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      suffixText: 'sats',
                      border: OutlineInputBorder(),
                      hintText: 'Enter amount',
                    ),
                  ),
                ),
              ),
              // TODO: This needs to actually do something
              FlatButton(
                onPressed: () {},
                child: Text('Max'),
              )
            ]),
            Row(
              children: [
                Expanded(
                  child: Consumer<SendModel>(
                    builder: (context, viewModel, child) => ElevatedButton(
                      // TODO: we should probably have ValueNotifiable props
                      // specifically for this component
                      // Rather than wiring directly to the global viewmodel
                      onPressed: () {
                        visible.value = false;
                        viewModel.sendAmount = null;
                      },
                      child: Text('Cancel'),
                    ),
                  ),
                ),
                Expanded(
                  child: Consumer<SendModel>(
                    builder: (context, viewModel, child) => ElevatedButton(
                      autofocus: true,
                      // TODO: we should probably have ValueNotifiable props
                      // specifically for this component
                      // Rather than wiring directly to the global viewmodel
                      onPressed: () {
                        sendButtonClicked(
                          context,
                          viewModel.sendToAddress,
                          viewModel.sendAmount,
                        );
                        visible.value = false;
                        viewModel.sendAmount = null;
                      },
                      child: Text('Send'),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
