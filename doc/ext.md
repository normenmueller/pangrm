---
title: How to Add a New Pangrm Format
...

This document explains how to add a new **Pangrm Format Plugin** step by step. Follow this guide to ensure your format integrates cleanly and idiomatically with the Pangrm core architecture.

All format modules are **statically typechecked**. Missing instances (e.g. `Normalizable`, `HasAST`) will cause **compile-time errors** that guide integration and prevent runtime failures.

For architectural rationale, see [Library Design](./dsg.md) and the [Architecture Decision Log](./adl.md).

# Step 1: Define the Format

Every Pangrm format module begins with:

1. A **type-level tag** (e.g., `data MyFormat = MyFormat`)
2. A **format-specific AST** (via `HasAST`)

These are defined in `Pangrm.Formats.MyFormat.Format`.

> Why type-level tags?
>
> Pangrm avoids string-based identifiers and instead uses **type-level format tags**. These tags:
>
> - Enable static dispatch and type inference
> - Prevent mismatches between runtime strings and type resolution
> - Allow safe registration and lookup in the Pangrm Registry

> Why format-specific ASTs?
>
> Each format can preserve layout, comments, ordering, and positions that are not expressible in the canonical Pangrm `Graph`. This enables:
>
> - Richer diagnostics and error reporting
> - Faithful roundtripping (format ↔ graph ↔ format)
> - Clear modular separation of format logic

```haskell
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE DeriveTraversable #-}
{-# LANGUAGE OverloadedStrings #-}

module Pangrm.Formats.MyFormat.Format
  ( MyFormat(..)
  , AST(..)
  ) where

import Data.Text (Text)
import Pangrm.Core.Format

-- | Type-level tag for the MyFormat format.
data MyFormat = MyFormat

instance HasTag MyFormat where
  tag _ = "mf"

-- | AST definition for the format.
--
-- Must implement Functor, Foldable, Traversable.
-- Must expose position and origin metadata.
instance HasAST MyFormat where
  data AST MyFormat a = MyFormatEntry
    { mfEty       :: a
    , mfEtyName   :: Text
    , mfEtyAttr   :: [Text]
    , mfEtyLine   :: Int
    , mfEtyColumn :: Int
    , mfEtyOrigin :: Maybe FilePath
    } deriving (Functor, Foldable, Traversable)

  getPosition ast = Position (myFormatEtyLine ast, myFormatEtyColumn ast)
  getOrigin   = myFormatEtyOrigin
```

What does this declaration do?

- `HasTag` connects your format to the Pangrm registry by providing a unique, type-level identifier. This is used for dynamic lookup, CLI dispatch, and internal routing. We recommend lowercase or canonical file extensions (e.g. `"ldif"`).

- `HasAST` defines the format-specific intermediate representation (AST). This is used by the `Reader`, `Writer`, and Pangrm's transformation pipeline.
  Your AST must:

  - Be parameterized (`AST f a`) and implement `Functor`, `Foldable`, and `Traversable`
  - Expose a valid `Position` and (optional) `FilePath` via `getPosition` and `getOrigin`

> Why a dedicated AST instead of parsing directly to the Graph?
>
> See the [Pangrm Architecture Decision Log (ADL)](./adl.md#adr-005-use-hasast--type-families-to-bind-format-to-ast) for the reasoning behind explicit format-specific ASTs and how this enables validation, traceability, and roundtripping safety.

These constraints ensure roundtripping, error traceability, and compatibility with Pangrm’s optics and traversal machinery.

> Format implementors must ensure that:
>
> - `getPosition` returns a meaningful source location.
> - `getOrigin` reflects the input source (e.g., file name), if available.
> - Dummy values (e.g. `(0,0)` or `Nothing`) may impair diagnostics and tracing.

With the tag and AST now defined, the next step is to implement the `Reader` and `Writer` modules that handle your format’s integration with the Pangrm graph and conversion pipeline.

# Step 2: Implement Reader and Writer

Once your format's tag and AST are defined, the next step is to implement the format's **Reader** and **Writer**. These components integrate your format into the Pangrm I/O pipeline.

- The `Reader` defines how to parse input text into your format-specific AST (`inject`) and how to convert that AST into the Pangrm Graph (`unify`).
- The `Writer` defines how to convert a Pangrm Graph into your AST (`eject`) and how to render the AST back into textual form (`render`).

> Why split the pipeline into eject/render and inject/unify?
>
> See [ADR-003](./adl.md#adr-003-enforce-reader--writer-separation-via-readerwriter-types) for rationale on separating parsing and normalization logic.

This two-stage design — **AST ↔ Graph ↔ AST** — provides the necessary flexibility to:

- Preserve structure and metadata faithfully
- Enable roundtripping and diagnostics
- Cleanly separate parsing from transformation

## Reader

A `Reader f m` consists of two functions:

```haskell
data Reader f m = Reader
  { rdrTag    :: Text
  , rdrInject :: forall a. PangrmMonad m => RdrOpts -> Text -> m (AST f a)
  , rdrUnify  :: forall a. PangrmMonad m => AST f a -> m Graph
  }
```

- `rdrInject`: parses raw text into a typed AST
- `rdrUnify`: converts the AST into a Pangrm Graph

Create a new module `Pangrm.Formats.MyFormat.Reader` and define:

```haskell
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE OverloadedStrings #-}

module Pangrm.Formats.MyFormat.Reader
  ( reader
  ) where

import Data.Proxy

import qualified Pangrm.Core.Graph as G
import Pangrm.Core.PangrmMonad
import Pangrm.Core.Format
import Pangrm.Formats.MyFormat.Format (MyFormat(..), AST(..))

reader :: PangrmMonad m => Reader MyFormat m
reader =
  Reader
    { rdrTag = tag @MyFormat Proxy
    , rdrInject =
        \_opts _txt ->
          return
            $ MyFormatEntry
                { mfEty = error "inject: dummy AST — replace in implementation"
                , mfEtyName = "dummy"
                , mfEtyAttr = []
                , mfEtyLine = 1
                , mfEtyColumn = 1
                , mfEtyOrigin = Nothing
                }
    , rdrUnify = \_ast -> return G.empty
    }
```

> Note:
>
> - Replace the `error` and dummy values with your actual parsing logic.
> - Use `rdrInject` only to produce your AST — do not convert directly to a Graph.
> - Use `rdrUnify` to extract semantic structure from your AST.

## Writer

A `Writer f m` reverses the reading process:

```haskell
data Writer f m = Writer
  { wrtTag    :: Text
  , wrtEject  :: forall a. PangrmMonad m => Graph -> m (AST f a)
  , wrtRender :: forall a. PangrmMonad m => WrtOpts -> AST f a -> m Text
  }
```

- `wrtEject`: converts a Pangrm Graph into a typed AST
- `wrtRender`: serializes the AST to text

Create a new module `Pangrm.Formats.MyFormat.Writer` and define:

```haskell
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE OverloadedStrings #-}

module Pangrm.Formats.MyFormat.Writer
  ( writer
  ) where

import Data.Proxy

import Pangrm.Core.PangrmMonad
import Pangrm.Core.Format
import Pangrm.Formats.MyFormat.Format (MyFormat(..), AST(..))

writer :: PangrmMonad m => Writer MyFormat m
writer =
  Writer
    { wrtTag = tag @MyFormat Proxy
    , wrtEject =
        \_graph ->
          return
            $ MyFormatEntry
                { mfEty = error "eject: dummy AST — replace in implementation"
                , mfEtyName = "dummy"
                , mfEtyAttr = []
                , mfEtyLine = 1
                , mfEtyColumn = 1
                , mfEtyOrigin = Nothing
                }
    , wrtRender = \_opts _ast -> return mempty
    }
```

> 🔧 Note:
>
> - Replace `error` and dummy values with your actual graph-to-AST logic.
> - Avoid rendering directly from the Graph — first generate your AST, then render.

In the next step, you'll **register your format** with Pangrm and expose it via the central format registry.

# Step 3: Register Your Format

Once your Reader and Writer are implemented, you must **connect your format to the Pangrm framework**. This enables it to participate in the format registry, CLI dispatch, and testing infrastructure.

You do this in two steps:

1. Provide a `Normalizable` instance
2. Add an entry to the format registry

## Implement the `Normalizable` and `Roundtrippable` instances

Create the glue module `Pangrm.Formats.MyFormat` and define:

```haskell
{-# OPTIONS_GHC -Wno-orphans #-}
{-# LANGUAGE TypeApplications #-}

module Pangrm.Formats.MyFormat
  ( module Pangrm.Formats.MyFormat.Format
  , module Pangrm.Formats.MyFormat.Reader
  , module Pangrm.Formats.MyFormat.Writer
  ) where

import Pangrm.Core.Format
import Pangrm.Formats.MyFormat.Format
import Pangrm.Formats.MyFormat.Reader
import Pangrm.Formats.MyFormat.Writer

-- | Connects MyFormat’s reader and writer.
instance Normalizable MyFormat where
  getReader = reader
  getWriter = writer

-- | Enables Graph roundtripping and CLI support.
instance Roundtrippable MyFormat
```

> Warning:
>
> This is the only location where an orphan instance is allowed. Do **not** place `Normalizable` elsewhere.

> Tip:
>
> The re-exports in the module header (`module ...`) simplify imports when writing tests or format-specific tooling.

## Add your format to the central registry

Make your format discoverable by adding it to the list of known entries. In `Pangrm.Formats.Registry` append your entry:

```haskell
registeredFormats :: PangrmMonad m => [PangrmFormat m]
registeredFormats =
  [ PangrmFormat (tag @MyFormat) (getReader @MyFormat) (getWriter @MyFormat)
  , ...
  ]
```

This enables CLI dispatch, test tooling, and all other dynamic format-based routing.

> Registry entries are required for:
>
> - CLI support (`pangrm convert --from ...`)
> - Roundtrip test runners
> - Format introspection tooling
> - Plugin-style extensibility

> Where is the registry structure defined?
>
> See [ADR-004](./adl.md#adr-004-format-registry-uses-existential-wrapper-for-dynamic-dispatch) for the rationale and type definition of `PangrmFormat`.

In the final step, you will **test your format end-to-end** and validate its behavior in the CLI.

# Step 4: Test Your Format

tbd.

<!--

- Normalization

-->

