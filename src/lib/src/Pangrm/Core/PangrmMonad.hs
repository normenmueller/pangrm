{-# LANGUAGE FlexibleContexts #-}

{-|
Module      : Pangrm.Core.PangrmMonad
Description : The monad interface required for all Pangrm transformations.

This module defines the 'PangrmMonad' type class — the unified monad interface
that all Pangrm readers and writers operate within.

It provides controlled access to:

  * Global mutable state ('PangrmState')
  * Error handling via 'MonadError'
  * Logging (both structured and immediate)
  * Tracing and debugging support

All Pangrm library components (e.g., Reader, Writer, Registry) rely on this
abstraction.

Note: 'PangrmMonad' intentionally abstracts over IO. Actual IO is only performed
by concrete instances (e.g., 'PangrmIO' used by the CLI).

== Design Goals:

  * Clean separation of concerns for effectful operations
  * Unified interface for readers/writers & CLI components
  * Explicit, testable, and easily mockable in unit tests
-}
module Pangrm.Core.PangrmMonad
  ( PangrmMonad(..)
  , report
  , getTracing
  , setTracing
  , getLog
  , clearLog
  , setVerbosity
  , getVerbosity
  ) where

import Control.Monad.Except
import Control.Monad (when)
import qualified Debug.Trace
import qualified Data.Text as T

import Pangrm.Shared
import Pangrm.Core.PangrmState

{-|
The @PangrmMonad@ class defines the monadic operations required by the Pangrm
ecosystem.

This includes:

  * Access to shared mutable state ('getState', 'putState', 'modifyState')
  * Structured logging & diagnostics ('report')
  * Immediate logging side-effects ('logOutput')
  * Tracing support ('trace')

This abstraction allows full separation between core logic and side-effects.
Pangrm components can be tested using mock monads that implement this class.
E.g. with a simplen Identity/StateT instance

@
newtype TestM a = TestM (StateT PangrmState (Except PangrmError) a)
@

@Note@:
This typeclass abstracts over any monad stack that supports Pangrm's core
operations. While typically instantiated by 'PangrmIO', alternative instances
(e.g. for testing) are possible.

@Note@:
`trace` outputs a debug message to sterr, using 'Debug.Trace.trace', if
tracing is enabled.  This writes to stderr even in pure instances.
-}
class (Functor m, Applicative m, Monad m, MonadError PangrmError m)
      => PangrmMonad m where
  getState :: m PangrmState
  putState :: PangrmState -> m ()

  getsState :: (PangrmState -> a) -> m a
  getsState f = f <$> getState

  modifyState :: (PangrmState -> PangrmState) -> m ()
  modifyState f = getState >>= putState . f

  logOutput :: LogMessage -> m ()

  trace :: T.Text -> m ()
  trace msg = do
    tracing <- getTracing
    when tracing $ Debug.Trace.traceM $ "[trace] " ++ T.unpack msg

-- * Utility functions for PangrmMonad

-- | Set the verbosity level.
setVerbosity :: PangrmMonad m => Verbosity -> m ()
setVerbosity v = modifyState $ \st -> st {stVbl = v}

-- | Get the verbosity level.
getVerbosity :: PangrmMonad m => m Verbosity
getVerbosity = getsState stVbl

-- | Get the accumulated log messages (in temporal order).
getLog :: PangrmMonad m => m [LogMessage]
getLog = reverse <$> getsState stLog

-- | Clears all accumulated logs.
clearLog :: PangrmMonad m => m ()
clearLog = modifyState $ \st -> st { stLog = [] }

-- | Record a log message into the internal log buffer (always),
-- and optionally emit it immediately if verbosity allows.
--
-- Use this for regular, structured logging inside Pangrm components.
--
-- See also:
--   * 'getLog' to retrieve accumulated messages
--   * 'logOutput' for immediate side effects (typically implemented by the CLI)
report :: PangrmMonad m => LogMessage -> m ()
report msg = do
  threshold <- getVerbosity
  when (levelLogMsg msg <= threshold) $ logOutput msg
  modifyState $ \st -> st{ stLog = msg : stLog st }

-- | Check if debug tracing is currently enabled.
--
-- Controlled via 'goTracing' in 'GlobalOptions'.
getTracing :: PangrmMonad m => m Bool
getTracing = getsState stTrc

-- | Enable or disable debug tracing globally.
--
-- Controlled via 'goTracing' in 'GlobalOptions'.
setTracing :: PangrmMonad m => Bool -> m ()
setTracing b = modifyState $ \st -> st { stTrc = b }

