import 'package:balance/ui/group/group_page.dart';
import 'package:go_router/go_router.dart';

import 'ui/home/home_page.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: "/",
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: "/groups/:id",
      builder: (context, state) => GroupPage(state.pathParameters["id"]!),
    ),
  ],
);
