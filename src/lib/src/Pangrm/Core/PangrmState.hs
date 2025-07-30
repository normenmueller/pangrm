{-|
Module      : Pangrm.Core.PangrmState
Description : Internal mutable state for the Pangrm monad.

Defines 'PangrmState' — the global state carried during Pangrm operations.

== Responsibilities:
  * Accumulate structured logs for later retrieval
  * Track verbosity level
  * Enable tracing for developer diagnostics
-}
module Pangrm.Core.PangrmState
  ( PangrmState(..)
  ) where

import Data.Default

import Pangrm.Shared

-- | The global mutable state for Pangrm operations.
data PangrmState = PangrmState
  { stLog :: [LogMessage]
    -- ^ Log messages collected during execution (in reverse order).
    -- TODO Use ‘DList’ or ‘Seq’ for better asymptotic properties
  , stVbl :: Verbosity
    -- ^ Current verbosity setting.
  , stTrc :: Bool
    -- ^ Whether trace mode is active (developer debugging aid).
  }

-- | Provides a default Pangrm state:
--   * empty log
--   * verbosity = WARNING
--   * tracing = disabled
instance Default PangrmState where
  def = PangrmState {stLog = [], stVbl = WARNING, stTrc = False}

