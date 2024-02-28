import 'package:auto_route/auto_route.dart';
import 'package:flash_talk/decoding.dart';
import 'package:flash_talk/translation_page.dart';

part 'router.gr.dart';

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
    MaterialRoute(page: TranslationRoute.page, initial: true),
    MaterialRoute(page: DecodingRoute.page)

  ];
}