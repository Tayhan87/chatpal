import "package:flutter/material.dart";

class LoadView extends StatelessWidget{
  const LoadView({super.key});

  @override
  Widget build(BuildContext context){
    return Center(

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            strokeWidth: 5,
          ),

          const SizedBox(height: 24,),

          Text(
            "Generating quiz",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.deepPurple.shade700
            ),
          ),

          const SizedBox(height: 8,),

         Text(
             "AI is Analyzing Your Document",
           style: TextStyle(
             fontSize: 14,
             color: Colors.grey.shade600
           ),
         ),


        ],
      ),
    );
  }

}