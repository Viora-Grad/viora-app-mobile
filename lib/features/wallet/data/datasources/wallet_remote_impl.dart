import 'package:dio/dio.dart';
import 'package:viora_app/core/api/end_points.dart';
import 'package:viora_app/core/errors/error_handler.dart';
import 'package:viora_app/core/api/api_consumer.dart';
import 'package:viora_app/features/wallet/data/datasources/wallet_remote.dart';
import 'package:viora_app/features/wallet/data/models/wallet_model.dart';

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final ApiConsumer _apiConsumer;

  WalletRemoteDataSourceImpl(this._apiConsumer);

  @override
  Future<WalletModel> openWallet() async {
    final response = await _apiConsumer.postRaw(
      EndPoints.walletCustomerUrl,
      requiresAuth: true,
    );
    if (response is Map<String, dynamic>) {
      return WalletModel.fromJson(response);
    }
    return WalletModel(
      walletId: response.toString(),
      walletType: 'Customer',
      balance: 0,
      currency: 'EGP',
    );
  }

  @override
  Future<WalletModel> getWallet({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _apiConsumer.get(
        EndPoints.walletCustomerUrl,
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
        requiresAuth: true,
      );
      return WalletModel.fromJson(response);
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<String> rechargeWallet(double amount) async {
    try {
      final response = await _apiConsumer.post(
        EndPoints.walletRechargeUrl,
        data: {'amount': amount},
        requiresAuth: true,
      );
      return response['paymentUrl'] as String? ?? '';
    } on DioException catch (e) {
      handleDioException(e);
    }
  }
}
