import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'goals_model.dart';

part 'modules_model.g.dart';

@HiveType(typeId: 0)

/// This class represents a Module. It is also a HiveObject, so it can be handled
/// easily by the Hive-Database.
class Module extends HiveObject{
  Module({this.abbreviation = '', this.name = '', this.color = Colors.blue,
    required this.creationDate});
  @HiveField(0)
  String abbreviation;
  @HiveField(1)
  String name;
  @HiveField(2)
  String? teacher;
  @HiveField(3)
  String? semester;
  @HiveField(4)
  String? credits;
  @HiveField(5)
  String? notes;
  @HiveField(6)
  Duration timeLearned = const Duration();
  @HiveField(7)
  Color color;
  @HiveField(8)
  HiveList<Goal> goals = HiveList(Hive.box<Goal>('goals'));
  @HiveField(9)
  bool isClosed = false;
  @HiveField(10)
  String creationDate;

  /// A Comparator that says how to sort the modules
  static Comparator<Module> moduleComparator() {
    String _sortOrder = Hive.box('settings').get('modulesSortOrder');
    return (a, b) {
      int _comparator;
      if (a.creationDate == '0') {
         _comparator = -1;
      } else {
          switch (_sortOrder) {
            case 'nameDescending':
              _comparator = a.name.compareTo(b.name);
              break;
            case 'nameAscending':
              _comparator = b.name.compareTo(a.name);
              break;
            case 'abbreviationDescending':
              _comparator = a.abbreviation.compareTo(b.abbreviation);
              break;
            case 'abbreviationAscending':
              _comparator = b.abbreviation.compareTo(a.abbreviation);
              break;
            case 'creationDateDescending':
              _comparator =a.creationDate.compareTo(b.creationDate);
              break;
            case 'creationDateAscending':
              _comparator =b.creationDate.compareTo(a.creationDate);
              break;
            default:
              _comparator = a.abbreviation.compareTo(b.name);
          }
      }
      return _comparator;
    };
  }

  // Formats the time learned in HH:MM:SS
  String formatTimeLearned() {
    return timeLearned.toString().split('.').first.padLeft(8, "0");
  }
}