import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Modifiers Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ItemListScreen(),
    );
  }
}

class Item {
  Item({required this.id, required this.name, required this.modifiers});

  final String id;
  final String name;
  List<Modifier> modifiers;
}

class Modifier {
  Modifier(
      {required this.id,
      required this.name,
      required this.modifiers,
      this.isSelected = false});

  final String id;
  final String name;
  List<Modifier> modifiers;
  bool isSelected;

  // Deep copy method to create a full copy of the modifier tree
  Modifier copy() {
    return Modifier(
      id: id,
      name: name,
      isSelected: isSelected,
      modifiers: modifiers.map((m) => m.copy()).toList(),
    );
  }
}

// Sample data
final List<Item> items = [
  Item(
    name: 'Item 0',
    id: 'i0',
    modifiers: [
      Modifier(
        name: 'Modifier 0.0',
        id: 'm0',
        modifiers: [
          Modifier(name: 'Modifier 0.0.0', id: 'm0.0', modifiers: []),
          Modifier(name: 'Modifier 0.0.1', id: 'm0.1', modifiers: []),
        ],
      ),
      Modifier(
        name: 'Modifier 0.1',
        id: 'm1',
        modifiers: [],
      ),
    ],
  ),
  Item(
    name: 'Item 1',
    id: 'i1',
    modifiers: [
      Modifier(
        name: 'Modifier 1.0',
        id: 'm2',
        modifiers: [
          Modifier(name: 'Modifier 1.0.0', id: 'm2.0', modifiers: []),
        ],
      ),
    ],
  ),
];

class ItemListScreen extends StatelessWidget {
  const ItemListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Items'),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(items[index].name),
            onTap: () => _showModifiersDialog(context, items[index].modifiers),
          );
        },
      ),
    );
  }

  // Show Modifiers dialog
  void _showModifiersDialog(BuildContext context, List<Modifier> modifiers) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ModifierDialog(modifiers: modifiers);
      },
    );
  }
}

class ModifierDialog extends StatefulWidget {
  final List<Modifier> modifiers;

  const ModifierDialog({super.key, required this.modifiers});

  @override
  State<ModifierDialog> createState() => _ModifierDialogState();
}

class _ModifierDialogState extends State<ModifierDialog> {
  late List<Modifier> originalModifiersState;

  @override
  void initState() {
    super.initState();
    // Save a deep copy of the entire modifier tree state
    originalModifiersState =
        widget.modifiers.map((modifier) => modifier.copy()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifiers'),
      content: SizedBox(
        height: 200,
        width: double.maxFinite,
        child: ListView.builder(
          itemCount: widget.modifiers.length,
          itemBuilder: (context, index) {
            final modifier = widget.modifiers[index];
            return ListTile(
              title: Text(modifier.name),
              trailing: Icon(
                modifier.isSelected
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                color: modifier.isSelected ? Colors.green : null,
              ),
              onTap: () => _onModifierTap(modifier),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            // Revert to original state including child modifiers
            _revertToOriginalState();
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Done'),
          onPressed: () {
            // Save changes and cancel the dialog
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  // Handle tapping on a modifier
  void _onModifierTap(Modifier modifier) {
    setState(() {
      if (modifier.isSelected) {
        // Unselect modifier and its children recursively
        _unselectModifiers(modifier);
      } else {
        // Select modifier and show its child modifiers
        modifier.isSelected = true;
        if (modifier.modifiers.isNotEmpty) {
          _showModifiersDialog(context, modifier.modifiers);
        }
      }
    });
  }

  // Unselect a modifier and its children recursively
  void _unselectModifiers(Modifier modifier) {
    modifier.isSelected = false;
    for (var child in modifier.modifiers) {
      _unselectModifiers(child);
    }
  }

  // Revert to the original state when "Cancel" is tapped, including child modifiers
  void _revertToOriginalState() {
    for (int i = 0; i < widget.modifiers.length; i++) {
      _revertModifierState(widget.modifiers[i], originalModifiersState[i]);
    }
  }

  // Recursively revert modifier states
  void _revertModifierState(Modifier current, Modifier original) {
    current.isSelected = original.isSelected;
    for (int i = 0; i < current.modifiers.length; i++) {
      _revertModifierState(current.modifiers[i], original.modifiers[i]);
    }
  }

  // Show modifiers in a new dialog
  void _showModifiersDialog(BuildContext context, List<Modifier> modifiers) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ModifierDialog(modifiers: modifiers);
      },
    ).then((_) => setState(() {})); // Ensure UI updates after dialog cancels
  }
}
