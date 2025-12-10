import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/shared/cubit/states.dart';
import 'package:todo_app/layout/todo_app/Todo_Layout.dart';
import 'package:todo_app/modules/new_tasks/New_TasksScreen.dart';
import 'package:todo_app/modules/done_tasks/Done_TasksScreen.dart';
import 'package:todo_app/modules/archived_tasks/Archived_TasksScreen.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;

  List<Widget> Screens =
  [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen(),
  ];

  List<String> Titles =
  [
    "New Tasks",
    "Done Tasks",
    "Archived Tasks",
  ];

  void changeIndex(int index) {
    currentIndex = index;
    emit(AppChangeBottomNavBarState());
  }

  Database? database;

  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];

  void createDatabase() {
    openDatabase(
        'Todo.db',
        version: 1,
        onCreate: (db, version) {
          print('Database Created');
          db.execute(
              'CREATE TABLE Tasks (ID INTEGER PRIMARY KEY, Title TEXT, Date TEXT, Time TEXT, Status TEXT)')
              .then((value) {
            print("Table Created");
          }).catchError((Error) {
            print('Error while creating the table ${Error.toString()}');
          });
        },
        onOpen: (database) {
          getDataFromDatabase(database);
          print('Database Opened');
        }
    ).then((value) {
      database = value;
      emit(AppCreateDatabaseState());
    });
  }

  Future InsertToDatabase(
      @required String Title,
      @required String Date,
      @required String Time,) async
  {
    if (database == null) {
      print("Database isn't initialized");

      return;
    }
    return await database!.transaction((txn) async
    {
      txn.rawInsert(
          'INSERT INTO Tasks(Title, Date, Time, Status) VALUES("$Title", "$Date", "$Time", "New")').then((value) {
        print("$value Inserted Successfully");
        emit(AppInsertDatabaseState());
        getDataFromDatabase(database);
        Clear();
      }).catchError((Error) => print('Error while inserting new record ${Error.toString()}'));
    });
  }

  void getDataFromDatabase(database) {
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];

    emit(AppGetDatabaseLoadingState());

    database!.rawQuery('SELECT * FROM Tasks').then((value) {
      if (value is List<Map<String, dynamic>>) {
        value.forEach((element) {
          if (element['Status'] == 'New') {
            newTasks.add(element);
          } else if (element['Status'] == 'Done') {
            doneTasks.add(element);
          } else {
            archivedTasks.add(element);
          }
        });
      } else {
        print("Unexpected data format: $value");
      }
      emit(AppGetDatabaseState());
    }).catchError((error) {
      print('Error while fetching data from the database: ${error.toString()}');
    });
  }

  void updateData({
    required dynamic Status,
    required ID,
  }) async
  {
    database!.rawUpdate(
        'UPDATE Tasks SET Status = ? WHERE ID = ?',
        ['$Status', '$ID']).then((value) {
      getDataFromDatabase(database);
      emit(AppUpdateDatabaseState());
      print('Task ($ID) Was $Status');
    });
  }

  void deleteData({
    required ID,
  }) async
  {
    database!.rawDelete(
        'DELETE FROM Tasks WHERE ID = ?', ['$ID']).then((value)
    {
      getDataFromDatabase(database);
      emit(AppDeleteDatabaseState());
      print('Task ($ID) Was Deleted');
    });
  }

  @override
  void Clear()
  {
    titleController.clear();
    timeController.clear();
    dateController.clear();
  }

  bool isBottomSheetShown = false;
  IconData fabIcon = Icons.edit;

  void ChangeBottomSheetState({
    required bool isShow,
    required IconData icon,})
  {
    isBottomSheetShown = isShow;
    fabIcon = icon;

    emit(AppChangeBottomSheetState());
  }
}