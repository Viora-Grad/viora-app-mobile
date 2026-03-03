import 'package:viora_app/core/connections/api/api_consumer.dart';
import 'package:viora_app/core/connections/api/end_points.dart';
import 'package:viora_app/core/params/user_parameters.dart';
import 'package:viora_app/features/user/data/models/user_model.dart';

class UserRemote {
  final ApiConsumer apiConsumer;

  UserRemote(this.apiConsumer);

  Future<UserModel> getUser(UserParameters parameters) async {
    final response = await apiConsumer.get('${EndPoints.users}/${parameters.userId}');
    return UserModel.fromJson(response);
  }
}
