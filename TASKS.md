# Refactoring Tasks - Clean Code, DRY & Error Handling

---

## Priority 1: Error Handling (Edge Functions)
> **Summary:** Make edge functions robust with proper validation, structured error responses, and clear logging. All errors should be handled at the edge so the app receives predictable responses.

- [ ] Consistent response structures (`{ success, data/error, message }`) *(Partial)*
  - [x] Both edge functions return `{ success, data, error }`
  - [ ] Add `message` field consistently
- [x] Wrap fetch in try/catch (general outer + specific for fetch)
- [x] Method enforcement (POST only) and input validation
- [ ] Simple env var validation
- [ ] Handle upstream non-2xx explicitly (return 503) *(Partial: error payloads handled, no `response.ok` check)*
- [ ] Log errors for debugging, fix error.message handling *(Partial: errors logged, message normalization pending)*

---

## Priority 2: DRY (Edge Functions)
> **Summary:** Extract shared utilities to avoid code duplication between edge functions.

- [ ] Create `supabase/functions/_shared/cors.ts`
- [ ] Create `supabase/functions/_shared/response.ts`
- [ ] Create `supabase/functions/_shared/validation.ts`
- [ ] Refactor `gemini-proxy` to use shared utilities
- [ ] Refactor `serp-amazon-search` to use shared utilities

---

## Priority 3: Error Handling (Flutter App)
> **Summary:** Add defensive error handling throughout the app. Errors should be caught and logged, not crash the app.

- [ ] `supabase_service.dart`: Wrap `initialize()` and `signInAnonymously()` in try/catch
- [ ] `base_adapter.dart`, `base_provider.dart`: Ensure methods are protected (already done for adapter)
- [ ] `gemini_adapter.dart`: Add try/catch to `callApi()`, safe cast, proper logging
- [ ] `amazon_provider.dart`: Add try/catch to `_callApi()`, safe cast, move randomizer inside class *(Partial: randomizer still top-level; `callApi()` lacks try/catch and safe cast)*
- [ ] `orchestrator.dart`: Add try/catch to `initialize()`, search loop, proper logging, use `Future.wait()`
- [ ] `search_item.dart`: Wrap `launchUrl` in try/catch
- [ ] `main.dart`: Add try/catch to `SupabaseService.initialize()`
- [ ] `app.dart`: Add try/catch/finally to `_validateInput()`, `getInstance`, `search`

---

## Priority 4: Clean Code
> **Summary:** Remove dead code, fix inconsistencies, and improve code quality.

- [ ] `app.dart`: Remove hardcoded test data, fix `enterdAge` typo *(Partial: hardcoded test data still present; `enteredAge` already spelled correctly)*
- [ ] `search.dart`: Fix nullable/default inconsistency for `ratings`/`reviews` *(Partial: defaults exist, but model field naming/types still differ from edge response shape)*
- [ ] `gift_ideas_list.dart`: Use `GiftContext.id` as key instead of `ValueKey(ideas[index])`
- [ ] `GiftSearchItem`: Tighten types for `ratings`/`reviews` to match edge response *(Partial: `rating` is normalized to string, but model is not aligned with upstream type semantics)*

---

## Progress Log

| Date | Section | Status |
|------|---------|--------|
| 2026-02-11 | Priority 1 | Partial |
| 2026-02-11 | Priority 2 | Pending |
| 2026-02-11 | Priority 3 | Partial |
| 2026-02-11 | Priority 4 | Partial |
