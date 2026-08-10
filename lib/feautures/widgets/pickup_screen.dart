import 'package:customer_app/feautures/widgets/selection_card.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'custom_button.dart';

class PickupScreen extends StatelessWidget{
  const PickupScreen({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor:AppColors.background,
      // appBar:AppBar(
      //   title:const Text("Pickup"),
      //   centerTitle:true,
      // ),
      body:Padding(
        padding:const EdgeInsets.all(20),
        child:Column(
          children:[

            const SizedBox(height:70),

            CircleAvatar(
              radius:38,
              backgroundColor:AppColors.primary.withOpacity(.1),
              child:const Icon(
                Icons.storefront,
                color:AppColors.primary,
                size:38,
              ),
            ),

            const SizedBox(height:18),

            const Text(
              "Pickup From",
              style:TextStyle(
                fontSize:24,
                fontWeight:FontWeight.bold,
              ),
            ),

            const SizedBox(height:6),

            Text(
              "Choose your restaurant branch",
              style:TextStyle(
                color:Colors.grey.shade600,
              ),
            ),

            const SizedBox(height:30),

            SelectionCard(
              icon:Icons.near_me,
              title:"Nearest Branch",
              subtitle:"TBC QA",
              onTap:(){
                // TODO:
              },
            ),

            SelectionCard(
              icon:Icons.store,
              title:"Choose Another Branch",
              subtitle:"Select Branch",
              onTap:(){
                // TODO:
              },
            ),

            SelectionCard(
              icon:Icons.schedule,
              title:"Pickup Time",
              subtitle:"ASAP",
              onTap:(){
                // TODO:
              },
            ),
            const SizedBox(height:30),
            CustomButton(
              text: "Continue",
              onPressed: (){
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}