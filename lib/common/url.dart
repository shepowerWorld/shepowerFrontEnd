import 'package:Shepower/service.dart';

class Url {
  static const String baseUrl = '${ApiConfig.baseUrl}';
  //Events
  static const String myEvent = "${baseUrl}myEvents";
  static const String allEvent = "${baseUrl}AllEvents";
  //Dashboard

  //Chat
  static const String getAllGroups = '${baseUrl}getAllGroups';
  static const String joinGroups = '${baseUrl}joingroup';
  static const String deleteRoom = '${baseUrl}deleteroom';
  static const String deletePerson = '${baseUrl}deleteperson';
  static const String exitGroup = "${baseUrl}exitgroup";
  static const String createGroup = "${baseUrl}creategroup";
  static const String viewGroupInfo = "${baseUrl}viewgroupinfo";
  static const String updateProfileGroup = "${baseUrl}updateProfilegroup";
  static const String updateGroupImage = "${baseUrl}updategroupimage";
  static const String sendRequestGroup = "${baseUrl}sendRequestGroup";
  static const String acceptGroupRequest = "${baseUrl}acceptGroupRequest";

  //post
  static const String getPostAll = '${baseUrl}getPostsOfAll';
  static const String createPost = '${baseUrl}createPost';
  static const String editPostDetails = '${baseUrl}editPostDetails';
  static const String likePost = '${baseUrl}likePost';
  static const String getLikesOfPost = '${baseUrl}getLikesOfPost';
  static const String addComment = '${baseUrl}addComment';
  static const String addReplyComment = '${baseUrl}addReplyComment';
  static const String likeComment = '${baseUrl}likeComment';
  static const String getAllPostsOfMe = '${baseUrl}getAllPostsofMe';
  static const String replyCommentLike = '${baseUrl}replyCommentlike';
  static const String deletePost = '${baseUrl}deletePost';
  static const String getComment = '${baseUrl}getComment';
  static const String deleteComment = '${baseUrl}deleteComment';

  //sos
  static const String commentSos = "${baseUrl}commentsSos";
  static const String allCommentsSos = '${baseUrl}getSosComments';
  static const String getRatingsReview = "${baseUrl}getratingsReview";
}
