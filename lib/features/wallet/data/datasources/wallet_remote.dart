import 'package:viora_app/features/wallet/data/models/wallet_model.dart';

abstract class WalletRemoteDataSource {
  Future<WalletModel> openWallet();

  Future<WalletModel> getWallet({
    int page = 1,
    int pageSize = 20,
  });

  Future<String> rechargeWallet(double amount);
}
