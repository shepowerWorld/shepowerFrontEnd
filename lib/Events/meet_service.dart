import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/auth_io.dart';

class EventData {
  String summary;
  String description;
  DateTime startDateTime;
  DateTime endDateTime;

  EventData(
      {required this.summary,
      required this.description,
      required this.startDateTime,
      required this.endDateTime});
}

class MeetService {
  static final _googleSignIn = GoogleSignIn(
    scopes: <String>[calendar.CalendarApi.calendarScope],
  );

  static calendar.EventDateTime _getEventTime(DateTime date) {
    return calendar.EventDateTime(dateTime: date, timeZone: "GMT+05:30");
  }

  static Future<String?> getLink(EventData data) async {
    await _googleSignIn.signIn();

    AuthClient? httpClient = (await _googleSignIn.authenticatedClient());
    assert(httpClient != null, 'Authenticated client missing!');
    var calendarApi = calendar.CalendarApi(httpClient!);

    calendar.ConferenceData conferenceData = calendar.ConferenceData();
    calendar.CreateConferenceRequest conferenceRequest =
        calendar.CreateConferenceRequest();

    conferenceRequest.requestId =
        "${data.startDateTime.millisecondsSinceEpoch}-${data.endDateTime.millisecondsSinceEpoch}";
    conferenceData.createRequest = conferenceRequest;

    // Create an event.
    final event = calendar.Event()
      ..summary = data.summary
      ..description = data.description
      ..conferenceData = conferenceData
      ..start = _getEventTime(data.startDateTime)
      ..end = _getEventTime(data.endDateTime);

    String calendarId = "primary";
    final createdEvent = await calendarApi.events.insert(event, calendarId,
        conferenceDataVersion: 1, sendUpdates: "all");
    final joinLink = createdEvent.conferenceData?.conferenceId ?? "";
    print("https://meet.google.com/$joinLink");
    return "https://meet.google.com/$joinLink";
  }
}
