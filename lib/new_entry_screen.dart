import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'entry.dart';

class NewEntryScreen extends StatelessWidget {
  const NewEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Entry"),
      ),
      body: const NewEntryScreenBody(),
    );
  }
}

class NewEntryScreenBody extends StatefulWidget {
  const NewEntryScreenBody({super.key});

  @override
  State<NewEntryScreenBody> createState() => _NewEntryScreenBodyState();
}

class _NewEntryScreenBodyState extends State<NewEntryScreenBody> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _costController = TextEditingController();
  EntryType _entryType = EntryType.expense;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: "Title"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a title";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: "Description"),
                ),
                TextFormField(
                  controller: _costController,
                  decoration: const InputDecoration(labelText: "Amount"),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a cost";
                    }
                    if (double.tryParse(value) == null) {
                      return "Please enter a valid number";
                    }
                    return null;
                  },
                ),
                RadioListTile<EntryType>(
                  title: const Text("Expense"),
                  value: EntryType.expense,
                  groupValue: _entryType,
                  onChanged: (value) {
                    setState(() {
                      _entryType = value!;
                    });
                  },
                ),
                RadioListTile<EntryType>(
                  title: const Text("Income"),
                  value: EntryType.income,
                  groupValue: _entryType,
                  onChanged: (value) {
                    setState(() {
                      _entryType = value!;
                    });
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final entry = Entry(
                        title: _titleController.text,
                        description: _descriptionController.text,
                        amount: double.parse(_costController.text),
                        type: _entryType,
                      );

                      Navigator.of(context).pop(entry);
                    }
                  },
                  child: const Text("Save"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
