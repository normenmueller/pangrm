---
title: Library design
...

<!--
- Core, Graph, Monad cleanly separated
- Spec & plugin system logical and clean
- Reader/Writer architecture
  - Incl. excursus on data-driven vs. typeclass-only!
- Registry pattern
- HasAST + AST with constraints
- Functor/Foldable/Traversable enforced
- Position & origin handling
- Roundtrippable cleanly defined
-->

# Overview

This document provides an in-depth explanation of the Pangrm library design. It outlines the architectural principles, core abstractions, format plugin system, error classification, and extensibility mechanisms. Where relevant, concrete code snippets from the implementation are provided.

Design decisions are formalized and cross-referenced in the ADR log ([ADL](./adl.md)).

# Architecture Summary

Pangrm is structured into clearly separated subsystems:

- **Core**: monadic effects, shared options, and central abstractions
- **Graph**: normalized internal graph representation
- **Registry**: dynamic discovery and dispatch over supported formats
- **Formats**: self-contained plugins with tag, AST, reader, and writer

This modular structure ensures clean responsibilities, testability, and extensibility.

# Unified Pangrm Graph

See [ADR-002](adl.md#adr-002-use-fgl-as-internal-graph-backend--wrap-with-clean-api)  
See also [ADR-006](adl.md#adr-006-do-not-use-uuids-for-internal-graph-ids)

## Design Commitments

- **Backend**: `fgl` (via `Data.Graph.Inductive`) as internal graph engine
- **API Layer**: wrapper module `Graph` + `Graph.Utils` to abstract over `fgl`
- **Multigraph**: modeled via `RelInfo` grouped in `Rel`
- **Pure API**: stateless, no mutation; all updates return new graphs
- **Optics**: all element access via `Lens.Micro` optics only

The internal model avoids direct use of `fgl` in clients:

```haskell
-- Example: add node using API
addNode :: Int -> Elm -> Graph -> Graph
```

Note: we use `Int` node IDs instead of `UUID` to retain compatibility with `fgl` and simplify in-memory manipulation.

## Graph Structure

- `Elm` – typed node with ID, name, type, and properties
- `Rel` – edge with source/target node IDs and relation list
- `RelInfo` – per-relation metadata (name, type, props, ID)
- `Graph` – wrapper around `Gr Elm Rel`

# Optics and Traversals

Note: these rebuild the full graph on traversal.  
See [ADR-002](adl.md#adr-002-use-fgl-as-internal-graph-backend--wrap-with-clean-api)

- Fine-grained `Lens'` accessors for all record fields
- `Traversal'` for `allNodes`, `allEdges`, `allRelations`

```haskell
allRelations :: Traversal' Graph RelInfo
```

# Pangrm Monad and State

See [ADR-003](adl.md#adr-003-enforce-reader--writer-separation-via-readerwriter-types)

The `PangrmMonad` class abstracts over:

- global mutable state (`PangrmState`)
- verbosity / tracing control
- structured logging (`report`, `logOutput`)
- error handling via `MonadError PangrmError`

This enables composable format modules, CLI handlers, and tests.

```haskell
class (Functor m, Applicative m, Monad, MonadError PangrmError m)
      => PangrmMonad m where
  getState :: m PangrmState
  putState :: PangrmState -> m ()
  ...
```

# Error Classification

See [ADR-001](adl.md#adr-001-keep-cli-graph-only--do-not-expose-ast-in-cli)

Clear distinction between intent- and phase-specific errors:

| Context | Error          | Type               | Constructor |
| ------- | -------------- | ------------------ | ------------|
| CLI     | validation     | `Validation Error` | `vErr`      |
| File    | operation fail | `IO Error`         | `ioErr`     |

All errors implement `Pretty` and are handled via `handleError` for consistent CLI behavior.

```haskell
handleError :: Either PangrmError a -> IO a
```

# Format Plugin System

See [ADR-004](adl.md#adr-004-format-registry-uses-existential-wrapper-for-dynamic-dispatch)

Pangrm supports statically registered format plugins via the `Registry` and `Roundtrippable` interface.

## Key Abstractions

```haskell
data Entry m where
  Entry :: (Roundtrippable f) =>
    { fmtTag :: forall proxy. proxy f -> Text
    , fmtRdr :: Reader f m
    , fmtWrt :: Writer f m
    } -> Entry m
```

Format modules must implement:

- `HasTag` – defines tag string (e.g. "ldif")
- `HasAST` – associates a format-specific AST `f a`
- `Normalizable f` – provides reader/writer
- `Roundtrippable f` – marker class: reader + writer both present

Registered entries are listed in `entries :: [Entry m]` and matched dynamically.

*Note*: Prefer `tag @LDIF Proxy` over verbose alternatives like `tag (Proxy :: Proxy LDIF)` or `tag (Proxy @LDIF)`.

# Reader and Writer Design

See [ADR-003](adl.md#adr-003-enforce-reader--writer-separation-via-readerwriter-types)

## Why AST?

See [ADR-005](adl.md#adr-005-use-hasast--type-families-to-bind-format-to-ast)

We distinguish between:

- `AST f a`: format-specific structure
- `Graph`: normalized, shared internal form

This enables:

- faithful parsing (e.g. preserving positions, comments, ordering)
- reversible transformations (roundtripping)
- structured error reporting

<!--
-# Warum der Zwischenschritt?
-
-## Vorteile einer formateigenen Struktur
-
-- **Validierung, Fehlererkennung und Rückverfolgung**
-
-    Wenn bspw. LDIF kaputt ist, kann man präzise Fehler im LDIF-spezifischen
-    AST melden.
-
-- **Strukturtreue**:
-
-    LDIF und andere Formate (XML, RDF, JSON-Graphen, ...) haben Eigenheiten,
-    die im Pangrm-Graph nicht direkt repräsentierbar sind (z. B. Kommentare,
-    Include-Tags, Positionsinfo).
-
-- **Roundtripping-Sicherheit**:
-
-    Wenn man später LDIF -> Graph -> LDIF machen will, braucht man ggf. mehr
-    Informationen als der Graph trägt.
-
-## Alternative: Reader → direkt Graph?
-
-Das ist einfacher, aber zu unflexibel für das Ziel "Pandoc für Graphen".
-
-Wenn man nur 1–2 Formate hätte, wäre der direkte Pfad akzeptabel. Aber mit 10+
-Formaten will man:
-
-- trennbare Verantwortlichkeiten
-- austauschbare Reader/Writer
-- generische Testbarkeit
-
-Daher: formateigner AST als eigene Schicht.
-->

## Reader Structure

```haskell
Reader f m = {
  rdrTag    :: Text
  rdrInject :: RdrOpts f -> Text -> m (AST f Graph)
  rdrUnify  :: AST f Graph -> m Graph
}
```

## Writer Structure

```haskell
Writer f m = {
  wrtTag    :: Text
  wrtEject  :: Graph -> m (AST f Graph)
  wrtRender :: WrtOpts f -> AST f Graph -> m Text
}
```

## Design Note: Typeclass-Only vs. Data-Driven

See [ADR-004](adl.md#adr-004-format-registry-uses-existential-wrapper-for-dynamic-dispatch)

Pangrm uses a hybrid approach:

- Typeclass: `HasAST`, `HasTag`, `Normalizable`, `Roundtrippable`
- Data-Driven: `Reader`, `Writer` are values, passed dynamically

This balances:

| Property           | Typeclass-Only | Data-Driven |
| ------------------ | -------------- | ----------- |
| Static dispatch    | ✔              | ✗           |
| Runtime lookup     | ✗              | ✔           |
| Composability      | ✗              | ✔           |
| Ergonomics for CLI | ✗              | ✔           |

**TODO**: include side-by-side code examples in a separate appendix.

# AST Requirements

See [ADR-007](adl.md#adr-007-format-asts-must-be-functorfoldabletraversable)

All `AST f a` types must be:

- `Functor`
- `Foldable`
- `Traversable`

This ensures:

- type-generic transformation pipelines
- uniform error annotation
- compatibility with Graph ↔ AST conversions

Additionally, every AST node must expose:

```haskell
getPosition :: AST f a -> Position
getOrigin   :: AST f a -> Maybe FilePath
```

# Conclusion

The Pangrm library design follows principles of modularity, explicit effects, and safe extensibility. It enables the integration of multiple graph formats while maintaining consistency and testability across the system.

Essentials such as the Graph core, AST discipline, and dynamic Registry make the system extensible for future formats and use cases.

See [ADL](./adl.md) for rationale and commitments.
