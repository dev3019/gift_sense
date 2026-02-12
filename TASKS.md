# Refactoring Tasks - Clean Code, DRY & Error Handling

---

## Priority 1: Error Handling (Edge Functions)
> **Summary:** Make edge functions robust with proper validation, structured error responses, and clear logging. All errors should be handled at the edge so the app receives predictable responses.

- [x] Consistent response structures (`{ success, data/error, message }`)
  - (Partial) Both functions use `{ success, data, error }` pattern. The `message` field from the original spec is absent — only `error` carries text.
- [x] Wrap fetch in try/catch (general outer + specific for fetch)
- [x] Method enforcement (POST only) and input validation
- [x] Simple env var validation
  - Both functions now guard against missing env vars with an early return (503) and log the issue. Non-null assertions (`!`) removed.
- [x] Handle upstream non-2xx explicitly (return 503)
  - (Partial) Checks error fields in the JSON body and returns 503, but does **not** check `response.ok` or `response.status` for HTTP-level failures.
- [x] Log errors for debugging, fix error.message handling
  - (Partial) `console.error` calls exist in all catch blocks and error branches. However, raw `error` objects are logged directly — no safe access via `error instanceof Error ? error.message : String(error)`.

---

## Priority 2: DRY (Edge Functions)
> **Summary:** Extract shared utilities to avoid code duplication between edge functions.

- [ ] Create `supabase/functions/_shared/cors.ts`
- [ ] Create `supabase/functions/_shared/response.ts`
- [ ] Create `supabase/functions/_shared/validation.ts`
- [ ] Refactor `gemini-proxy` to use shared utilities
- [ ] Refactor `serp-amazon-search` to use shared utilities

> **Note:** No `_shared/` directory exists. Both functions duplicate CORS headers, `jsonResponse`, and validation logic inline.

---

## Priority 3: Error Handling (Flutter App)
> **Summary:** Add defensive error handling throughout the app. Errors should be caught and logged, not crash the app.

- [ ] `supabase_service.dart`: Wrap `initialize()` and `signInAnonymously()` in try/catch
  - No try/catch around `Supabase.initialize()` or `_ensureAnonymousSession()`.
- [x] `base_adapter.dart`, `base_provider.dart`: Ensure methods are protected (already done for adapter)
  - (Partial) `GeminiAiAdapter.getGiftIdeas` has try/catch. `AmazonProvider.search` has try/catch. However, `AmazonProvider.callApi` is **not** wrapped.
- [ ] `gemini_adapter.dart`: Add try/catch to `callApi()`, safe cast, proper logging
  - `callApi()` uses direct `response.data as Map<String, dynamic>` cast with no try/catch. `parseResponse` also uses unsafe `as` casts.
- [ ] `amazon_provider.dart`: Add try/catch to `_callApi()`, safe cast, move randomizer inside class
  - `callApi()` uses unsafe cast. `final randomizer = Random()` remains top-level (line 7), not inside the class.
- [ ] `orchestrator.dart`: Add try/catch to `initialize()`, search loop, proper logging, use `Future.wait()`
  - `initialize()` has no try/catch. Provider search loop is sequential with no error handling or `Future.wait()`.
- [ ] `search_item.dart`: Wrap `launchUrl` in try/catch
  - `_launchUrl()` throws `Exception` on failure instead of catching gracefully.
- [ ] `main.dart`: Add try/catch to `SupabaseService.initialize()`
  - `await SupabaseService.initialize()` is called without any try/catch in `main()`.
- [ ] `app.dart`: Add try/catch/finally to `_validateInput()`, `getInstance`, `search`
  - No try/catch/finally around the async search flow. A failure leaves `_isLoading = true` permanently.

---

## Priority 4: Clean Code
> **Summary:** Remove dead code, fix inconsistencies, and improve code quality.

- [x] `app.dart`: Remove hardcoded test data, fix `enterdAge` typo
  - (Partial) `enterdAge` typo was fixed → now `enteredAge`. `Descibe` typo fixed → now `Describe`. Hardcoded `_giftIdeas` test items remain (not removed per scope).
- [x] `search.dart`: Fix nullable/default inconsistency for `ratings`/`reviews`
  - Both fields are non-nullable with defaults (`ratings: '0'`, `reviews: 0`). Consistent.
- [x] `gift_ideas_list.dart`: Use `GiftContext.id` as key instead of `ValueKey(ideas[index])`
  - Now uses `ValueKey(ideas[index].id)` for a stable, unique key.
- [ ] `GiftSearchItem`: Tighten types for `ratings`/`reviews` to match edge response
  - (Partial) `reviews` is `int` (matches API). `ratings` is `String` while the edge function returns `num` — the model does not align with the raw response type.

---

## Progress Log

| Date       | Section    | Status           |
|------------|------------|------------------|
| 2026-02-11 | Priority 1 | Partially Complete |
| 2026-02-11 | Priority 2 | Not Started      |
| 2026-02-11 | Priority 3 | Not Started      |
| 2026-02-11 | Priority 4 | Partially Complete |
| 2026-02-12 | Priority 1 | Complete (partials left as-is) |
| 2026-02-12 | Priority 4 | Complete (partials left as-is) |
