---
title: Architecture Decision Log
...

# ADR-001: Keep CLI Graph-Only — Do Not Expose AST in CLI

## Status

Accepted

## Context

See design context in [dsg.md](./dsg.md#reader-and-writer-design)

The Pangrm CLI dispatches reader/writer actions using the format registry. These operate solely on `Text ↔ Graph` conversions. ASTs are not exposed or handled by the CLI.

## Decision

The CLI will not interact with ASTs or intermediate representations. It remains a minimal, format-agnostic dispatcher.

## Rationale

- Maintains CLI stability and abstraction.
- Avoids coupling to format-specific internal logic.
- Keeps CLI lightweight and focused on orchestration.

## Consequences

- AST inspection or debugging requires library-side code.
- No `--dump-ast` or similar CLI features by default.

## Alternatives Considered

- AST-exposing CLI (rejected due to complexity and coupling).

## Future Considerations

Introduce a separate `pangrm debug` CLI layer for AST-level inspection if needed.

# ADR-002: Use `fgl` as Internal Graph Backend — Wrap with Clean API

## Status

Accepted

## Context

See design context in [dsg.md](./dsg.md#unified-pangrm-graph)

Pangrm manipulates normalized graphs internally. We need a stable, generic, and well-supported backend.

## Decision

Use `fgl` (`Data.Graph.Inductive`) as backend implementation, but wrap it:

- `Graph.Types` defines data model (nodes/edges).
- `Graph.Utils` wraps `fgl` constructors.
- `Graph.Optics` provides safe and idiomatic optics API.

## Rationale

- `fgl` is mature and well-tested.
- Wrapping avoids legacy-style API exposure.
- Maintains modern, composable design using optics.

## Consequences

- Internal graph IDs are `Int`, not UUIDs.
- For large graphs, memory tuning may require low-level control.

# ADR-003: Enforce Reader & Writer Separation via `Reader`/`Writer` Types

## Status

Accepted

## Context

See design context in [dsg.md](./dsg.md#reader-and-writer-design)

Each format requires structured import and export logic. Maintaining composability and testability is critical.

## Decision

Define explicit `Reader` and `Writer` records per format:

- `Reader f m` = tagged injection + normalization
- `Writer f m` = graph → AST → rendered `Text`

ASTs remain internal to the library and are parametric.

## Rationale

- Clean separation of parsing vs. normalization logic
- Roundtrippable formats enforce symmetry
- Readers are composable/testable without IO

## Consequences

- Writers must implement full eject/render pipelines.
- Readers must preserve origin and position metadata.

# ADR-004: Format Registry Uses Existential Wrapper for Dynamic Dispatch

## Status

Accepted

## Context

See design context in [dsg.md](./dsg.md#format-plugin-system)

The CLI and other tooling need dynamic lookup of available formats.

## Decision

Define:

```haskell
data Entry m where
  Entry :: Roundtrippable f =>
    { fmtTag  :: forall proxy. proxy f -> Text
    , fmtRdr  :: Reader f m
    , fmtWrt  :: Writer f m
    } -> Entry m
```

Store all formats in a dynamic list of `Entry m`.

## Rationale

- Dynamic registry with static safety
- Enables flexible extension points (plugins, CLI, tests)
- Maintains full type safety and roundtripping contracts

## Consequences

- Requires GADTs and existential types
- Registry must be manually extended when formats are added

# ADR-005: Use `HasAST` + Type Families to Bind Format to AST

## Status

Accepted

## Context

See design context in [dsg.md](./dsg.md#ast-requirements)

Formats define custom intermediate representations. We need a way to associate types statically and access AST metadata.

## Decision

Use:

```haskell
class HasAST f where
  data AST f :: * -> *
  getPosition :: AST f a -> Position
  getOrigin   :: AST f a -> Maybe FilePath
```

Each format provides a data instance of its `AST f a`.

## Rationale

- AST is fully parametric (Functor, Traversable, Foldable)
- Position & origin access unified across all formats
- Clean separation of core vs. format-specific logic

## Consequences

- Requires higher-rank types
- Each AST definition must be boilerplate-heavy

# ADR-006: Do Not Use UUIDs for Internal Graph IDs

## Status

Accepted

## Context

See design context in [dsg.md](./dsg.md#unified-pangrm-graph)

Graph nodes and edges require stable identifiers. UUIDs are tempting, but unnecessary overhead for in-memory graphs.

## Decision

Use plain `Int` as internal node IDs. Ensure uniqueness per `Graph`.

## Rationale

- Simpler, faster, predictable
- Compatible with `fgl` and graph algorithms
- IDs are opaque to the user

## Consequences

- ID collision must be managed at ingestion points
- No global ID guarantees across graphs

# ADR-007: Format ASTs Must Be Functor/Foldable/Traversable

## Status

Accepted

## Context

See design context in [dsg.md](./dsg.md#ast-requirements)

To operate on graphs, ASTs must be traversable and transformable.

## Decision

Require all `AST f` to derive `Functor`, `Foldable`, and `Traversable`.

## Rationale

- Enables graph extraction and serialization
- Generic traversal tools (e.g., lenses) apply cleanly
- Ensures minimal structural consistency

## Consequences

- AST constructors must follow generic shape
- Deeply recursive formats may require careful design
