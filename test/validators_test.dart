import 'package:flutter_test/flutter_test.dart';
import 'package:studyplan/core/constants/app_strings.dart';
import 'package:studyplan/core/utils/validators.dart';

void main() {
  test('email валидациясы', () {
    expect(Validators.email(''), AppStrings.enterEmail);
    expect(Validators.email('abc'), AppStrings.badEmail);
    expect(Validators.email('a@b'), AppStrings.badEmail);
    expect(Validators.email('aidana@mail.kz'), isNull);
  });

  test('құпиясөз валидациясы', () {
    expect(Validators.passwordNotEmpty(''), AppStrings.enterPassword);
    expect(Validators.passwordNotEmpty('1'), isNull);
    expect(Validators.newPassword('1234567'), AppStrings.shortPassword);
    expect(Validators.newPassword('12345678'), isNull);
  });

  test('міндетті өріс', () {
    expect(Validators.required('  ', 'қате'), 'қате');
    expect(Validators.required('мәтін', 'қате'), isNull);
  });
}
