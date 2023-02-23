import 'package:flutter/material.dart';

// home screen transport selection card

class GridItem extends StatelessWidget {
  final IconData? icon;
  final Color? color;
  final String? title;
  final Color? iconColor;
  final VoidCallback? onTap;
  const GridItem(
      {Key? key, this.color, this.icon, this.onTap, this.title, this.iconColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Icon(
                icon,
                color: iconColor,
                size: 60,
              ),
            ),
            Text(
              title!,
              style: const TextStyle(fontWeight: FontWeight.w500),
            )
          ],
        ),
      ),
    );
  }
}
