import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:transportation_mobile_app/models/entities/inspection_item.dart';
import 'package:transportation_mobile_app/models/entities/modular-args.dart';
import 'package:transportation_mobile_app/utils/app_colors.dart';
import 'package:transportation_mobile_app/widgets/service/report_panel.dart';

class PhotoDetails extends StatefulWidget {
  InspectionItem item;
  bool canEdit;

  PhotoDetails(ModularArguments args) {
    PhotoDetailsArgs argsItem = args.data as PhotoDetailsArgs;
    item = argsItem.item;
    canEdit = argsItem.isEditable;
  }

  @override
  _PhotoDetailsState createState() => _PhotoDetailsState();
}

class _PhotoDetailsState extends State<PhotoDetails> {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.portGore,
        title: Text(
          widget.item.name + " Pictures",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xffeeeeee),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: const Color(0xff7099b2)),
          color: const Color(0xff7099b2),
          onPressed: () {
            handlePop(context);
          },
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 30, horizontal: 30),
        child: ListView(
          children: [
            Container(
              height: 300,
              child: Image.file(
                File(widget.item.value),
                fit: BoxFit.fill,
              ),
            ),
            Divider(),
            Text("Tap anywhere in the image below to report an issue"),
            VehiclePanelReport(sideName: widget.item.name.toLowerCase()),
            // TextField(
            //   enabled: widget.canEdit,
            //   onChanged: (issues) => widget.item.comments = issues,
            //   maxLines: 5,
            //   style: TextStyle(color: Colors.black),
            //   decoration: InputDecoration.collapsed(
            //       hintText:
            //           "Describe any issues needed to be reported for this image, if any."),
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                !widget.canEdit
                    ? Container()
                    : customButton(
                        text: "DELETE",
                        color: AppColors.alizarinCrimson,
                        onPressed: () {
                          widget.item.value = "";
                          handlePop(context);
                        }),
                customButton(
                    text: "BACK",
                    color: AppColors.portGore,
                    onPressed: () => handlePop(context)),
              ],
            )
          ],
        ),
      ),
    );
  }


  Widget customButton({String text, Color color, VoidCallback onPressed}) {
    return TextButton(
        child: Container(
          width: 120,
          height: 34,
          child: Center(child: Text(text)),
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(6.0)),
        ),
        onPressed: onPressed);
  }

  void handlePop(context) {
    Navigator.pop(context, widget.item);
  }
}


