import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'entry.dart';
import 'textured_container.dart';

class Summary extends StatelessWidget {
  const Summary({super.key});

  @override
  Widget build(BuildContext context) {
    if (Provider.of<GlobalStates>(context).loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final balance = Provider.of<GlobalStates>(context).balance!;
    return Card(
      color: balance >= 0
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.error,
      child: TexturedContainer(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Your Balance",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                    ),
                    Text(
                      currency.format(balance),
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const AdjustBalance(),
            ],
          ),
        ),
      ),
    );
  }
}

class AdjustBalance extends StatefulWidget {
  const AdjustBalance({super.key});

  @override
  State<AdjustBalance> createState() => _AdjustBalanceState();
}

class _AdjustBalanceState extends State<AdjustBalance> {
  var _editing = false;
  final balanceController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: const TextSelectionThemeData(
            cursorColor: Colors.white,
            selectionColor: Color.fromARGB(128, 255, 255, 255),
            selectionHandleColor: Colors.white),
      ),
      child: Container(
        height: 70,
        alignment: Alignment.bottomRight,
        child: _editing
            ? AdjustBalanceEditing(
                controller: balanceController,
                done: () {
                  final newBalance = double.tryParse(balanceController.text);
                  if (newBalance != null) {
                    Provider.of<GlobalStates>(context, listen: false).balance =
                        newBalance;
                  }
                  setState(() {
                    _editing = false;
                  });
                },
                nairaStyle: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
              )
            : ElevatedButton(
                onPressed: () => setState(() {
                  _editing = true;
                  balanceController.text =
                      '${Provider.of<GlobalStates>(context, listen: false).balance}';
                  balanceController.selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: balanceController.text.length);
                }),
                child: const Text("Adjust balance >"),
              ),
      ),
    );
  }
}

class AdjustBalanceEditing extends StatelessWidget {
  final TextEditingController controller;
  final void Function() done;
  final TextStyle? nairaStyle;

  const AdjustBalanceEditing(
      {required this.controller,
      required this.done,
      this.nairaStyle,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.white,
          selectionColor: Color.fromARGB(128, 255, 255, 255),
          selectionHandleColor: Colors.white,
        ),
      ),
      child: Row(
        children: [
          Text('₦', style: nairaStyle),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              autofocus: true,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.-]')),
              ],
              decoration: const InputDecoration(
                hintText: 'Enter new balance',
                hintStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              onSubmitted: (_) {
                done();
              },
            ),
          ),
          IconButton(
            onPressed: done,
            icon: const Icon(Icons.check),
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
