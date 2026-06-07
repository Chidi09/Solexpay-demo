import 'package:sentry_flutter/sentry_flutter.dart';

/// Key-name fragments that must never leave the device. SolexPay is a banking
/// app — PINs, OTPs, BVN/NIN, account numbers, phone numbers and auth tokens
/// are all sensitive and must be redacted before any crash report is sent,
/// regardless of where in the payload they surface.
const _sensitiveKeyFragments = <String>[
  'pin',
  'otp',
  'bvn',
  'nin',
  'account_number',
  'accountnumber',
  'phone',
  'token',
  'password',
  'authorization',
  'cookie',
];

const _redacted = '[redacted]';

bool _isSensitiveKey(String key) {
  final lower = key.toLowerCase();
  return _sensitiveKeyFragments.any(lower.contains);
}

dynamic _scrub(dynamic value) {
  if (value is Map) {
    return value.map((key, v) {
      if (_isSensitiveKey(key.toString())) {
        return MapEntry(key, _redacted);
      }
      return MapEntry(key, _scrub(v));
    });
  }
  if (value is Iterable) {
    return value.map(_scrub).toList();
  }
  return value;
}

Map<String, String> _scrubHeaders(Map<String, String> headers) {
  return headers.map(
    (key, value) => MapEntry(key, _isSensitiveKey(key) ? _redacted : value),
  );
}

/// Redacts sensitive request data/headers from outgoing events before they
/// leave the device. This is defence-in-depth on top of `sendDefaultPii =
/// false` and the fact that the Dio integration doesn't capture bodies by
/// default — if either of those ever changes, secrets still can't leak.
SentryEvent? scrubSentryEvent(SentryEvent event, Hint hint) {
  final request = event.request;
  if (request == null) return event;

  event.request = SentryRequest(
    url: request.url,
    method: request.method,
    queryString: request.queryString,
    cookies: request.cookies,
    fragment: request.fragment,
    apiTarget: request.apiTarget,
    data: request.data == null ? null : _scrub(request.data),
    headers: _scrubHeaders(request.headers),
    env: request.env,
  );
  return event;
}

/// Redacts sensitive fields from breadcrumb payloads (e.g. HTTP breadcrumbs
/// carrying query parameters or headers) before they're attached to the scope
/// and shipped alongside the next event.
Breadcrumb? scrubSentryBreadcrumb(Breadcrumb? breadcrumb, Hint hint) {
  final data = breadcrumb?.data;
  if (breadcrumb == null || data == null) return breadcrumb;

  breadcrumb.data = Map<String, dynamic>.from(_scrub(data) as Map);
  return breadcrumb;
}
