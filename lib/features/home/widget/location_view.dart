import '../../../core/shared/widgets/selection_card.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/fonts_manager.dart';
import '../../../core/theme/textfont_styles.dart';
import '../../../core/shared/widgets/custom_button.dart';
class LocationView extends StatelessWidget{
  const LocationView({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor:AppColors.background,
      // appBar:AppBar(
      //   title:const Text("Delivery"),
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
                Icons.delivery_dining,
                color:AppColors.primary,
                size:38,
              ),
            ),

            const SizedBox(height:18),

            Text(
              "Deliver To",
              style:getBoldStyle(
                fontSize:MyFonts.size24,
                color:AppColors.text,
              ),
            ),

            const SizedBox(height:6),

            Text(
              "Choose your delivery location",
              style:getRegularStyle(
                color:AppColors.grey600,
              ),
            ),

            const SizedBox(height:30),

            SelectionCard(
              icon:Icons.my_location,
              title:"Current Location",
              subtitle:"Use GPS Location",
              onTap:(){
                // TODO:
              },
            ),

            SelectionCard(
              icon:Icons.location_city,
              title:"City / Region",
              subtitle:"Select City",
              onTap:(){
                // TODO: Bottom Sheet
              },
            ),

            SelectionCard(
              icon:Icons.location_on,
              title:"Area / Subregion",
              subtitle:"Select Area",
              onTap:(){
                // TODO: Bottom Sheet
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




