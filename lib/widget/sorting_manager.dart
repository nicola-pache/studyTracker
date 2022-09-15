import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

/// Creates a sorting manager.
class SortingManager extends StatelessWidget {
  SortingManager({required this.onSave,
    required this.sortOrders,
    required this.dialogTitle,
    required this.boxName,
    Key? key}) : super(key: key);

  /// Function that will be executed on saving the sorting type.
  final void Function(String) onSave;

  /// List of all sort orders.
  final Map<String, String> sortOrders;

  /// Title of the dialog.
  final String dialogTitle;

  /// Name of the box (goal or module).
  final String boxName;

  /// The currently selected sort order.
  late final ValueNotifier<String> _currentlySelectedSortOrder
      = ValueNotifier('');

  /// Builds the sorting manager view.
  @override
  Widget build(BuildContext context) {

    // initialize the ValueNotifier with the sort order saved in the HiveBox
    _currentlySelectedSortOrder.value = Hive.box('settings').get(boxName);

    return ListTile(
        title: Text("Sortierung"),
        subtitle:
          ValueListenableBuilder(
              valueListenable: _currentlySelectedSortOrder,
              builder: (BuildContext context, String value, _) {
                return Text(sortOrders[value]!);
              }),
        trailing: Icon(Icons.swap_vert,
            color: Theme.of(context).colorScheme.onSurface),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
        onTap: () {
          return _showSortingManager(context);
        });
  }

  /// Shows the sorting manager.
  void _showSortingManager(BuildContext context) {
    // Shows a dialog with all sorting options
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text(dialogTitle),
              content: listSortOrders(context),
              actions: <Widget>[
                TextButton(
                  child:
                      const Text('ABBRECHEN', style: TextStyle(fontSize: 18)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                    child:
                        const Text('SPEICHERN', style: TextStyle(fontSize: 18)),
                    onPressed: () {
                      onSave(_currentlySelectedSortOrder.value);
                      Navigator.of(context).pop();
                    })
              ]);
        });
  }

  /// Lists the possible sort orders from which the user can select one.
  Widget listSortOrders(BuildContext context) {
    return Container(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height / 3,
        child: Scrollbar(
          isAlwaysShown: true,
          interactive: true,
          child: ListView.builder(
            itemCount: sortOrders.length,
            itemBuilder: (BuildContext context, int index) {
              MapEntry<String, String> _sortOrder = sortOrders.entries.elementAt(index);
              return ValueListenableBuilder(
                  valueListenable: _currentlySelectedSortOrder,
                  builder: (BuildContext context, String value, _) {
                    return ListTile(
                        title:
                          Text(_sortOrder.value, style: TextStyle(fontSize: 18)),
                        selected: _sortOrder.key == value,
                        onTap: () {
                          _currentlySelectedSortOrder.value = _sortOrder.key;
                        }
                    );
                  }
              );
            })));
  }
}
