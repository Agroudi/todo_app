import 'package:flutter/material.dart';
import 'package:todo_app/shared/cubit/cubit.dart';

Widget defaultFormField({
  Key? key,
  required TextEditingController controller,
  required TextInputType type,
  onSubmit,
  onChange,
  onTap,
  bool isPassword = false,
  required validate,
  required String label,
  required IconData prefix,
  IconData? suffix,
  suffixPressed,
}) => TextFormField(
  controller: controller,
  keyboardType: type,
  obscureText: isPassword,
  onFieldSubmitted: onSubmit,
  onChanged: onChange,
  onTap: onTap,
  validator: validate,
  decoration: InputDecoration(
    border: const OutlineInputBorder(),
    labelText: label,
    prefixIcon: Icon(
      prefix),
      suffixIcon: suffix != null ? IconButton(onPressed: suffixPressed,
         icon:  Icon(suffix)) : null,
  ),
);

Widget buildTaskItems(Map model, context) => Dismissible(
  key: Key(model['ID'].toString()),
  onDismissed: (direction)
  {
    AppCubit.get(context).deleteData(ID: model['ID']);
  },
  child: Padding(
    padding: const EdgeInsets.all(17.0),
    child: Row(
      children: [
        CircleAvatar(
          radius: 40.0,
          child: Text(
              '${model['Time']}'
          ),
          backgroundColor: Colors.amber,
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${model['Title']}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${model['Date']}',
                style: const TextStyle(
                    color: Colors.grey
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        IconButton(onPressed: ()
        {
          AppCubit.get(context).updateData(Status: 'Done', ID: model['ID']);
        }
        ,icon: Icon(color: Colors.green,
              Icons.check_box_outlined)),
        const SizedBox(width: 20),
        IconButton(onPressed: ()
        {
          AppCubit.get(context).updateData(Status: 'Archived', ID: model['ID']);
        }
          ,icon: Icon(color: Colors.amber,
              Icons.archive_outlined),)
      ],
    ),
  ),
);