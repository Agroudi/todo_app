import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:todo_app/shared/cubit/states.dart';
import 'package:todo_app/shared/components/components.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';

class HomeLayout extends StatelessWidget
{
  const HomeLayout({super.key});

  @override
  Widget build(BuildContext context)
  {
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppStates>(
          listener: (BuildContext context, AppStates state) {
            if(state is AppInsertDatabaseState)
              {
                Navigator.pop(context);
              }
          },
          builder: (BuildContext context, AppStates state)
        {
          AppCubit cubit = AppCubit.get(context);
        return Scaffold(
          key: scaffoldKey,
          appBar: AppBar(
            backgroundColor: Colors.amber,
            title: Text(cubit.Titles[cubit.currentIndex],
              style: const TextStyle(
                  color: Colors.white
              ),
            ),
          ),
          body: ConditionalBuilder(
              condition: state is! AppGetDatabaseLoadingState,
              builder: (context) => cubit.Screens[cubit.currentIndex],
              fallback: (BuildContext context) => const Center(child: CircularProgressIndicator())
          ),

          floatingActionButton: FloatingActionButton(
            onPressed: ()
            {
               if(cubit.isBottomSheetShown)
               {
                   if(formKey.currentState!.validate()) {
                   cubit.InsertToDatabase(
                       titleController.text,
                       dateController.text,
                       timeController.text);
                   }
               } else
               {
                scaffoldKey.currentState!.showBottomSheet((context) =>
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children:
                          [
                            defaultFormField(
                                controller: titleController,
                                type: TextInputType.text,
                                validate: (value)
                                {
                                  if(value.isEmpty)
                                  {
                                    return "Title cannot be empty";
                                  }
                                  return null;
                                },
                                label: 'Task Title',
                                prefix: Icons.title),

                            const SizedBox(height: 15.0),

                            defaultFormField(
                                controller: timeController,
                                type: TextInputType.datetime,
                                onTap: ()
                                {
                                  showTimePicker
                                    (
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  ).then((value)
                                  {
                                    timeController.text = value!.format(context).toString();
                                  });
                                },
                                validate: (value)
                                {
                                  if(value == null || value.isEmpty)
                                  {
                                    return "Time cannot be empty";
                                  }

                                  // Regex for "HH:MM AM/PM"
                                  final RegExp timePattern = RegExp(r'^(0?[1-9]|1[0-2]):[0-5][0-9]\s?(AM|PM)$');

                                  if(!timePattern.hasMatch(value))
                                    {
                                      return "Time Must Be 'HH:MM AM/PM'";
                                    }
                                  return null;
                                },
                                label: 'Task Time',
                                prefix: Icons.watch_later_outlined),

                            const SizedBox(height: 15.0),

                            defaultFormField(
                                controller: dateController,
                                type: TextInputType.datetime,
                                onTap: ()
                                {
                                  showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.parse("2029-12-31"),
                                  ).then((value)
                                  { if(value != null)
                                  {
                                    dateController.text = DateFormat.yMMMd().format(value);
                                  }
                                  });
                                },
                                validate: (value)
                                {
                                  if(value == null || value.isEmpty)
                                  {
                                    return "Date cannot be empty";
                                  }

                                  // Regex to Match Date
                                  final RegExp datePattern = RegExp(r'^\w{3}\s\d{1,2},\s\d{4}$');
                                  if(!datePattern.hasMatch(value))
                                    {
                                      return 'Date Must Be MMM D,YYYY';
                                    }
                                  return null;
                                  },
                                label: 'Task Date',
                                prefix: Icons.calendar_month_outlined),
                          ],
                        ),
                      ),
                    ),
                  elevation: 80.0,
                ).closed.then((value)
                {
                  cubit.ChangeBottomSheetState(isShow: false, icon: Icons.edit);
                });
                cubit.ChangeBottomSheetState(isShow: true, icon: Icons.add);
              }
            },
            backgroundColor: Colors.amber,
            child: Icon(cubit.fabIcon),
          ),
          bottomNavigationBar:
          BottomNavigationBar(
              backgroundColor: Colors.amber,
              type: BottomNavigationBarType.fixed,
              currentIndex: cubit.currentIndex,
              onTap: (index)
              {
                cubit.changeIndex(index);
              },
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.menu, color: Colors.green,),
                    label: "Tasks"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.check_circle_outline, color: Colors.green),
                    label: "Done"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.archive_outlined, color: Colors.green),
                    label: "Archived"),
              ]
          ),
        );
        }
      ),
    );
  }
}
var scaffoldKey = GlobalKey<ScaffoldState>();
var formKey = GlobalKey<FormState>();
var titleController = TextEditingController();
var timeController = TextEditingController();
var dateController = TextEditingController();