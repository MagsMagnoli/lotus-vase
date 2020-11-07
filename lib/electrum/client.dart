import 'package:cashew/electrum/rpc.dart';

class ListUnspentResponseItem {
  int height;
  int tx_pos;
  String tx_hash;
  BigInt value;
}

class ElectrumClient extends JSONRPCWebsocket {
  Future<Object> blockchainTransactionBroadcast(String transaction) {
    return call('blockchain.transaction.broadcast', [transaction]);
  }

  Future<List<ListUnspentResponseItem>> blockchainScripthashListunspent(
      String scriptHash) async {
    // TODO: Add interface here for this call specifically
    final List<dynamic> response =
        await call('blockchain.scripthash.listunspent', [scriptHash]);
    return response.cast<ListUnspentResponseItem>();
  }

  Future<GetBalanceResponse> blockchainScripthashGetBalance(
      String scripthash) async {
    final Map<String, dynamic> response =
        await call('blockchain.scripthash.get_balance', [scripthash]);
    return GetBalanceResponse(response['confirmed'], response['unconfirmed']);
  }

  Future<List<String>> serverVersion(
      String ownVersion, String supportedVersion) async {
    final List<dynamic> response =
        await call('server.version', [ownVersion, supportedVersion]);
    return response.cast<String>();
  }

  Future<Object> blockchainScripthashSubscribe(
      String scripthash, SubscriptionHandler resultHandler) {
    return subscribe(
        'blockchain.scripthash.subscribe', [scripthash], resultHandler);
  }
}

class ElectrumFactory {
  ElectrumFactory(this.url);

  Future<ElectrumClient> _client;
  Uri url;

  /// Builds client if non-existent and attempts to connect before resolving.
  Future<ElectrumClient> build() {
    if (_client == null) {
      final newClient = ElectrumClient();
      _client = newClient.connect(url).then((_) => newClient);
    }
    return _client;
  }
}