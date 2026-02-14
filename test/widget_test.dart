import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vouch_app/core/constants/app_constants.dart';
import 'package:vouch_app/core/widgets/trust_card.dart';
import 'package:vouch_app/core/widgets/vouch_button.dart';
import 'package:vouch_app/core/widgets/empty_state.dart';

void main() {
  group('TrustCard Widget', () {
    testWidgets('displays pro name and category', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TrustCard(
              proName: 'Joe\'s Plumbing',
              category: 'Plumber',
              voucherName: 'Mary',
              safetyRating: 5,
            ),
          ),
        ),
      );

      expect(find.text('Joe\'s Plumbing'), findsOneWidget);
      expect(find.text('Plumber'), findsOneWidget);
      expect(find.text('5/5'), findsOneWidget);
    });

    testWidgets('shows correct voucher info for 1st degree', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TrustCard(
              proName: 'Test Pro',
              category: 'Electrician',
              voucherName: 'John',
              trustTier: AppConstants.trustTierFirstDegree,
            ),
          ),
        ),
      );

      expect(find.text('Vouched by John'), findsOneWidget);
    });

    testWidgets('shows correct voucher info for 2nd degree', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TrustCard(
              proName: 'Test Pro',
              category: 'Electrician',
              voucherName: 'John',
              trustTier: AppConstants.trustTierSecondDegree,
            ),
          ),
        ),
      );

      expect(
        find.text('Vouched by a friend of John'),
        findsOneWidget,
      );
    });

    testWidgets('shows neighborhood info for tier 3', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TrustCard(
              proName: 'Test Pro',
              category: 'Painter',
              trustTier: AppConstants.trustTierNeighborhood,
            ),
          ),
        ),
      );

      expect(
        find.text('Recommended by your neighborhood'),
        findsOneWidget,
      );
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrustCard(
              proName: 'Test',
              category: 'Test',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TrustCard));
      expect(tapped, isTrue);
    });
  });

  group('VouchButton Widget', () {
    testWidgets('displays label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VouchButton(
              label: 'Test Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('shows loading indicator when isLoading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VouchButton(
              label: 'Loading',
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading'), findsNothing);
    });

    testWidgets('shows icon when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VouchButton(
              label: 'With Icon',
              icon: Icons.add,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('With Icon'), findsOneWidget);
    });

    testWidgets('meets minimum touch target size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: VouchButton(
                label: 'Touch Target',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.height, greaterThanOrEqualTo(AppConstants.minTouchTargetSize));
    });
  });

  group('EmptyState Widget', () {
    testWidgets('displays title and message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              title: 'No Data',
              message: 'Nothing to show here',
            ),
          ),
        ),
      );

      expect(find.text('No Data'), findsOneWidget);
      expect(find.text('Nothing to show here'), findsOneWidget);
    });

    testWidgets('shows action button when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              title: 'Empty',
              message: 'Add something',
              actionLabel: 'Add Now',
              onAction: () {},
            ),
          ),
        ),
      );

      expect(find.text('Add Now'), findsOneWidget);
    });

    testWidgets('hides action button when no callback', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              title: 'Empty',
              message: 'Nothing here',
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsNothing);
    });
  });

  group('Accessibility', () {
    testWidgets('TrustCard renders at 200% text scale', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
            child: const Scaffold(
              body: SingleChildScrollView(
                child: TrustCard(
                  proName: 'Joe\'s Plumbing',
                  category: 'Plumber',
                  voucherName: 'Mary',
                ),
              ),
            ),
          ),
        ),
      );

      // Verify it renders without overflow errors
      expect(find.text('Joe\'s Plumbing'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('VouchButton renders at 200% text scale', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
            child: Scaffold(
              body: Center(
                child: VouchButton(
                  label: 'Large Text Button',
                  onPressed: () {},
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Large Text Button'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
