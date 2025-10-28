import "package:flutter/material.dart";
import "../theme/theme.dart";

class DashboardScreen extends StatelessWidget {
  final VoidCallback onAIChatTap;
  const DashboardScreen({super.key, required this.onAIChatTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.buildBoxDecoration,
      width: double.infinity,
      height: double.infinity,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: title on the left, avatar on the right
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "CramLand",
                    style: _buildTextStyleCram(context),
                  ),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.black26,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text("Welcome Back \nTayhan!",style:_buildTextStyleWel(context),),
              const SizedBox(height:32),
              Container(
                   height: 150,
                  width: 400,
                  child: _buildCardAI(context),
              ),

            ],
          ),
        ),
      ),
    );
  }




  TextStyle _buildTextStyleCram(BuildContext context){
    return const TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      fontFamily: "Inter",
      color: Colors.white54
    );
  }

  TextStyle _buildTextStyleWel(BuildContext context){
    return TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: Color(0xFF3D4B6B),
      height: 1.3,
    );
  }
  
  Card _buildCardAI(BuildContext context){
    return Card(
      elevation: 12,
      shape:RoundedRectangleBorder(
          borderRadius:BorderRadius.circular(30)
      ),
      clipBehavior:Clip.antiAlias,
      color:Color(0xFFE9EEFE),
      child: InkWell(
        onTap: onAIChatTap,
        child: Padding(
          padding:  EdgeInsets.only(left: 24, top: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                  children: [
                    Icon(Icons.smart_toy_outlined,size:70,color: Color(0xFF96A3F6)),
                    SizedBox(height: 5,),
                    Text("AI Chat")
                  ]
              ),
            ],
          ),
        ),
      ),
    );
  }

}
