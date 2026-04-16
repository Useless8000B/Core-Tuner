import 'package:flutter/material.dart';

class AppbarComponent extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const AppbarComponent({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: null,
      actions: [
        Padding(
          padding: EdgeInsetsGeometry.only(right: 18),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
