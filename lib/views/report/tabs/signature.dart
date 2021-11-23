import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:signature/signature.dart';
import 'package:transportation_mobile_app/controllers/report/bill_of_lading.dart';
import 'package:transportation_mobile_app/models/entities/globals.dart';
import 'package:transportation_mobile_app/models/entities/inspection_item.dart';
import 'package:transportation_mobile_app/models/entities/report_enums.dart';
import 'package:transportation_mobile_app/utils/app_colors.dart';
import 'package:transportation_mobile_app/utils/app_images.dart';
import 'package:transportation_mobile_app/utils/services/local_storage.dart';
import 'package:transportation_mobile_app/widgets/report/button_widget.dart';
import 'package:transportation_mobile_app/widgets/report/digital_input_menu.dart';
import 'package:transportation_mobile_app/widgets/report/rectangular_button.dart';

class SignatureTabPage extends StatefulWidget {
  final ReportCategories reportTabName;
  final List<ReportCategories> reportingCategories;

  SignatureTabPage(
      {@required this.reportTabName,
      @required this.reportingCategories,
      Key key})
      : super(key: key);

  @override
  _SignatureTabPageState createState() => _SignatureTabPageState();
}

class _SignatureTabPageState extends State<SignatureTabPage> {
  SignatureController _controller;
  InspectionItem signatureImage;
  InspectionItem customerName;
  bool canUserEdit = false;
  Timer uploadTimer;
  int uploadProgress = 0;
  bool signatureAvail = false;
  static const String NO_SIGNATURE_NOTE = "No signer available";

  void savePoints() {
    signatureImage.signaturePoints = _controller.points;
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      signatureImage = getCurrentSession()
          .categoryItems[widget.reportTabName.getName()]
          .firstWhere((InspectionItem element) =>
              element.name == ReportCategoryItems.SignatureImage.getName());
      customerName = getCurrentSession()
          .categoryItems[widget.reportTabName.getName()]
          .firstWhere((element) =>
              element.name == ReportCategoryItems.CustomerName.getName());
      signatureAvail = customerName.value != NO_SIGNATURE_NOTE;
      canUserEdit = widget.reportTabName
          .canUserEditTab(getCurrentSession().sessionStatus);
      _controller = SignatureController(
          penStrokeWidth: 1,
          penColor: Colors.black,
          exportBackgroundColor: Colors.transparent,
          onDrawEnd: savePoints,
          points: signatureImage.signaturePoints);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(
              height: 50,
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  signatureAvail = !signatureAvail;
                  if (!signatureAvail) {
                    customerName.value = NO_SIGNATURE_NOTE;
                  } else {
                    customerName.value = "";
                  }
                  getCurrentSession().saveToLocalStorage();
                });
              },
              child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.portGore),
                    color: !signatureAvail ? AppColors.portGore : Colors.white,
                  ),
                  width: double.maxFinite,
                  margin: EdgeInsets.all(0),
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                        "Signature available: ${signatureAvail ? "Yes" : "No"}",
                        style: TextStyle(
                            fontFamily: 'poppins',
                            color:
                                !signatureAvail ? Colors.white : Colors.black)),
                  )),
            ),
            Divider(),
            if (signatureAvail) ...getSignatureWidgets(),
            TextButton(
              onPressed: () {
                List<InspectionItem> allItems = [];
                for (ReportCategories category in widget.reportingCategories) {
                  allItems.addAll(getCurrentSession().reportItems.where(
                      (element) => element.category == category.getName()));
                }
                if (signatureAvail) {
                  saveSignatureImage();
                }
                BillOfLading().generate(currentSession, allItems);
              },
              child: Row(
                children: [
                  Icon(Icons.print),
                  VerticalDivider(),
                  Text(
                    "Generate Bill of lading",
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
            Divider(),
            if (!widget.reportTabName
                .canUserEditTab(getCurrentSession().sessionStatus))
              Container()
            else
              Center(
                child: TextButton(
                  onPressed: () async {
                    if (signatureAvail) {
                      await saveSignatureImage();
                    }
                    getCurrentSession().saveToLocalStorage();
                    _showWarningDialog(context);
                  },
                  child: Container(
                    height: 40.0,
                    width: 160.0,
                    decoration: BoxDecoration(
                        color: AppColors.portGore,
                        borderRadius: BorderRadius.circular(16.0)),
                    child: Center(
                      child: Text(
                        "Submit",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future saveSignatureImage() async {
    signatureImage.data = await _controller.toPngBytes();
    signatureImage.image = await _controller.toImage();
    if (signatureImage.image == null || signatureImage.data == null) {
      return;
    }
    signatureImage.value = await LocalStorage.saveFile(
        ReportCategoryItems.SignatureImage.getName(),
        FileType.png,
        await _controller.toPngBytes());
  }

  void _showWarningDialog(context) {
    List<String> missingPictures = signatureAvail ? getMissingPicture() : [];
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              content: new SingleChildScrollView(
                  child: Container(
                      child: Column(children: <Widget>[
                SizedBox(
                  height: 10.0,
                ),
                Image.asset(
                  AppImages.missingError,
                  height: 50.0,
                  width: 70.0,
                ),
                Container(
                  height: 15.7,
                ),
                Container(
                    child: Text(
                  missingPictures.isEmpty
                      ? "You are about to submit your progress. You CANNOT UNDO this action."
                      : 'MISSING INFO IN THE FOLLOWING AREAS:',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                )),
                Container(
                  height: 20,
                ),
                Column(
                    children: missingPictures
                        .map((e) => DigitalInputErrorMenu(error: e))
                        .toList()),
              ]))),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(width: 8),
                    RectangularButton(
                        backgroundColor: AppColors.alizarinCrimson,
                        onTap: () {
                          for (ReportCategories category
                              in widget.reportingCategories) {
                            getCurrentSession().uploadReport(category);
                          }
                          if (widget.reportingCategories
                              .contains(ReportCategories.PICKUP_PICTURES)) {
                            copyInspectionItemValues(
                                src: getCurrentSession().reportItems.where(
                                    (element) =>
                                        element.category ==
                                        ReportCategories.PICKUP_PICTURES
                                            .getName()).toList(),
                                dst: getCurrentSession().reportItems.where(
                                    (element) =>
                                        element.category ==
                                        ReportCategories.DROP_OFF_PICTURES
                                            .getName()).toList());
                          }
                          Navigator.of(context).pop();
                          _showUploadDialog(context);
                        },
                        text: "PROCEED ANYWAY".padLeft(18).padRight(24),
                        textColor: Colors.white),
                    Container(width: 16),
                    RectangularButton(
                        backgroundColor: AppColors.portGore,
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        text: "BACK".padLeft(10).padRight(16),
                        textColor: Colors.white),
                    Container(width: 16),
                  ],
                )
              ]);
        });
  }

  List<String> getMissingPicture() {
    List<String> missingItems = [];
    if (signatureImage.signaturePoints == null ||
        signatureImage.signaturePoints.length < 20) {
      missingItems.add("Signature");
    }
    if (customerName.value == null || customerName.value.isEmpty) {
      missingItems.add("Customer Name");
    }
    return missingItems;
  }

  void _showUploadDialog(context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            if (uploadTimer == null) {
              uploadTimer = new Timer.periodic(Duration(seconds: 1), (Timer t) {
                print('Timer Finished');
                setState(() {
                  print(uploadProgress);
                  uploadProgress = getCurrentSession().getUploadProgress();
                  if (uploadProgress == 100) {
                    uploadTimer.cancel();
                    Modular.to.popAndPushNamed('/home');
                  }
                  uploadProgress = min(uploadProgress, 100);
                });
              });
            }
            return SingleChildScrollView(
                child: Container(
                    color: Colors.white,
                    child: Column(children: <Widget>[
                      Container(
                        height: 15.7,
                      ),
                      Container(
                          child: Text(
                        'Uploading Report',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.portGore,
                        ),
                      )),
                      Container(
                        height: 20,
                      ),
                      new CircularPercentIndicator(
                        radius: 60.0,
                        lineWidth: 5.0,
                        percent: uploadProgress / 100,
                        center: new Text(
                          uploadProgress.toString() + "%",
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                        progressColor: Theme.of(context).colorScheme.secondary,
                      )
                    ])));
          }),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            ButtonWidget(
              buttonColor: ButtonColor.primary,
              color: Colors.white,
              width: 300,
              text: 'Continue Upload in Background',
              onTap: () {
                uploadTimer.cancel();
                Modular.to.popAndPushNamed('/home');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (uploadTimer != null) {
      if (uploadTimer.isActive) {
        uploadTimer.cancel();
      }
    }
  }

  List<Widget> getSignatureWidgets() {
    return [
      Text("Receiving customer's Name",
          style: TextStyle(fontFamily: 'poppins')),
      TextFormField(
        style: TextStyle(fontFamily: 'poppins', color: Colors.black),
        initialValue: customerName.value,
        enabled: widget.reportTabName
            .canUserEditTab(getCurrentSession().sessionStatus),
        onChanged: (String value) => customerName.value = value,
      ),
      Divider(
        height: 50,
      ),
      Text(
        "Please have receiver electronically sign below",
        style: TextStyle(fontFamily: 'poppins'),
      ),
      if (canUserEdit) ...[
        Signature(
          controller: _controller,
          height: 100,
          backgroundColor: Color(0xFFccdcf0),
        ),
        TextButton(
            onPressed: () {
              _controller.clear();
              savePoints();
            },
            child: Row(
              children: [
                Text(
                  "Clear",
                  style: TextStyle(color: AppColors.portGore),
                ),
                Icon(
                  Icons.clear,
                  color: AppColors.alizarinCrimson,
                  size: 16,
                ),
              ],
            )),
      ] else if (signatureImage.data != null && signatureImage.data.isNotEmpty)
        Image.memory(signatureImage.data)
      else
        Container(
            color: Colors.grey,
            padding: EdgeInsets.all(10),
            child: Center(
              child: Text(
                "No signature to show",
                style: TextStyle(color: Colors.black),
              ),
            )),
    ];
  }

  void copyInspectionItemValues(
      {@required List<InspectionItem> src,
      @required List<InspectionItem> dst}) {
    for (InspectionItem item in src) {
      dst
          .firstWhere((element) => element.name == item.name,
              orElse: () => InspectionItem())
          .value = item.value;
    }
    dev.log("Copied inspection items");
  }
}
