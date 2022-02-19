import 'package:newsafer/tool/api_tool.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:location/location.dart';

void backgroundFetchHeadlessTask(HeadlessTask task) async {
  String taskId = task.taskId;
  bool isTimeout = task.timeout;
  if (isTimeout) {
    // This task has exceeded its allowed running-time.
    // You must stop what you're doing and immediately .finish(taskId)
    print("[BackgroundFetch] Headless task timed-out: $taskId");
    BackgroundFetch.finish(taskId);
    return;
  }
  print('[BackgroundFetch] Headless event received.');
  // Do your work here...
  LocationData locationdata = await Location().getLocation();
  ApiTool.postlocation(locationdata.latitude, locationdata.longitude);
  BackgroundFetch.finish(taskId);
}
