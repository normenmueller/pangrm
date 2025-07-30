{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE ConstraintKinds #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}

{-|
Module      : Pangrm.Core.Format
Description : Defines the contract and data types for Pangrm formats.

This module defines the required components for implementing a Pangrm format,
including:

* A unique type-level tag via 'HasTag'
* The associated intermediate representation (IR) via 'HasAST'
* Format-specific 'Reader' and 'Writer' records
* The 'Roundtrippable' contract for safe bidirectional transformations

Pangrm formats are expected to implement both reading (inject + unify)
and writing (eject + render) capabilities based on a shared AST.
-}
module Pangrm.Core.Format
  ( Position(..)
  , HasTag(..)
  , HasAST(..)
  , Reader(..)
  , Writer(..)
  , Normalizable(..)
  , Roundtrippable
  ) where

import Data.Text (Text)
import Data.Kind (Type)

import Pangrm.Core.Graph
import Pangrm.Core.PangrmMonad
import Pangrm.Shared

-- | Represents a line-column position.
newtype Position = Position (Int, Int)

-- | A tag type used to identify a format at the type level.
-- @TODO@ Re-asses via type familes: 'forall f. KnownSymbol (TagOf f) => ...'
class HasTag f where
  tag :: proxy f -> Text

{-|
Declares the format-specific Abstract Syntax Tree (AST) used by a Pangrm format.

Each format must define a type constructor `AST f` of kind `Type -> Type`.
The parameter `a` can be used to thread annotations or additional metadata
(e.g., via `Identity`, `Maybe`, or custom types).

Note: Implementors are responsible for ensuring that 'getPosition' and 'getOrigin'
behave consistently across all valid instantiations of @AST f a@. These functions
must extract the source-level location and origin information from the AST node
regardless of the annotation type.

@TODO@:
Currently, Pangrm does not extract `Position` or `Origin` information *from* the
annotation type `a`. While this may be desirable in the future (e.g., via a
typeclass constraint like Pandoc's `ToSources`), the current design places the
responsibility entirely on the AST constructor itself.

This means that `getPosition` and `getOrigin` must be carefully implemented such
that they return meaningful values. If `getPosition` always yields a dummy value
like (0,0), or if `getOrigin` returns `Nothing` indiscriminately, then Pangrm’s
diagnostics, error messages, and traceability features will be significantly
impaired.

Format implementors should therefore:

- Ensure their AST carries enough positional metadata
- Connect `getPosition` and `getOrigin` to that data explicitly
- Consider annotating AST nodes with `Position` and `FilePath` when parsing

Future versions of Pangrm may introduce a structural requirement or helper
abstraction to enforce this more systematically.
-}
class HasAST f where
  data AST f :: Type -> Type
  -- ^ The associated Abstract Syntax Tree (AST) type of the format.
  getPosition :: AST f a -> Position
  -- ^ Extracts from an AST node the position in the origin.
  getOrigin :: AST f a -> Maybe FilePath
  -- ^ Extract the origin from an AST node, if available.

-- | A format-specific reader instance.
data Reader f m = Reader
  { rdrTag    :: Text
    -- ^ Unique format tag.
  , rdrInject :: forall a. PangrmMonad m => RdrOpts -> Text -> m (AST f a)
    -- ^ Parse input 'Text' into the format-specific AST, using reader options.
  , rdrUnify  :: forall a. PangrmMonad m => AST f a -> m Graph
    -- ^ Convert the AST into a canonical 'Graph'.
  }

-- | A format-specific writer instance.
data Writer f m = Writer
  { wrtTag    :: Text
    -- ^ Unique format tag.
  , wrtEject  :: forall a. PangrmMonad m => Graph -> m (AST f a)
    -- ^ Generate the format-specific AST from a Pangrm 'Graph'. Reverse to
    -- 'rdrUnify'.
  , wrtRender :: forall a. PangrmMonad m => WrtOpts -> AST f a -> m Text
    -- ^ Render the AST to 'Text' using writer options.
  }

-- | A format that is both readable and writable.
--
-- Must implement:
--
--   * 'getReader' — to obtain the format's 'Reader'
--   * 'getWriter' — to obtain the format's 'Writer'
--
-- Provides default helpers:
--
--   * 'encode' — reads + unifies input into a 'Graph' (ie. Structure -> Text)
--   * 'decode' — ejects + renders a 'Graph' into output 'Text' (ie. Text ->
--   Structure)
--
-- @Note@: The default 'encode' and 'decode' are for library-side reuse
-- and testing — they are not used by the CLI.
class Normalizable f where
  getReader :: PangrmMonad m => Reader f m
  getWriter :: PangrmMonad m => Writer f m

  -- | Reads and normalizes input into a Pangrm 'Graph'.
  encode :: forall m. PangrmMonad m => RdrOpts -> Text -> m Graph
  encode opts txt =
    let rdr = getReader @f @m
     in rdrInject rdr opts txt >>= rdrUnify rdr

  -- | Renders a Pangrm 'Graph' into textual output.
  decode :: forall m. PangrmMonad m => WrtOpts -> Graph -> m Text
  decode opts graph =
    let wrt = getWriter @f @m
     in wrtEject wrt graph >>= wrtRender wrt opts

{-| A complete roundtrippable Pangrm format.

Any Pangrm format must define:

- A unique type-level tag ('HasTag')
- An associated 'AST' implementation ('HasAST')
- A 'Reader' instance for parsing and unification ('Normalizable')
- A 'Writer' instance for ejection and rendering ('Normalizable')

Additionally, the associated 'AST' must satisfy:

- 'Functor', 'Foldable', 'Traversable'
- Provide source position and optional origin metadata

These constraints guarantee that all formats are:

- Roundtrippable (can parse and render consistently)
- Type-safe and discoverable via the Pangrm Registry
- Composable within the Pangrm transformation pipeline
- Traceable and auditable via AST and Graph mappings
-}
class ( HasTag f
      , HasAST f
      , Functor (AST f)
      , Foldable (AST f)
      , Traversable (AST f)
      , Normalizable f)
  => Roundtrippable f

