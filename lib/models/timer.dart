final String tableTimer = 'timer';
final String columnId = '_id';
final String columnHours = 'hours';
final String columnMinutes = 'minutes';
final String columnSeconds = 'seconds';
final String columnMultiTimer = 'multitimer';
final String columnDisplayOrder = 'displayOrder';


class Timer{
  int id;
  int hours;
  int minutes;
  int seconds;
  int multitimer;
  int displayOrder;

  Timer({this.hours, this.minutes, this.seconds});

  Timer.fromMap(Map<String, dynamic> map){
    id = map[columnId];
    hours = map[columnHours];
    minutes = map[columnMinutes];
    seconds = map[columnSeconds];
    multitimer = map[columnMultiTimer];
    displayOrder = map[columnDisplayOrder];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnHours: hours,
      columnMinutes: minutes,
      columnSeconds: seconds,
    };
    if (id != null){
      map[columnId] = id;
    }
    if (multitimer != null){
      map[columnMultiTimer] = multitimer;
    }
    if (displayOrder != null){
      map[columnDisplayOrder] = displayOrder;
    }
    return map;
  }

  String toString(){
    return '$hours h : $minutes m : $seconds s';
  }

  String getDisplayString(){
    String hourString = hours.toString().padLeft(2, '0');
    String minuteString = minutes.toString().padLeft(2, '0');
    String secondString = minutes.toString().padLeft(2, '0');
    return '$hourString : $minuteString : $secondString';
  }

  void decrementBySecond(){
    if (seconds != 0){
      seconds -= 1;
    } else{
      if (minutes != 0){
        minutes -= 1;
        seconds = 59;
      } else {
        if (hours != 0){
          hours -= 1;
          minutes = 59;
          seconds = 59;
        }
      }
    }
  }

  int getTotalSeconds(){
    return hours*3600 + minutes*60 + seconds;
  }
}