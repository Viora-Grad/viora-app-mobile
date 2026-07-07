import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:viora_app/core/enums/gender.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/core/params/user_parameters.dart';
import 'package:viora_app/features/auth/domain/entities/user.dart';
import 'package:viora_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:viora_app/features/auth/domain/usecases/login_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepo;
  late LoginUsecase subject;

  setUpAll(() {
    registerFallbackValue(LoginParameters(email: 'a@b.com', password: 'Aa1!abcd'));
  });

  setUp(() {
    mockRepo = MockAuthRepository();
    subject = LoginUsecase(mockRepo);
  });

  test('validates email and password formats', () async {
    // Empty email
    var res = await subject.call(LoginParameters(email: '', password: 'Aa1!abcd'));
    expect(res.isLeft(), isTrue);
    res.fold((l) => expect(l, isA<ValidationFailure>()), (_) {});

    // Invalid email
    res = await subject.call(LoginParameters(email: 'bad', password: 'Aa1!abcd'));
    expect(res.isLeft(), isTrue);

    // Short password
    res = await subject.call(LoginParameters(email: 'a@b.com', password: 'short'));
    expect(res.isLeft(), isTrue);
  });

  test('delegates to repository on valid credentials', () async {
    final user = User(id: 'u1', email: 'a@b.com', firstName: 'A', lastName: 'B', gender: Gender.male, dateOfBirth: DateTime(2000, 1, 1));
    when(() => mockRepo.login(any())).thenAnswer((_) async => Right(user));

    final res = await subject.call(LoginParameters(email: 'a@b.com', password: 'Aa1!abcd'));
    expect(res.isRight(), isTrue);
    res.fold((_) {}, (r) => expect(r, equals(user)));
    verify(() => mockRepo.login(any())).called(1);
  });
}
