import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:sitter_app/drawers/parentDrawer.dart';
import 'package:intl/intl.dart';
import 'package:date_format/date_format.dart';
import 'package:sitter_app/screens/pickSitterPage/pickSitter.dart';
import 'package:http/http.dart' as http;
import 'package:sitter_app/size_config.dart';
import 'package:square_in_app_payments/in_app_payments.dart';
import 'package:square_in_app_payments/models.dart' as squareModels;

import '../../../globals.dart';
import '../../../materialColor.dart';
import '../../../shakeWidget.dart';

extension TimeOfDayExtension on TimeOfDay {
  TimeOfDay addHour(int hour) {
  // replacing the hour with the remainder of 24
    return this.replacing(hour: (this.hour + hour) % 24, minute: this.minute);
  }
}

class ParentHomePage extends StatefulWidget {
  @override
  _ParentHomePageState createState() => _ParentHomePageState();
}

class _ParentHomePageState extends State<ParentHomePage> {
  DateTime currentBackPressTime;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final FirebaseAuth auth = FirebaseAuth.instance;
  User user;
  var maxHourlyRate = '';
  ShakeXController shakeController;

  String errorText = '';


  String _hour, _minute, _time;

  String dateTime;

  DateTime selectedDate = DateTime.now().add(const Duration(hours: 1));

  TimeOfDay selectedStartTime = TimeOfDay.now().addHour(1);
  TimeOfDay selectedEndTime = TimeOfDay.now().addHour(2) ;

  DateTime startDateTime, endDateTime;

  TextEditingController _dateController = TextEditingController();
  TextEditingController _startTimeController = TextEditingController();
  TextEditingController _endTimeController = TextEditingController();

  DateTime currentDate = DateTime.now();

  bool checkedValue = false;

  String responsibilities;

  Future findSitters({nonce}) async {
    var token = await user.getIdToken();
    try {
      var response = await http.post(Uri.http('www.$urlPath', '/findSitters'),
          headers: {
            'VersionNumber': jsonEncode(versionNumber),
            'Content-Type': 'application/json',
            HttpHeaders.authorizationHeader: token,
          },
          body: jsonEncode({
            "startDateTime": startDateTime.toIso8601String(),
            'endDateTime': endDateTime.toIso8601String(),
            'responsibility': responsibilities,
            'emergencyBooking': checkedValue,
            'nonce': nonce,
            'maxHourlyRate': maxHourlyRate,
          })).timeout(const Duration(seconds: timeout));
      var jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return jsonResponse;
      } else if (response.statusCode == 500) {
        if(jsonResponse == 'need-update') {
          if (versionValid) {
            versionValid = false;
            showUpdateDialog(
              context,

            );
          }
        } else {
          final snackBar = SnackBar(
            content: Text(jsonResponse),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } else {
        print(response.body);
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Something went wrong. Please try again'),
        ),
      );
      print(error);
    }
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: currentDate,
        lastDate: DateTime(currentDate.year + 1));
    if (picked != null)
      setState(() {
        selectedDate = picked;
        _dateController.text = DateFormat('EEE, MMMM d').format(selectedDate);
      });
  }

  Future<Null> _selectStartTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: selectedStartTime,
    );
    if (picked != null)
      setState(() {
        selectedStartTime = picked;
        _hour = selectedStartTime.hour.toString();
        _minute = selectedStartTime.minute.toString();
        _time = _hour + ' : ' + _minute;
        _startTimeController.text = _time;
        _startTimeController.text = formatDate(
            DateTime(
                2019, 08, 1, selectedStartTime.hour, selectedStartTime.minute),
            [hh, ':', nn, " ", am]).toString();
      });
  }

  Future<Null> _selectEndTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: selectedEndTime,
    );
    if (picked != null)
      setState(() {
        selectedEndTime = picked;
        _hour = selectedEndTime.hour.toString();
        _minute = selectedEndTime.minute.toString();
        _time = _hour + ' : ' + _minute;
        _endTimeController.text = _time;
        _endTimeController.text = formatDate(
            DateTime(2019, 08, 1, selectedEndTime.hour, selectedEndTime.minute),
            [hh, ':', nn, " ", am]).toString();
      });
  }

  Future<void> _pay() async {
    await InAppPayments.setSquareApplicationId(
        'sq0idp-UT-WGaHR8QaL2C_NCkTyPg');
    await InAppPayments.startCardEntryFlow(
        onCardNonceRequestSuccess: _onCardEntryCardNonceRequestSuccess,
        onCardEntryCancel: _onCancelCardEntryFlow);
  }

  void _onCancelCardEntryFlow() {
    // Handle the cancel callback
  }

  void _onCardEntryCardNonceRequestSuccess(squareModels.CardDetails result) async {
    try {
      // take payment with the card nonce details
      // you can take a charge
      // await chargeCard(result);
      await findSitters(nonce: result.nonce);

      // payment finished successfully
      // you must call this method to close card entry
      // this ONLY apply to startCardEntryFlow, please don't call this method when use startCardEntryFlowWithBuyerVerification
      InAppPayments.completeCardEntry(
          onCardEntryComplete: _onCardEntryComplete);
    } catch (ex) {
      // payment failed to complete due to error
      // notify card entry to show processing error
      InAppPayments.showCardNonceProcessingError(ex.message);
    }
  }

  void _onCardEntryComplete() {
    // Update UI to notify user that the payment flow is finished successfully
  }

  @override
  void initState() {
    shakeController = ShakeXController();

    _dateController.text = DateFormat('EEE, MMMM d').format(DateTime.now().add(const Duration(hours: 1)));

    _startTimeController.text = formatDate(
        DateTime(2019, 08, 1, DateTime.now().hour + 1, DateTime.now().minute),
        [hh, ':', nn, " ", am]).toString();
    user = auth.currentUser;

    _endTimeController.text = formatDate(
        DateTime(2019, 08, 1, DateTime.now().hour + 2, DateTime.now().minute),
        [hh, ':', nn, " ", am]).toString();
    user = auth.currentUser;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);

    dateTime = DateFormat.yMd().format(DateTime.now());
    final theme = Theme.of(context);
    SizeConfig().init(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Find Sitter',
            style: TextStyle(color: materialColor(RosePink.primary)),
          ),
        ),
        drawer: ParentDrawer(0),
        body: Center(
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                      elevation: 2,
                      margin: EdgeInsets.all(15),
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Column(
                        children: [
                          Image(
                            image: AssetImage("assets/images/babyroom.jpg"),
                          ),
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Choose Date',
                                  style: TextStyle(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  margin:
                                      EdgeInsets.only(top: 10, bottom: 30),
                                  child: GestureDetector(
                                    onTap: () {
                                      _selectDate(context);
                                      FocusManager.instance.primaryFocus.unfocus();
                                    },
                                    child: TextFormField(
                                      style: TextStyle(fontSize: 17),
                                      enabled: false,
                                      keyboardType: TextInputType.text,
                                      controller: _dateController,
                                      decoration: InputDecoration(
                                        suffixIcon: Icon(
                                          Icons.calendar_today_rounded,
                                          color:
                                              materialColor(RosePink.primary),
                                        ),
                                        contentPadding: EdgeInsets.only(
                                            left: 20,
                                            top: 15,
                                            bottom: 15,
                                            right: 15),
                                        isDense: true,
                                        disabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(27),
                                            borderSide: BorderSide(
                                                color: materialColor(
                                                    RosePink.primary),
                                                width: 2)),
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  'Select Time',
                                  style: TextStyle(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  margin:
                                      EdgeInsets.only(top: 10, bottom: 30),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          _selectStartTime(context);
                                          FocusManager.instance.primaryFocus.unfocus();
                                        },
                                        child: SizedBox(
                                          width: getProportionateScreenWidth(
                                              139),
                                          child: TextFormField(
                                            style: TextStyle(fontSize: 15),
                                            enabled: false,
                                            keyboardType: TextInputType.text,
                                            controller: _startTimeController,
                                            decoration: InputDecoration(
                                              suffixIcon: Icon(
                                                Icons.access_time,
                                                color: materialColor(
                                                    RosePink.primary),
                                              ),
                                              contentPadding: EdgeInsets.only(
                                                left: 15,
                                                top: 10,
                                                bottom: 10,
                                              ),
                                              isDense: true,
                                              disabledBorder:
                                                  OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(27),
                                                      borderSide: BorderSide(
                                                          color: materialColor(
                                                              RosePink
                                                                  .primary),
                                                          width: 2)),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Text(
                                          "-",
                                          style: TextStyle(fontSize: 35),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          _selectEndTime(context);
                                          FocusManager.instance.primaryFocus.unfocus();
                                        },
                                        child: SizedBox(
                                          width: getProportionateScreenWidth(
                                              139),
                                          child: TextFormField(
                                            style: TextStyle(fontSize: 15),
                                            onEditingComplete: () => node.unfocus(),
                                            enabled: false,
                                            keyboardType: TextInputType.text,
                                            controller: _endTimeController,
                                            decoration: InputDecoration(
                                              suffixIcon: Icon(
                                                Icons.access_time,
                                                color: materialColor(
                                                    RosePink.primary),
                                              ),
                                              contentPadding: EdgeInsets.only(
                                                left: 15,
                                                top: 10,
                                                bottom: 10,
                                              ),
                                              isDense: true,
                                              disabledBorder:
                                                  OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(27),
                                                      borderSide: BorderSide(
                                                          color: materialColor(
                                                              RosePink
                                                                  .primary),
                                                          width: 2)),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '*Responsibilities for Babysitter',
                                  style: TextStyle(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                    top: 10,
                                  ),
                                  child: TextFormField(
                                    keyboardType: TextInputType.multiline,
                                    onEditingComplete: () => node.unfocus(),
                                    maxLines: null,
                                    onChanged: (value) {
                                      responsibilities = value;
                                    },
                                    decoration: InputDecoration(
                                      isDense: true,
                                      hintText:
                                          'e.g. bath time, putting kids to bed',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(27)),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(27),
                                          borderSide: BorderSide(
                                              color: materialColor(
                                                  RosePink.primary),
                                              width: 2)),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(top: 6, bottom: 8),
                                  child: CheckboxListTile(
                                    title:
                                    Text('Emergency Booking', style: TextStyle( fontSize: 16),),
                                    value: checkedValue,
                                    onChanged: (newValue) {
                                      setState(() {
                                        checkedValue = newValue;
                                        maxHourlyRate = '';
                                      });
                                    },
                                    contentPadding: EdgeInsets.only(left: 5, bottom: 0),
                                    visualDensity: VisualDensity.compact,
                                    controlAffinity: ListTileControlAffinity
                                        .leading, //  <-- leading Checkbox
                                    dense: true,
                                  ),
                                ),
                                if(checkedValue)
                                  Container(
                                  margin: EdgeInsets.only(bottom: 15),
                                  child: TextFormField(
                                    textInputAction: TextInputAction.done,
                                    onEditingComplete: () => node.unfocus(),
                                    inputFormatters: [
                                      MaskTextInputFormatter(
                                        mask: '\$#####',
                                        filter: {"#": RegExp(r'[0-9.]')},
                                        type: MaskAutoCompletionType.lazy,
                                      )
                                    ],
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      if(value.isNotEmpty) {
                                       maxHourlyRate = value.substring(1,);
                                      } else {
                                        maxHourlyRate = value;
                                      }
                                    },
                                    decoration: InputDecoration(
                                      isDense: true,
                                      hintText:
                                      'Max Hourly Rate',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(27)),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(27),
                                          borderSide: BorderSide(
                                              color: materialColor(
                                                  RosePink.primary),
                                              width: 2)),
                                    ),
                                  ),
                                ),
                                ShakeX(
                                  child: errorText != '' ?
                                    Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: Text(
                                        errorText,
                                        textAlign: TextAlign.center,
                                        style:
                                            TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  )
                                  : null,
                                  controller: shakeController,
                                ),
                                Container(
                                  margin: EdgeInsets.only(bottom: 5),
                                  height: 52.0,
                                  child: RaisedButton(
                                    onPressed: () async {
                                      startDateTime = DateTime(selectedDate.year, selectedDate.month,
                                          selectedDate.day, selectedStartTime.hour, selectedStartTime.minute, 59);
                                      if (selectedEndTime.hour < selectedStartTime.hour) {
                                        endDateTime = DateTime(selectedDate.year, selectedDate.month,
                                            selectedDate.day + 1, selectedEndTime.hour, selectedEndTime.minute, 59);
                                      } else {
                                        endDateTime = DateTime(selectedDate.year, selectedDate.month,
                                            selectedDate.day, selectedEndTime.hour, selectedEndTime.minute, 59);
                                      }
                                      if(checkedValue) {
                                        if (maxHourlyRate == null || maxHourlyRate.isEmpty || !maxHourlyRate.contains(RegExp(r'[0-9]'))) {
                                          setState(() {
                                            errorText =
                                            'Max Hourly Rate must be filled out';
                                          });
                                          shakeController.shake();
                                        } else if (endDateTime
                                            .difference(startDateTime)
                                            .inHours < 1) {
                                          setState(() {
                                            errorText =
                                            'Babysitting job has to be at least 1 hour';
                                          });
                                          shakeController.shake();
                                        } else if (startDateTime
                                            .difference(DateTime.now())
                                            .inMinutes <= 0) {
                                          setState(() {
                                            errorText =
                                            'Babysitting job can\'t be created earlier than current time';
                                          });
                                          shakeController.shake();
                                        } else {
                                          await _pay();
                                        }

                                      } else {
                                        if (endDateTime
                                            .difference(startDateTime)
                                            .inHours < 1) {
                                          setState(() {
                                            errorText =
                                            'Babysitting job has to be at least 1 hour';
                                          });
                                          shakeController.shake();
                                        } else if (startDateTime
                                            .difference(DateTime.now())
                                            .inHours < 1) {
                                          setState(() {
                                            errorText =
                                            'Babysitting job has to be created at least an hour in advanced';
                                          });
                                          shakeController.shake();
                                        }
                                        else {
                                          setState(() {
                                            errorText = '';
                                          });
                                          formKey.currentState.save();
                                          var jobId = await findSitters();
                                          if (jobId != null) {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (
                                                    BuildContext context) =>
                                                    PickSitterPage(jobId),
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    },
                                    padding: EdgeInsets.all(0.0),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(75.0)),
                                    child: Ink(
                                      decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              materialColor(RosePink.primary),
                                              materialColor(
                                                  RosePink.primary)[100]
                                            ],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(28.0)),
                                      child: Container(
                                        alignment: Alignment.center,
                                        child: Text(
                                          'FIND SITTER',
                                          style: TextStyle(
                                              fontSize: 18.5,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )),
                  // RaisedButton(
                  //   onPressed: () => _selectDate(context),
                  //   child: Text('ff'),
                  // ),
                ],
              ),
            ),
          ),
        ));
  }
}
