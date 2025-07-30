-- |
-- Module      : Pangrm
-- Description : Primary public entry point for the Pangrm library.
--
-- This module re-exports the essential components of Pangrm for most users:
--
--   * 'PangrmMonad' interface and state primitives from "Pangrm.Core"
--   * Format abstractions: 'Reader', 'Writer', 'HasAST', 'HasOpt', etc.
--   * The central registry of all registered formats ('lookupFormat', etc.)
--   * Logging utilities, errors, and global options from "Pangrm.Shared"
--
-- This is the preferred import for downstream tools, CLI integrations, and
-- converters.
module Pangrm
  ( -- * Monad & State
    module Pangrm.Core
  , -- * Format Registry (dynamic dispatch)
    Entry(..)
  , entries
  , entryFor
  , -- * Options, Error & Logging
    module Pangrm.Shared
  ) where

import Pangrm.Core
import Pangrm.Registry
import Pangrm.Shared

