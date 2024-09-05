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
  Item({required this.id, required this.name, required this.modifiersScreens});

  final String id;
  final String name;
  List<ModifiersScreen> modifiersScreens;
}

class ModifiersScreen {
  ModifiersScreen(
      {required this.id,
      required this.min,
      required this.max,
      required this.freeCount,
      required this.name,
      required this.modifiers});

  final String id;
  final String name;
  final int min;
  final int max;
  final int freeCount;
  final List<Modifier> modifiers;

  // Deep copy method to create a full copy of the modifiers screens tree
  ModifiersScreen copy() {
    return ModifiersScreen(
      id: id,
      min: min,
      max: max,
      freeCount: freeCount,
      name: name,
      modifiers: modifiers.map((m) => m.copy()).toList(),
    );
  }
}

class Modifier {
  Modifier(
      {required this.id,
      required this.name,
      required this.modifiersScreens,
      this.isSelected = false});

  final String id;
  final String name;
  bool isSelected;
  final List<ModifiersScreen> modifiersScreens;

  // Deep copy method to create a full copy of the modifier tree
  Modifier copy() {
    return Modifier(
      id: id,
      name: name,
      isSelected: isSelected,
      modifiersScreens: modifiersScreens.map((m) => m.copy()).toList(),
    );
  }
}

// Sample data
final List<Item> items = [
  Item(
    name: 'Item 0',
    id: 'i0',
    modifiersScreens: [
      ModifiersScreen(
        id: 'ms0',
        min: 1,
        max: 2,
        freeCount: 1,
        name: 'Modifier Screen 0',
        modifiers: [
          Modifier(
            name: 'Modifier 0.0',
            id: 'm0',
            modifiersScreens: [
              ModifiersScreen(
                id: 'ms0.0',
                min: 1,
                max: 2,
                freeCount: 1,
                name: 'Modifier Screen 0.0',
                modifiers: [
                  Modifier(
                      name: 'Modifier 0.0.0', id: 'm0.0', modifiersScreens: []),
                  Modifier(
                      name: 'Modifier 0.0.1', id: 'm0.1', modifiersScreens: []),
                ],
              ),
              ModifiersScreen(
                id: 'ms0.1',
                min: 1,
                max: 2,
                name: 'Modifier Screen 0.1',
                freeCount: 1,
                modifiers: [
                  Modifier(
                      name: 'Modifier 0.1.0', id: 'm0.0', modifiersScreens: []),
                  Modifier(
                      name: 'Modifier 0.1.1', id: 'm0.1', modifiersScreens: []),
                ],
              ),
            ],
          ),
          Modifier(
            name: 'Modifier 0.1',
            id: 'm1',
            modifiersScreens: [],
          ),
        ],
      ),
      ModifiersScreen(
        id: 'ms1',
        min: 1,
        max: 2,
        freeCount: 1,
        name: 'Modifier Screen 1',
        modifiers: [
          Modifier(
            name: 'Modifier 1.0',
            id: 'm2',
            modifiersScreens: [
              ModifiersScreen(
                id: 'ms1.0',
                min: 1,
                max: 2,
                freeCount: 1,
                name: 'Modifier Screen 1.0',
                modifiers: [
                  Modifier(
                      name: 'Modifier 1.0.0', id: 'm2.0', modifiersScreens: []),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  ),
  Item(
    name: 'Item 1',
    id: 'i1',
    modifiersScreens: [
      ModifiersScreen(
        id: 'ms1',
        min: 1,
        max: 2,
        freeCount: 1,
        name: 'Modifier Screen 1',
        modifiers: [
          Modifier(
            name: 'Modifier 1.0',
            id: 'm2',
            modifiersScreens: [
              ModifiersScreen(
                id: 'ms1.0',
                min: 1,
                max: 2,
                freeCount: 1,
                name: 'Modifier Screen 1.0',
                modifiers: [
                  Modifier(
                      name: 'Modifier 1.0.0', id: 'm2.0', modifiersScreens: []),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  ),
];

// Constants for button text
const cancelText = 'Cancel';
const doneText = 'Done';

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
            onTap: () async {
              for (final modifiersScreen in items[index].modifiersScreens) {
                await _showModifiersScreenDialog(context, modifiersScreen);
              }
            },
          );
        },
      ),
    );
  }

  // Show Modifiers dialog
  Future<T?> _showModifiersScreenDialog<T>(
      BuildContext context, ModifiersScreen modifiersScreen) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return ModifiersScreenDialog(modifiersScreen: modifiersScreen);
      },
    );
  }
}

class ModifiersScreenDialog extends StatefulWidget {
  final ModifiersScreen modifiersScreen;

  const ModifiersScreenDialog({super.key, required this.modifiersScreen});

  @override
  State<ModifiersScreenDialog> createState() => _ModifiersScreenDialogState();
}

class _ModifiersScreenDialogState extends State<ModifiersScreenDialog> {
  late ModifiersScreen originalModifiersScreenState;
  bool isDirty = false;

  @override
  void initState() {
    super.initState();
    // Save a deep copy of the entire modifier tree state
    originalModifiersScreenState = widget.modifiersScreen.copy();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.modifiersScreen.name),
      content: SizedBox(
        height: 260,
        width: double.maxFinite,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Min: ${widget.modifiersScreen.min}'),
            Text('Max: ${widget.modifiersScreen.max}'),
            Text('Free Count: ${widget.modifiersScreen.freeCount}'),
            const Divider(),
            const Text('Modifiers: '),
            Expanded(
              child: ListView.builder(
                itemCount: widget.modifiersScreen.modifiers.length,
                itemExtent: 56.0, // Fixed height for each item
                itemBuilder: (context, index) {
                  final modifier = widget.modifiersScreen.modifiers[index];
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
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text(cancelText),
          onPressed: () {
            // Revert to original state if changes were made
            if (isDirty) {
              _revertToOriginalState();
            }
            Navigator.of(context).pop('CANCEL');
          },
        ),
        TextButton(
          child: const Text(doneText),
          onPressed: () {
            // Save changes and dismiss the dialog
            Navigator.of(context).pop('DONE');
          },
        ),
      ],
    );
  }

  // Handle tapping on a modifier
  void _onModifierTap(Modifier modifier) async {
    setState(() {
      isDirty = true; // Track changes
      if (modifier.isSelected) {
        // Unselect modifier and its children recursively
        _unselectModifiers(modifier);
      } else {
        // Select modifier and show its child modifiers
        modifier.isSelected = true;
      }
    });

    // Lazy load child modifiers
    if (modifier.modifiersScreens.isNotEmpty && modifier.isSelected) {
      for (final modifierScreen in modifier.modifiersScreens) {
        await _showModifiersScreenDialog(context, modifierScreen);
      }
    }
  }

  // Unselect modifier and all its descendants
  void _unselectModifiers(Modifier modifier) {
    modifier.isSelected = false;
    for (final modifierScreen in modifier.modifiersScreens) {
      for (final childModifier in modifierScreen.modifiers) {
        _unselectModifiers(childModifier);
      }
    }
  }

  // Revert to the original state when "Cancel" is tapped, including child modifiers
  void _revertToOriginalState() {
    for (int i = 0; i < widget.modifiersScreen.modifiers.length; i++) {
      _revertModifierState(widget.modifiersScreen.modifiers[i],
          originalModifiersScreenState.modifiers[i]);
    }
  }

  // Recursively revert modifier states
  void _revertModifierState(Modifier current, Modifier original) {
    current.isSelected = original.isSelected;
    for (int i = 0; i < current.modifiersScreens.length; i++) {
      for (int j = 0; j < current.modifiersScreens[i].modifiers.length; j++) {
        _revertModifierState(current.modifiersScreens[i].modifiers[j],
            original.modifiersScreens[i].modifiers[j]);
      }
    }
  }

  // Show the child modifier screen dialog
  Future<T?> _showModifiersScreenDialog<T>(
      BuildContext context, ModifiersScreen modifierScreen) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return ModifiersScreenDialog(modifiersScreen: modifierScreen);
      },
    );
  }
}
