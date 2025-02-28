import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:heartless/backend/services/activity/date_service.dart';
import 'package:heartless/services/exceptions/app_exceptions.dart';
import 'package:heartless/shared/models/activity.dart';

class ActivityService {
  // mark as completed
  Future<bool> markAsCompleted(String activityId, String patientId) async {
    // activity can be marked as completed only if it belongs to the current week
    DateTime startOfWeek = DateService.getStartOfWeekOfDate(DateTime.now());
    try {
      await FirebaseFirestore.instance
          .collection('Patients')
          .doc(patientId)
          .collection("WeeklyData")
          .doc(startOfWeek.toString())
          .collection('Activities')
          .doc(activityId)
          .update({'status': Status.completed.index}).timeout(
              DateService.timeLimit);
      return true;
    } on FirebaseAuthException {
      throw UnAutherizedException();
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    } on TimeoutException {
      throw ApiNotRespondingException('Server is not responding');
    }
  }

  // to add an activity
  Future<Activity> addActivity(Activity activity) async {
    try {
      DateTime startOfWeek = DateService.getStartOfWeekOfDate(activity.time);
      DocumentReference documentReference = FirebaseFirestore.instance
          .collection('Patients')
          .doc(activity.patientId)
          .collection("WeeklyData")
          .doc(startOfWeek.toString())
          .collection('Activities')
          .doc();
      // getting the id for the new activity from the reference
      activity.id = documentReference.id;
      await documentReference
          .set(activity.toMap())
          .timeout(DateService.timeLimit);
      return activity;
    } on FirebaseAuthException {
      throw UnAutherizedException();
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    } on TimeoutException {
      throw ApiNotRespondingException('Server is not responding');
    }
  }

  // to edit an activity
  Future<bool> editActivity(Activity activity) async {
    try {
      if (activity.id == '') {
        return false;
      }
      DateTime startOfWeek = DateService.getStartOfWeekOfDate(activity.time);
      await FirebaseFirestore.instance
          .collection('Patients')
          .doc(activity.patientId)
          .collection("WeeklyData")
          .doc(startOfWeek.toString())
          .collection('Activities')
          .doc(activity.id)
          .update(activity.toMap())
          .timeout(DateService.timeLimit);
      return true;
    } on FirebaseAuthException {
      throw UnAutherizedException();
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    } on TimeoutException {
      throw ApiNotRespondingException('Server is not responding');
    }
  }

  // to delete an activity
  Future<bool> deleteActivity(Activity activity) async {
    try {
      if (activity.id == '') {
        return false;
      }
      DateTime startOfWeek = DateService.getStartOfWeekOfDate(activity.time);
      await FirebaseFirestore.instance
          .collection('Patients')
          .doc(activity.patientId)
          .collection("WeeklyData")
          .doc(startOfWeek.toString())
          .collection('Activities')
          .doc(activity.id)
          .delete()
          .timeout(DateService.timeLimit);
      return true;
    } on FirebaseAuthException {
      throw UnAutherizedException();
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    } on TimeoutException {
      throw ApiNotRespondingException('Server is not responding');
    }
  }

  // to get all activities of the day
  static Stream<QuerySnapshot> getAllActivitiesOfTheDate(
      DateTime date, String patientId) {
    DateTime startOfWeek = DateService.getStartOfWeekOfDate(date);
    DateTime startOfDay = DateService.getStartOfDay(date);
    return FirebaseFirestore.instance
        .collection('Patients')
        .doc(patientId)
        .collection("WeeklyData")
        .doc(startOfWeek.toString())
        .collection('Activities')
        .where('time', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('time',
            isLessThan:
                Timestamp.fromDate(startOfDay.add(const Duration(days: 1))))
        .snapshots();
  }

  // to get update the activity status according to the time
  static Future<bool> updateActivityStatus(String patientId) async {
    // get the Datetime with for the start of the week
    DateTime startOfWeek = DateService.getStartOfWeekOfDate(DateTime.now());

    try {
      // get all the activities with status upcoming
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Patients')
          .doc(patientId)
          .collection("WeeklyData")
          .doc(startOfWeek.toString())
          .collection('Activities')
          .where('status', isEqualTo: Status.upcoming.index)
          .where('time',
              isLessThan: Timestamp.fromDate(DateTime.now().add(const Duration(
                  minutes: -10)))) //! giving a buffer time of 10 minutes
          .get()
          .timeout(DateService.timeLimit);

      // check if the time of the activity is before the current time
      for (var element in querySnapshot.docs) {
        Activity activity =
            Activity.fromMap(element.data() as Map<String, dynamic>);
        if (activity.time.isBefore(DateTime.now())) {
          await FirebaseFirestore.instance
              .collection('Patients')
              .doc(patientId)
              .collection("WeeklyData")
              .doc(element.id)
              .update({'status': Status.missed.index}).timeout(
                  DateService.timeLimit);
        }
      }
      return true;
    } on FirebaseAuthException {
      throw UnAutherizedException();
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    } on TimeoutException {
      throw ApiNotRespondingException('Server is not responding');
    }
  }

  // to get all completed activities of the day
  static Stream<QuerySnapshot> getCompletedActivitiesOftheDay(
      DateTime dateTime, String patientId) {
    DateTime startOfWeek = DateService.getStartOfWeekOfDate(dateTime);
    DateTime startOfDay = DateService.getStartOfDay(dateTime);
    return FirebaseFirestore.instance
        .collection('Patients')
        .doc(patientId)
        .collection("WeeklyData")
        .doc(startOfWeek.toString())
        .collection('Activities')
        .where('time', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('time',
            isLessThan:
                Timestamp.fromDate(startOfDay.add(const Duration(days: 1))))
        .where('status', isEqualTo: Status.completed.index)
        .snapshots();
  }

  // to get all upcoming activities of the day
  static Stream<QuerySnapshot> getUpcomingActivitiesOftheDay(
      DateTime dateTime, String patientId) {
    DateTime startOfWeek = DateService.getStartOfWeekOfDate(dateTime);
    DateTime startOfDay = DateService.getStartOfDay(dateTime);
    return FirebaseFirestore.instance
        .collection('Patients')
        .doc(patientId)
        .collection("WeeklyData")
        .doc(startOfWeek.toString())
        .collection('Activities')
        .where('time', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('time',
            isLessThan:
                Timestamp.fromDate(startOfDay.add(const Duration(days: 1))))
        .where('status', isEqualTo: Status.upcoming.index)
        .snapshots();
  }

  // to get all missed activities of the day
  static Stream<QuerySnapshot> getMissedActivitiesOftheDay(
      DateTime dateTime, String patientId) {
    DateTime startOfWeek = DateService.getStartOfWeekOfDate(dateTime);
    DateTime startOfDay = DateService.getStartOfDay(dateTime);
    return FirebaseFirestore.instance
        .collection('Patients')
        .doc(patientId)
        .collection("WeeklyData")
        .doc(startOfWeek.toString())
        .collection('Activities')
        .where('time', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('time',
            isLessThan:
                Timestamp.fromDate(startOfDay.add(const Duration(days: 1))))
        .where('status', isEqualTo: Status.missed.index)
        .snapshots();
  }

  // to get all the activities for a given period
  static Stream<QuerySnapshot> getAllActivitiesForAWeek(
      DateTime date, String patientId) {
    DateTime startOfWeek = DateService.getStartOfWeekOfDate(date);
    return FirebaseFirestore.instance
        .collection('Patients')
        .doc(patientId)
        .collection("WeeklyData")
        .doc(startOfWeek.toString())
        .collection('Activities')
        .snapshots();
  }
}
