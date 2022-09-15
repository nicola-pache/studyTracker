import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

/// Shows a filter manager to filter goals or modules.
class FilterManager extends StatelessWidget {
  FilterManager({required this.filters, required this.filterName,
    required this.onSave, required this.dialogTitle, Key? key}) : super(key: key);

  /// Available filters.
  final Map<String, String> filters;

  /// The name of the currently selected filter.
  final String filterName;

  /// Function executed on saving the filter type.
  final void Function(String) onSave;

  /// The tile of the dialog.
  final String dialogTitle;

  /// The currently filter.
  late final ValueNotifier<String> _currentlySelectedFilter = ValueNotifier<String>(
      Hive.box('settings').get(filterName));

  /// Builds the list of filters.
  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text("Filter"),
        subtitle: ValueListenableBuilder(
            valueListenable: _currentlySelectedFilter,
            builder: (BuildContext context, String value, _) {
              return Text(filters[value]!);
            }),
        trailing: Icon(Icons.filter_alt,
            color: Theme.of(context).colorScheme.onSurface),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
        onTap: () {
          return _showFilterManager(context);
        });
  }

  /// Creates the filter manager.
  void _showFilterManager(BuildContext context) {
    // Shows a dialog with all sorting options
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text(dialogTitle),
              content: listFilters(context),
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
                      onSave(_currentlySelectedFilter.value);
                      Navigator.of(context).pop();
                    })
              ]);
        });
  }

  /// Lists the possible sort orders from which the user can select one.
  Widget listFilters(BuildContext context) {
    return Container(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height / 4,
        child: Scrollbar(
            isAlwaysShown: true,
            interactive: true,
            child: ListView.builder(
                itemCount: filters.length,
                itemBuilder: (BuildContext context, int index) {
                  MapEntry<String, String> _filter = filters.entries.elementAt(index);
                  return ValueListenableBuilder(
                      valueListenable: _currentlySelectedFilter,
                      builder: (BuildContext context, String value, _) {
                        return ListTile(
                            title:
                            Text(_filter.value, style: TextStyle(fontSize: 18)),
                            selected: _filter.key == value,
                            onTap: () {
                              _currentlySelectedFilter.value = _filter.key;
                            }
                        );
                      }
                  );
                })));
  }
}
