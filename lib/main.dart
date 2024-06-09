import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'entry.dart';
import 'new_entry_screen.dart';
import 'summary.dart';
import 'textured_container.dart';

void main() {
  runApp(
    ChangeNotifierProvider<GlobalStates>(
      create: (context) => GlobalStates(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallet',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'YOUR WALLET',
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(color: Theme.of(context).colorScheme.onSurface),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        centerTitle: true,
      ),
      body: const HomeScreenBody(),
      floatingActionButton: FloatingActionButton(
        tooltip: "Add new entry",
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: const Icon(Icons.add),
        onPressed: () async {
          Entry? result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const NewEntryScreen(),
            ),
          );
          if (result != null) {
            if (!context.mounted) return;
            Provider.of<GlobalStates>(
              context,
              listen: false,
            ).addEntry(result);
          }
        },
      ),
      drawer: const WalletDrawer(),
    );
  }
}

class WalletDrawer extends StatelessWidget {
  const WalletDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DrawerHeader(
            padding: const EdgeInsets.all(0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: TexturedContainer(
              opacity: 0.02,
              child: Column(
                children: [
                  Text(
                    'YOUR WALLET',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                  Expanded(
                    child: Center(
                      child: OutlinedButton(
                        onPressed: () {
                          Provider.of<GlobalStates>(context, listen: false)
                              .empty();
                          Navigator.pop(context);
                        },
                        child: const Text('Reset wallet'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class HomeScreenBody extends StatelessWidget {
  const HomeScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Summary(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Text(
            "ENTRIES",
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
          ),
        ),
        const Entries(),
      ],
    );
  }
}

class Entries extends StatelessWidget {
  const Entries({super.key});

  @override
  Widget build(BuildContext context) {
    final groupedEntries = Provider.of<GlobalStates>(context).groupByDate();

    return Expanded(
      child: ListView.builder(
        itemCount: groupedEntries.length,
        itemBuilder: (context, index) {
          final date = groupedEntries.keys.elementAt(index);
          final entries = groupedEntries[date]!;
          return EntryGroup(date: date, entries: entries);
        },
      ),
    );
  }
}

class EntryGroup extends StatelessWidget {
  const EntryGroup({
    super.key,
    required this.date,
    required this.entries,
  });

  final DateTime date;
  final List<Entry> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            DateFormat.yMMMd().format(date),
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return EntryWidget(entry);
          },
        ),
      ],
    );
  }
}

class EntryWidget extends StatelessWidget {
  const EntryWidget(this.entry, {super.key});

  final Entry entry;

  @override
  Widget build(BuildContext context) {
    final formattedCost =
        "${entry.type == EntryType.income ? '+' : '-'}${currency.format(entry.amount)}";

    return Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(entry.title,
                      style: Theme.of(context).textTheme.bodyLarge),
                  Text(
                    formattedCost,
                    style: TextStyle(
                      color: entry.type == EntryType.income
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  entry.description.isNotEmpty
                      ? Text(entry.description)
                      : Container(),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              Provider.of<GlobalStates>(context, listen: false)
                  .removeEntry(entry);
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}
