# Java / Kotlin pitfalls

## Java
- `==` on objects/strings instead of `.equals`; `equals` overridden without `hashCode`.
- Null handling: unchecked returns from maps/repositories; `Optional.get()` without check; `Optional` as fields/parameters.
- Resources without try-with-resources (streams, connections, `ResultSet`).
- Catching `Exception`/`Throwable` broadly; empty catch blocks; losing the cause when rethrowing.
- Mutable shared state in singletons/Spring beans (beans are singletons by default — instance fields are shared across requests).
- `SimpleDateFormat` shared across threads; `java.util.Date` instead of `java.time`.
- Collections returned mutable from getters; `ConcurrentModificationException` from modifying while iterating.
- JPA: N+1 from lazy loading in loops, `@Transactional` on private methods or self-invocation (no effect), entities exposed directly as API responses.
- SQL/JPQL built by string concatenation.

## Kotlin
- `!!` hiding nullability; platform types from Java treated as non-null.
- `lateinit` accessed before init; `runBlocking` in production/request code.
- Coroutines: `GlobalScope`, missing structured concurrency, blocking calls on `Dispatchers.Main`/`Default`.
- `data class` with mutable `var`s used as map keys.

## Tooling hints
- Maven: `mvn -q verify` or `mvn test`; Gradle: `./gradlew check` / `test`. Checkstyle/SpotBugs/detekt/ktlint if configured (check mode only — not `ktlintFormat`/`spotlessApply`).
