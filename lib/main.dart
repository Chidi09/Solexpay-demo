import 'package:flutter/widgets.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'app/app.dart';
import 'core/observability/sentry_scrubber.dart';

/// DSN and environment are injected at build time via `--dart-define` so
/// secrets never live in source control:
///   flutter run --dart-define=SENTRY_DSN=https://xxx@sentry.io/yyy \
///               --dart-define=APP_ENV=production
const _sentryDsn = String.fromEnvironment('SENTRY_DSN');
const _appEnvironment = String.fromEnvironment('APP_ENV', defaultValue: 'development');

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = _sentryDsn;
      options.environment = _appEnvironment;

      // Performance tracing: sample everything outside production to keep
      // local/staging visibility high, throttle in production to control cost.
      options.tracesSampleRate = _appEnvironment == 'production' ? 0.2 : 1.0;

      // Never auto-attach device PII (IP, user identifiers) — this is a
      // banking app; only what we explicitly set should be reported.
      options.sendDefaultPii = false;
      options.attachStacktrace = true;

      // Defence-in-depth scrubbing — see sentry_scrubber.dart for why.
      options.beforeSend = scrubSentryEvent;
      options.beforeBreadcrumb = scrubSentryBreadcrumb;
    },
    appRunner: () => runApp(const SolexPayApp()),
  );
}
