import 'package:flutter/material.dart';
import "../theme/theme.dart";


class Head extends StatelessWidget{
  final String title;
  final VoidCallback onBackTap;
  const Head({super.key, required this.title,required this.onBackTap});

  Widget build(BuildContext context){
    return Row(

      children: [
        SizedBox(width:8),
        IconButton(
            onPressed: onBackTap,
            icon: Icon(Icons.arrow_back_ios,color: Colors.black54,size: 38,)
        ),
        SizedBox(width: 8,),
        Text(title, style: AppTheme.Titlefont,)
      ],
    );
  }
}