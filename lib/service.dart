import 'package:socket_io_client/socket_io_client.dart' as IO;

class ApiConfig {
  //dev server
  // static const String baseUrl = 'http://13.233.108.0:6002/';
  // static const String socket = 'http://13.233.108.0:6002';

  //client server
  // static const String baseUrl = 'http://13.126.45.34:6002/';
  // static const String socket = 'http://13.126.45.34:6002';

  //new server
  // static const String baseUrl = 'http://newelb-885227103.ap-south-1.elb.amazonaws.com:6002/';
  // static const String socket = 'http://newelb-885227103.ap-south-1.elb.amazonaws.com:6002';

  //Test server
  static const String baseUrl ='http://awseb--awseb-6atjymbpqxcu-1588189131.ap-south-1.elb.amazonaws.com:6002/';
     // 'http://shepower.ap-south-1.elasticbeanstalk.com:6002/';
  static const String socket = 'http://awseb--awseb-6atjymbpqxcu-1588189131.ap-south-1.elb.amazonaws.com:6002';
}

class imagespath {
  // //dev
  // static const String baseUrl =
  //     'https://shepoerbucket2.s3.ap-south-1.amazonaws.com/images/';

  // client
  static const String baseUrl =
      'https://shepowerbucket02.s3.ap-south-1.amazonaws.com/images/';
}

class pdfpath {
  //dev
  // static const pthUrl =
  //     'https://shepoerbucket2.s3.ap-south-1.amazonaws.com/images/'; 

  //client
  static const String baseUrl =
      'https://shepowerbucket02.s3.ap-south-1.amazonaws.com/images/';
}

//dev
//final socket = IO.io('http://13.233.108.0:6002');

//client
//  final socket = IO.io('http://13.126.45.34:6002');

//newurl
// final socket = IO.io('http://newelb-885227103.ap-south-1.elb.amazonaws.com:6002');

//text url
final socket = IO.io('http://awseb--awseb-6atjymbpqxcu-1588189131.ap-south-1.elb.amazonaws.com:6002');

class PaymentKey {
  static const String apiKey = 'rzp_test_1d8Uz0Rqn101Hj';
}

class genderdetection {
  static const String detectAPIUrl = 'https://api.luxand.cloud/photo/detect';
  static const String token = '750e44aa21794b8fa5de1b20b2775ded';
}

// old one 925f1eb1f75446e8a3a49f8104a4339b


// final socket = IO.io("http://15.207.242.57:3000", <String, dynamic>{
//   "transports": ["websocket"],
//   "autoConnect": false,
//   "timeout": 30000,
// });


