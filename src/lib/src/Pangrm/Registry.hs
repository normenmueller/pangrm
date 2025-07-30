{-# LANGUAGE GADTs #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE ExistentialQuantification #-}

-- |
-- Module      : Pangrm.Registry
-- Description : Central registry of all Roundtrippable Pangrm formats.
--
-- This module defines the dynamic registry used by the CLI and integration
-- tools to discover formats, perform lookups by tag, and access format-specific
-- 'Reader' and 'Writer' instances.
--
-- === Responsibilities
--
--   * Collect all statically registered formats
--   * Enforce that all formats implement 'Roundtrippable'
--   * Support dynamic lookup of formats by tag (used by CLI)
module Pangrm.Registry
  ( Entry(..)
  , entries
  , entryFor
  ) where

import Data.Proxy
import Data.Text (Text)

import Pangrm.Core
import Pangrm.Formats.Cql
import Pangrm.Formats.Ldif

-- | Existential wrapper for a registered Pangrm format.
--
-- This GADT packages a format’s type-level tag and associated I/O machinery.
-- It hides the specific format @f@ behind the 'Roundtrippable' constraint,
-- enabling dynamic dispatch without losing type safety.
--
-- The wrapped values are:
--
--   * 'fmtTag' — format tag (e.g. @"ldif"@ or @"cql"@)
--   * 'fmtReader' — the registered 'Reader' for the format
--   * 'fmtWriter' — the registered 'Writer' for the format
--
-- === Note
--
-- All values require the 'PangrmMonad' constraint to operate,
-- as they invoke logging, error handling, and other effects.
data Entry m where
  Entry :: (Roundtrippable f) =>
    { fmtTag :: forall proxy. proxy f -> Text
    , fmtRdr :: Reader f m
    , fmtWrt :: Writer f m
    } -> Entry m

instance Show (Entry m) where
  show (Entry tagF _ _) = "Entry(" <> show (tagF Proxy) <> ")"

-- | List of all registered Pangrm formats.
--
-- Extend this list manually whenever a new format is introduced.
--
-- @TODO@: Automation via Template Haskell for large quantities. Not necessary
-- for ≤ 10 formats.
entries :: PangrmMonad m => [Entry m]
entries =
  [ Entry (tag @CQL) (getReader @CQL) (getWriter @CQL)
  , Entry (tag @LDIF) (getReader @LDIF) (getWriter @LDIF)
  ]

-- | Lookup a registered format by its tag.
--
-- Returns 'Nothing' if no format with that tag is registered.
entryFor :: PangrmMonad m => Text -> Maybe (Entry m)
entryFor t =
  lookup
    t
    [ (tagF Proxy, fe)
    | fe@(Entry tagF _ _) <- entries
    ]

