import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:todo_app/shared/cubit/states.dart';
import 'package:todo_app/shared/components/components.dart';

class NewTasksScreen extends StatelessWidget {
  const NewTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
        listener: (context, state) {},
        builder: (context, state)
        {
          var Tasks = AppCubit.get(context).newTasks;

          return ConditionalBuilder(
            condition:Tasks.length > 0,
            builder: (context) => ListView.separated(
                itemBuilder: (context, index)
                {
                  return buildTaskItems(Tasks[index], context);
                },
                separatorBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Container(
                    width: double.infinity,
                    height: 1.0,
                    color: Colors.grey[300],
                  ),
                ),
                itemCount: Tasks.length
            ),
            fallback: (context) => Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                        Icons.menu,
                        size: 100,
                        color: Colors.amber),
                    Text(
                      'Press The Button To Add Your Tasks',
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 20,
                          fontWeight: FontWeight.w600),),
                  ]
              ),
            ),
          );
        }
    );
  }
}