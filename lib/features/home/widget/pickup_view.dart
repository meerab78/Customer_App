import '../../../core/shared/widgets/selection_card.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/fonts_manager.dart';
import '../../../core/theme/textfont_styles.dart';
import '../../../core/shared/widgets/custom_button.dart';

class PickupView extends StatelessWidget{
  const PickupView({super.key});

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
              child: Icon(
                Icons.storefront,
                color:AppColors.primary,
                size:38,
              ),
            ),

            const SizedBox(height:18),

            Text(
              "Pickup From",
              style:getBoldStyle(
                fontSize:MyFonts.size24,
                color:AppColors.text,
              ),
            ),

            const SizedBox(height:6),

            Text(
              "Choose your restaurant branch",
              style:getRegularStyle(
                color:AppColors.grey600,
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




