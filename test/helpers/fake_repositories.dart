import 'package:mocktail/mocktail.dart';
import 'package:easy_finance/domain/repositories/auth_repository.dart';
import 'package:easy_finance/domain/repositories/asset_repository.dart';
import 'package:easy_finance/domain/repositories/watchlist_repository.dart';
import 'package:easy_finance/domain/repositories/chat_repository.dart';
import 'package:easy_finance/data/datasources/secure_storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockAssetRepository extends Mock implements AssetRepository {}
class MockWatchlistRepository extends Mock implements WatchlistRepository {}
class MockChatRepository extends Mock implements ChatRepository {}
class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}
