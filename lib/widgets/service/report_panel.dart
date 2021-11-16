import 'package:flutter/material.dart';
import 'package:transportation_mobile_app/utils/app_images.dart';

class VehiclePanelReport extends StatefulWidget {
  const VehiclePanelReport({
    Key key,
    @required this.sideName,
  }) : super(key: key);

  final String sideName;

  @override
  State<VehiclePanelReport> createState() => _VehiclePanelReportState();
}

class _VehiclePanelReportState extends State<VehiclePanelReport> {
  List<Map<String, String>> issues = [];
  Map<String, List<Map<String, double>>> dotCoordinates = {
    "left": [
      {"markNumber": 1, "top": 100, "left": 0},
      {"markNumber": 2, "top": 100, "left": 120},
      {"markNumber": 3, "top": 100, "left": 200},
      {"markNumber": 4, "top": 70, "left": 290},
      {"markNumber": 5, "top": 105, "left": 305},
      {"markNumber": 6, "top": 100, "left": 40},
      {"markNumber": 7, "top": 100, "left": 260},
      {"markNumber": 8, "top": 50, "left": 140},
      {"markNumber": 8, "top": 50, "left": 200},
    ],
    "back": [
      {"markNumber": 1, "top": 100, "left": 0},
      {"markNumber": 2, "top": 100, "left": 120},
      {"markNumber": 3, "top": 100, "left": 50},
      {"markNumber": 4, "top": 100, "left": 150},
    ],
    "right": [
      {"markNumber": 1, "top": 100, "left": 0},
      {"markNumber": 2, "top": 100, "left": 120},
      {"markNumber": 3, "top": 100, "left": 50},
      {"markNumber": 4, "top": 100, "left": 150},
    ],
    "front": [
      {"markNumber": 1, "top": 100, "left": 0},
      {"markNumber": 2, "top": 100, "left": 120},
      {"markNumber": 3, "top": 100, "left": 50},
      {"markNumber": 4, "top": 100, "left": 150},
    ],
    "top": [
      {"markNumber": 1, "top": 100, "left": 0},
      {"markNumber": 2, "top": 100, "left": 120},
      {"markNumber": 3, "top": 100, "left": 50},
      {"markNumber": 4, "top": 100, "left": 150},
    ]
  };

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [

        Center(
          child: Image.asset(
            AppImages.report_issues_base + widget.sideName + ".png",
            height: 200,
          ),
        ),
        ...dotCoordinates[widget.sideName]
            .map((Map<String, double> e) => Positioned(
                  top: e["top"],
                  left: e["left"],
                  child: IssueButtonMenu(
                      allIssues: this.issues,
                      sideName: widget.sideName,
                      markNumber: e["markNumber"]),
                ))
            .toList(),
        ElevatedButton(onPressed: ()=> setState(() {
          dotCoordinates[widget.sideName] = dotCoordinates[widget.sideName];
        }), child: Text("Refresh")),
      ],
    );
  }
}

class IssueButtonMenu extends StatefulWidget {
  IssueButtonMenu({
    Key key,
    @required this.allIssues,
    @required String sideName,
    @required double markNumber,
  })  : panelName = "${sideName}_$markNumber",
        super(key: key);

  final List<Map<String, String>> allIssues;
  final String panelName;

  @override
  State<IssueButtonMenu> createState() => _IssueButtonMenuState();
}

class _IssueButtonMenuState extends State<IssueButtonMenu> {
  IssueTypes _issueSelected = IssueTypes.none;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: 40,
      child: TextButton(
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
              color: widget.allIssues.any((Map<String, String> element) =>
                      element["name"] == widget.panelName)
                  ? Colors.red
                  : Colors.grey,
              shape: BoxShape.circle),
        ),
        onPressed: () async {
          IssueTypes issueSel = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Issue types'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: IssueTypes.values
                          .map((IssueTypes e) => ListTile(
                                onTap: () => setState(() {
                                  _issueSelected = e;
                                  Navigator.pop(context, e);
                                }),
                                title: Text(
                                  e.getName(),
                                  style: TextStyle(color: Colors.black),
                                ),
                                leading: Radio<IssueTypes>(
                                  value: e,
                                  groupValue: _issueSelected,
                                  onChanged: (IssueTypes value) {
                                    setState(() {
                                      _issueSelected = value;
                                    });
                                    Navigator.pop(context, value);
                                  },
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                );
              });
          if (issueSel == IssueTypes.none) {
            widget.allIssues.removeWhere((Map<String, String> element) =>
                element['name'] == widget.panelName);
            return;
          }
          widget.allIssues.add(
              {"name": widget.panelName, "value": issueSel.getAbbreviation()});
        },
      ),
    );
  }
}

enum IssueTypes {
  none,
  b,
  bb,
  br,
  c,
  cr,
  d,
  f,
  ff,
  l,
  m,
  pc,
  r,
  ru,
  s,
  ss,
  st,
  t
}

extension on IssueTypes {
  String getName() {
    switch (this) {
      case IssueTypes.b:
        return "Bent";
      case IssueTypes.bb:
        return "Buffer Burned";
      case IssueTypes.br:
        return "Broken";
      case IssueTypes.c:
        return "Cut";
      case IssueTypes.cr:
        return "Cracked";
      case IssueTypes.d:
        return "Dented";
      case IssueTypes.f:
        return "Faded";
      case IssueTypes.ff:
        return "Foreign Fluid";
      case IssueTypes.l:
        return "Loose";
      case IssueTypes.m:
        return "Mission";
      case IssueTypes.pc:
        return "Paint Chip";
      case IssueTypes.r:
        return "Rubble";
      case IssueTypes.ru:
        return "Rust";
      case IssueTypes.s:
        return "Scratched";
      case IssueTypes.ss:
        return "Surface Scratch";
      case IssueTypes.st:
        return "Stained";
      case IssueTypes.t:
        return "Torn";
      case IssueTypes.none:
        return "No issues";
      default:
        return "Other";
    }
  }

  String getAbbreviation() {
    switch (this) {
      case IssueTypes.b:
        return "B";
      case IssueTypes.bb:
        return "BB";
      case IssueTypes.br:
        return "BR";
      case IssueTypes.c:
        return "C";
      case IssueTypes.cr:
        return "CR";
      case IssueTypes.d:
        return "D";
      case IssueTypes.f:
        return "F";
      case IssueTypes.ff:
        return "F";
      case IssueTypes.l:
        return "L";
      case IssueTypes.m:
        return "M";
      case IssueTypes.pc:
        return "PC";
      case IssueTypes.r:
        return "R";
      case IssueTypes.ru:
        return "RU";
      case IssueTypes.s:
        return "S";
      case IssueTypes.ss:
        return "SS";
      case IssueTypes.st:
        return "ST";
      case IssueTypes.t:
        return "T";
      case IssueTypes.none:
        return "NONE";
      default:
        return "OTHER";
    }
  }
}
