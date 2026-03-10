## What was the bug?

The `HttpClient` failed to attach an `Authorization` header when the `oauth2Token` was a plain object (e.g., `{ accessToken: '...', expiresAt: ... }`) instead of `OAuth2Token` class instance.

## Why did it happen?

The original logic used `!this.oauth2Token` to check for missing tokens and `this.oauth2Token instanceof OAuth2Token` to check for expiration.
When a plain object is provided:

1. It passed the truthiness check (so no refresh happened).
2. It failed the `instanceof` check (so the expiration wasn't checked, and the header was never assigned).
   TypeScript's type narrowing couldn't guarantee the existence of `.asHeader()` on a plain object, so the code simply skipped the assignment.

## Why does your fix actually solve it?

By changing the condition to `!(this.oauth2Token instanceof OAuth2Token)`, I ensure that any state that isn't a proper class instance—including `null` or a plain object—triggers `refreshOAuth2()`. This guarantees that by the time we reach the header assignment, `oauth2Token` is a valid `OAuth2Token` instance with the required methods.

## What’s one realistic case / edge case your tests still don’t cover?

- The tests don't cover an expired `OAuth2Token` instance.

- **Concurrent Requests:** If multiple asynchronous requests are initiated while the token is expired, the current implementation would trigger multiple simultaneous `refreshOAuth2()` calls. A production-ready client should make the refresh process "awaitable" and ensure that only one network call is made to the identity provider, and all pending requests wait for that single new token.
