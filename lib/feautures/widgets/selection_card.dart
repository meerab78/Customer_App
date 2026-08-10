import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SelectionCard extends StatelessWidget{
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const SelectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context){
    return InkWell(
      borderRadius:BorderRadius.circular(18),
      onTap:onTap,
      child:Container(
        margin:const EdgeInsets.only(bottom:16),
        padding:const EdgeInsets.all(16),
        decoration:BoxDecoration(
          color:Colors.white,
          borderRadius:BorderRadius.circular(18),
          boxShadow:[
            BoxShadow(
              color:Colors.black12,
              blurRadius:8,
              offset:const Offset(0,3),
            ),
          ],
        ),
        child:Row(
          children:[
            CircleAvatar(
              radius:24,
              backgroundColor:AppColors.primary.withOpacity(.1),
              child:Icon(icon,color:AppColors.primary),
            ),
            const SizedBox(width:14),
            Expanded(
              child:Column(
                crossAxisAlignment:CrossAxisAlignment.start,
                children:[
                  Text(
                    title,
                    style:const TextStyle(
                      fontSize:16,
                      fontWeight:FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height:4),
                  Text(
                    subtitle,
                    style:TextStyle(
                      color:Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size:18,
              color:Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}