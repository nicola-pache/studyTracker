import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'goals_model.g.dart';

@HiveType(typeId: 1)

/// This class represents a Goal. It is also a HiveObject, so it can be handled
/// easily by the Hive-Database.
class Goal extends HiveObject{
  Goal({this.name = '', this.color = Colors.blue, this.creationDate = ''});

  @HiveField(0)
  String name;
  @HiveField(1)
  Duration? estimatedTime;
  @HiveField(2)
  DateTime? deadline;
  @HiveField(3)
  String? reminder;
  @HiveField(4)
  String module = '0';
  @HiveField(5)
  String? notes;
  @HiveField(6)
  Duration timeLearned = const Duration();
  @HiveField(7)
  Color color;
  @HiveField(8)
  bool isCompleted = false;
  @HiveField(9)
  bool isArchived = false;
  @HiveField(10)
  String creationDate;

  /// A Comparator that says how to sort the goals
  static Comparator<Goal> goalComparator() {
    String _sortOrder = Hive.box('settings').get('goalsSortOrder');
    return (a, b) {
      int _comparator;
      switch (_sortOrder) {
        case 'nameDescending':
          _comparator = a.name.compareTo(b.name);
          break;
        case 'nameAscending':
          _comparator = b.name.compareTo(a.name);
          break;
        case 'creationDateDescending':
          _comparator = a.creationDate.compareTo(b.creationDate);
          break;
        case 'creationDateAscending':
          _comparator = b.creationDate.compareTo(a.creationDate);
          break;
        case 'deadlineDescending':
          if (a.deadline != null && b.deadline != null) {
            _comparator = a.deadline!.compareTo(b.deadline!);
          } else if (a.deadline != null) {
            _comparator = -1; // a is before b (b has no deadline)
          } else if (b.deadline != null) {
            _comparator = 1; // b is before a (a has no deadline)
          } else {
            _comparator = a.creationDate.compareTo(b.creationDate);
          }
          break;
        case 'deadlineAscending':
          if (a.deadline != null && b.deadline != null) {
            _comparator = b.deadline!.compareTo(a.deadline!);
          } else if (a.deadline != null) {
            _comparator = -1; // a is before b (b has no deadline)
          } else if (b.deadline != null) {
            _comparator = 1; // b is before a (a has no deadline)
          } else {
            _comparator = a.creationDate.compareTo(b.creationDate);
          }
          break;
        default:
          _comparator = a.creationDate.compareTo(b.creationDate);
      }
      return _comparator;
    };
  }

  /// Gets the time learned in hh:mm:ss
  String getTimeLearned() {
    return timeLearned.toString().split('.').first.padLeft(8, "0");
  }
}