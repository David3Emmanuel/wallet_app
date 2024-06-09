import 'dart:developer';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

final currency = NumberFormat("₦#,##0.00", "en_US");

Future<File> get _localFile async {
  // throw UnimplementedError();
  final directory = await getApplicationDocumentsDirectory();
  return File('${directory.path}/entries.json');
}

saveEntries(GlobalStates model) async {
  if (model._loading) return;
  final file = await _localFile;

  // Convert the entries to JSON and write them to the file
  file.writeAsString(json.encode({
    "balance": model.balance,
    "entries": model.entries!.map((e) => e.toJson()).toList(),
  }));
}

Future<void> loadEntries(GlobalStates model) async {
  try {
    final file = await _localFile;

    // Read the file
    String contents = await file.readAsString();
    log(contents);

    // Convert the JSON string to a List of Entries
    final data = json.decode(contents) as Map<String, dynamic>;
    model.balance = data["balance"] as double;
    final entriesJSON = data["entries"] as List;
    model.entries = entriesJSON.map((json) => Entry.fromJson(json)).toList();
  } catch (e) {
    log('$e');
    model.empty();
  }
}

class Entry {
  final String title;
  final String description;
  final double amount;
  final EntryType type;
  final DateTime date;

  Entry({
    required this.title,
    this.description = '',
    required this.amount,
    required this.type,
  }) : date = DateTime.now();

  Entry.dated({
    required this.title,
    this.description = '',
    required this.amount,
    required this.type,
    required this.date,
  });

  Entry.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        description = json['description'],
        amount = json['amount'],
        type = EntryType.values.firstWhere((e) => e.toString() == json['type']),
        date = DateTime.parse(json['date']);

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'amount': amount,
        'type': type.toString(),
        'date': date.toIso8601String(),
      };
}

enum EntryType {
  income,
  expense,
}

class GlobalStates extends ChangeNotifier {
  List<Entry>? _entries;
  double? _balance;
  bool _loading = true;

  GlobalStates() {
    loadEntries(this).then((void _) {
      _loading = false;
      notifyListeners();
    });
  }

  GlobalStates.empty() {
    empty(notify: false);
  }

  // empty({bool notify = true}) {
  //   _entries = [
  //     Entry(
  //       title: 'Rent',
  //       description: 'Monthly rent',
  //       amount: 1000,
  //       type: EntryType.expense,
  //     ),
  //     Entry(
  //       title: 'Groceries',
  //       description: 'Weekly groceries',
  //       amount: 200,
  //       type: EntryType.expense,
  //     ),
  //     Entry.dated(
  //       title: 'Salary',
  //       description: 'Monthly salary',
  //       amount: 5000,
  //       type: EntryType.income,
  //       date: DateTime.utc(2024, 6),
  //     ),
  //   ];
  //   _balance = _entries!
  //       .map((entry) =>
  //           entry.type == EntryType.income ? entry.amount : -entry.amount)
  //       .reduce((value, element) => value + element);
  //   _loading = false;
  //   notifyListeners();
  // }

  empty({bool notify = true}) {
    _entries = [];
    _balance = 0;
    _loading = false;
    notifyListeners();
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
    saveEntries(this);
  }

  get loading => _loading;

  List<Entry>? get entries => _entries;

  set entries(List<Entry>? newEntries) {
    _entries = newEntries;
    notifyListeners();
  }

  double? get balance => _balance;

  set balance(double? balance) {
    _balance = balance;
    notifyListeners();
  }

  addEntry(Entry newEntry) {
    if (_loading) return;

    _entries!.insert(0, newEntry);
    switch (newEntry.type) {
      case EntryType.income:
        _balance = _balance! + newEntry.amount;
        break;
      case EntryType.expense:
        _balance = _balance! - newEntry.amount;
        break;
    }
    notifyListeners();
  }

  removeEntry(Entry entry) {
    if (_loading) return;

    _entries!.remove(entry);
    switch (entry.type) {
      case EntryType.income:
        _balance = _balance! - entry.amount;
        break;
      case EntryType.expense:
        _balance = _balance! + entry.amount;
        break;
    }
    notifyListeners();
  }

  Map<DateTime, List<Entry>> groupByDate() {
    if (_loading) return {};
    final grouped = <DateTime, List<Entry>>{};
    for (final entry in _entries!) {
      final date = DateTime(entry.date.year, entry.date.month, entry.date.day);
      if (grouped.containsKey(date)) {
        grouped[date]!.add(entry);
      } else {
        grouped[date] = [entry];
      }
    }
    return grouped;
  }
}
