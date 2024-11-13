// ignore_for_file: non_constant_identifier_names, dead_code
import 'dart:io';
// import 'dart:nativewrappers/_internal/vm/lib/math_patch.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:video_call/common/joining_details/joining_details.dart';
import 'package:video_call/utils/api.dart';
import 'package:video_call/utils/custom_text.dart';
import 'package:videosdk/videosdk.dart';

import '../../constants/colors.dart';
import '../../utils/spacer.dart';
import '../../utils/toast.dart';
import 'one_to_one_meeting_screen.dart';

// Join Screen
class JoinScreen extends StatefulWidget {
  var username;
  var meetingId;
   JoinScreen({Key? key,required this.username,this.meetingId}) : super(key: key);

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  String _token = "";

  // Control Status
  bool isMicOn = true;
  bool isCameraOn = true;

  CustomTrack? cameraTrack;
  RTCVideoRenderer? cameraRenderer;

  bool? isJoinMeetingSelected;
  bool? isCreateMeetingSelected;

  @override
  void initState() {
    initCameraPreview();
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final token = await fetchToken(context);
      setState(() => _token = token);
    });
  }

  @override
  setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
        onWillPop: _onWillPopScope,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Join meeting"),
          ),
          backgroundColor:  Colors.white,
          body: 
                 SingleChildScrollView(
                   child: Container(
                     padding: EdgeInsets.all(30),
                     child: 
                         // Camera Preview
                       
                               Column(
                                 // alignment: Alignment.topCenter,
                                 crossAxisAlignment: CrossAxisAlignment.stretch,
                                 children: [
                                  //  Text("Start Meetings",style: TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.w900),),
                               SizedBox(height: 10,),
                                     
                                      
                                       
                                            cameraRenderer != null
                                               ? Container(
                                                width: MediaQuery.of(context).size.width/2,
                                                 height: MediaQuery.of(context).size.height/3,
                                                 child: ClipRRect(
                                                     borderRadius:
                                                         BorderRadius.circular(12),
                                                     child: RTCVideoView(
                                                       cameraRenderer
                                                           as RTCVideoRenderer,
                                                       objectFit: RTCVideoViewObjectFit
                                                           .RTCVideoViewObjectFitCover,
                                                     ),
                                                   ),
                                               )
                                               : Container(
                                                 width: MediaQuery.of(context).size.width/2,
                                                 height: MediaQuery.of(context).size.height/3,
                                                 padding: EdgeInsets.all(40),
                                                   decoration: BoxDecoration(
                                                       // color: black800,
                                                       border: Border.all(color: Colors.grey),
                                                       borderRadius:
                                                           BorderRadius.circular(
                                                               12)),
                                                   child:  Center(
                                                     child: Image.asset(
                                                       "packages/video_call/assets/image.png",
                                                     ),
                                                   ),
                                                 ),
                                         
                               SizedBox(height: 10,),
                               Center(
                                 child: Row(
                                   mainAxisAlignment: MainAxisAlignment.center,
                                   children: [
                                        ElevatedButton(
                                       onPressed: () {
                                         if (isCameraOn) {
                                           disposeCameraPreview();
                                         } else {
                                           initCameraPreview();
                                         }
                                         setState(() =>
                                             isCameraOn = !isCameraOn);
                                       },
                                       style: ElevatedButton.styleFrom(
                                         shape: const RoundedRectangleBorder(),
                                         // padding: EdgeInsets.all(
                                         //   ResponsiveValue<double>(context,
                                         //       conditionalValues: [
                                         //         Condition.equals(
                                         //             name: MOBILE,
                                         //             value: 6),
                                         //         Condition.equals(
                                         //             name: TABLET,
                                         //             value: 15),
                                         //         Condition.equals(
                                         //             name: DESKTOP,
                                         //             value: 18),
                                         //       ]).value!,
                                         // ),
                                         backgroundColor: 
                                              Color(0xFFd9d9d9)
                                             ,
                                       ),
                                       child: Icon(
                                         isCameraOn
                                             ? Icons.videocam_outlined
                                             : Icons.videocam_off_outlined,
                                         color: 
                                              Colors.black
                                             
                                       ),
                                     ),
                                  SizedBox(width: 10,),
                                     // Mic Action Button
                                     ElevatedButton(
                                       onPressed: () => setState(
                                         () => isMicOn = !isMicOn,
                                       ),
                                       style: ElevatedButton.styleFrom(
                                         shape: const RoundedRectangleBorder(),
                                         // padding: EdgeInsets.all(
                                           // ResponsiveValue<double>(context,
                                           //     conditionalValues: [
                                           //       Condition.equals(
                                           //           name: MOBILE,
                                           //           value: 6),
                                           //       Condition.equals(
                                           //           name: TABLET,
                                           //           value: 15),
                                           //       Condition.equals(
                                           //           name: DESKTOP,
                                           //           value: 18),
                                           //     ]).value!,
                                         // ),
                                         backgroundColor:
                                              Color(0xFFd9d9d9),
                                         foregroundColor: Colors.black,
                                       ),
                                       child: Icon(
                                           isMicOn
                                               ? Icons.mic_outlined
                                               : Icons.mic_off_outlined,
                                           color: isMicOn
                                               ? Colors.black
                                               : Colors.black),
                                     ),
                                   ],
                                 ),
                               ),
                               
                       SizedBox(height: 20),
                                CustomText.boldinfoText("Instructions :"),
                       SizedBox(height: 8),
                     
                       CustomText.infoText('1. Make sure your camera is properly working.\n2. Ensure your voice is clearly audible.\n3. Keep your original documents in hand.\n4.When ready, tap the "Start" button to start the meeting.'),
                                                       
                        TextButton(
                         child:CustomText.taskBtnText("Start"),
                           onPressed: (){
                       //  JoiningDetails(
                       //                                   isCreateMeeting: false,
                       //                                   onClickMeetingJoin: (meetingId, callType,
                       //                                           displayName) =>
                                       _onClickMeetingJoin(
                                           widget.meetingId, "ONE_TO_ONE", widget.username);
                                 // );
                         },
                         style: TextButton.styleFrom(
                             padding: const EdgeInsets.all(16),
                             shape: RoundedRectangleBorder(
                               borderRadius: BorderRadius.circular(10.0),
                             ),
                             foregroundColor: Colors.black,
                             backgroundColor: Colors.black,
                             // minimumSize: const Size(100, 30),
                             elevation: 0,
                             shadowColor: Colors.black),
                       
                        ),
                                                       ],
                   
                   
                           ),
                         )
                       
                     ),
                   ),
                 )
            ;  }

      
  

  Future<bool> _onWillPopScope() async {
    if (isJoinMeetingSelected != null && isCreateMeetingSelected != null) {
      setState(() {
        isJoinMeetingSelected = null;
        isCreateMeetingSelected = null;
      });
      return false;
    } else {
      return true;
    }
  }

  void initCameraPreview() async {
    CustomTrack track = await VideoSDK.createCameraVideoTrack();
    RTCVideoRenderer render = RTCVideoRenderer();
    await render.initialize();
    render.setSrcObject(stream: track.mediaStream, trackId: track.mediaStream.getVideoTracks().first.id);
    setState(() {
      cameraTrack = track;
      cameraRenderer = render;
    });
  }

  void disposeCameraPreview() {
    cameraTrack?.dispose();
    setState(() {
      cameraRenderer = null;
      cameraTrack = null;
    });
  }

  void _onClickMeetingJoin(meetingId, callType, displayName) async {
    if (displayName.toString().isEmpty) {
      displayName = "Guest";
    }
    // if (isCreateMeetingSelected!) {
      createAndJoinMeeting(callType, displayName);
    // } else {
    //   joinMeeting(callType, displayName, meetingId);
    // }
  }

  Future<void> createAndJoinMeeting(callType, displayName) async {
    try {
      var _meetingID = await createMeeting(_token);
      if (mounted) {
        disposeCameraPreview();
        // if (callType == "GROUP") {
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) => ConfereneceMeetingScreen(
        //         token: _token,
        //         meetingId: _meetingID,
        //         displayName: displayName,
        //         micEnabled: isMicOn,
        //         camEnabled: isCameraOn,
        //       ),
        //     ),
        //   );
        // } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OneToOneMeetingScreen(
                token: _token,
                meetingId: _meetingID,
                displayName: displayName,
                micEnabled: isMicOn,
                camEnabled: isCameraOn,
              ),
            ),
          );
        // }
      }
    } catch (error) {
      showSnackBarMessage(message: error.toString(), context: context);
    }
  }

  Future<void> joinMeeting(callType, displayName, meetingId) async {
    if (meetingId.isEmpty) {
      showSnackBarMessage(
          message: "Please enter Valid Meeting ID", context: context);
      return;
    }
    var validMeeting = await validateMeeting(_token, meetingId);
    if (validMeeting) {
      if (mounted) {
        disposeCameraPreview();
        // if (callType == "GROUP") {
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) => ConfereneceMeetingScreen(
        //         token: _token,
        //         meetingId: meetingId,
        //         displayName: displayName,
        //         micEnabled: isMicOn,
        //         camEnabled: isCameraOn,
        //       ),
        //     ),
        //   );
        // } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OneToOneMeetingScreen(
                token: _token,
                meetingId: meetingId,
                displayName: displayName,
                micEnabled: isMicOn,
                camEnabled: isCameraOn,
              ),
            ),
          );
        // }
      }
    } else {
      if (mounted) {
        showSnackBarMessage(message: "Invalid Meeting ID", context: context);
      }
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    cameraTrack?.dispose();
    super.dispose();
  }
}
