import 'package:flutter_test/flutter_test.dart';
import 'package:optigasto/features/promotions/presentation/bloc/publish_promotion_bloc.dart';
import 'package:optigasto/features/promotions/presentation/bloc/publish_promotion_event.dart';
import 'package:optigasto/features/promotions/presentation/bloc/publish_promotion_state.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  late PublishPromotionBloc bloc;
  late MockCreatePromotion mockCreatePromotion;
  late MockUploadPromotionImages mockUploadImages;
  late MockGetCurrentUser mockGetCurrentUser;

  setUpAll(registerFallbackValues);

  setUp(() {
    mockCreatePromotion = MockCreatePromotion();
    mockUploadImages = MockUploadPromotionImages();
    mockGetCurrentUser = MockGetCurrentUser();
    bloc = PublishPromotionBloc(
      createPromotion: mockCreatePromotion,
      uploadPromotionImages: mockUploadImages,
      getCurrentUser: mockGetCurrentUser,
    );
  });

  tearDown(() => bloc.close());

  test('initial state is PublishPromotionInitial', () {
    expect(bloc.state, const PublishPromotionInitial());
  });

  test(
    'SelectCommerceEvent stores commerce coordinates in form state',
    () async {
      // Act
      bloc.add(const SelectCommerceEvent(
        commerceId: 'commerce-1',
        commerceName: 'Supermercado Central',
        latitude: 9.9281,
        longitude: -84.0907,
        address: 'Av. Central, San José',
      ));
      await Future<void>.delayed(Duration.zero);

      // Assert
      final state = bloc.state as PublishPromotionFormState;
      expect(state.commerceId, 'commerce-1');
      expect(state.commerceName, 'Supermercado Central');
      expect(state.commerceLatitude, 9.9281);
      expect(state.commerceLongitude, -84.0907);
      expect(state.commerceAddress, 'Av. Central, San José');
    },
  );
}
