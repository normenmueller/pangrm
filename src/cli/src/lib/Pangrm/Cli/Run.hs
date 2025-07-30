{-# LANGUAGE GeneralizedNewtypeDeriving #-}

{-|
Module      : Pangrm.Cli.Run
Description : CLI execution logic and top-level monad stack.

This module defines the Pangrm CLI **execution context**.

It provides:

* The `App` monad (used throughout the CLI)
* The `runApp` function to run CLI commands
* Monad instances for state, error, IO, and CLI access

== Architecture

@
                  Opt (CLI args)
                      ↓
      ┌────────────────────────────┐
      │        ReaderT Opt         │
      │   (Pangrm.Cli.Run.App)     │
      └────────────────────────────┘
                      ↓
         PangrmIO: mutable state,
             error + IO layer
@

== Responsibilities

* Load CLI arguments into the App context
* Handle state, logging, tracing, errors
* Route CLI commands through the registry and backend

This module should be imported by the `Main` program via:

@
import Pangrm.Cli (pangrm)
@

All higher CLI composition is layered on top of this core runner.
-}
module Pangrm.Cli.Run
  ( App(..)
  , runApp
  ) where

import Prelude hiding ((<>))
import Control.Monad.Except
import Control.Monad.Reader
import Control.Monad.State
import Data.Default
import Prettyprinter
import Prettyprinter.Render.Terminal (putDoc)

import Pangrm.Core
import Pangrm.Shared

import Pangrm.Cli.Opt (Opt(..))

-- | Internal Pangrm backend monad.
--
-- This monad stacks:
--
-- * 'ExceptT PangrmError' for structured error handling
-- * 'StateT PangrmState' for mutable state
-- * 'IO' for file and system access
--
-- This monad forms the base layer for Pangrm's CLI and format runners.
newtype PangrmIO a = PangrmIO
  { unPangrmIO :: ExceptT PangrmError (StateT PangrmState IO) a
  }
  deriving ( Functor
           , Applicative
           , Monad
           , MonadIO
           , MonadError PangrmError
           )

-- | Run a Pangrm backend action in IO.
--
-- This initializes the 'PangrmState' with 'def' and executes the action.
-- Errors are captured and returned via 'Either'.
runIO :: PangrmIO a -> IO (Either PangrmError a)
runIO ma = flip evalStateT def . runExceptT $ unPangrmIO ma

-- | 'PangrmMonad' instance for 'PangrmIO'.
--
-- This provides:
--   * Access to the mutable 'PangrmState' via 'getState' and 'putState'
--   * Direct logging to @stderr@ using 'logOutput' for immediate feedback
--
-- Note: Unlike 'App', 'PangrmIO' does not accumulate structured logs.
instance PangrmMonad PangrmIO where
  getState = PangrmIO $ lift get
  putState = PangrmIO . lift . put
  --logOutput = liftIO . (PP.hPutDoc stderr . (<> line) . pretty)
  logOutput = liftIO . putDoc . (<> line) . renderLogMsg

-- | Pangrm CLI monad with access to CLI options and Pangrm state.
--
-- This monad layers:
--
-- * 'ReaderT Opt' for CLI arguments
-- * 'PangrmIO' for mutable state, errors, and IO
--
-- All CLI commands and format logic are executed within this monad.
newtype App a = App
  { unApp :: ReaderT Opt PangrmIO a
  }
  deriving ( Functor
           , Applicative
           , Monad
           , MonadIO
           , MonadReader Opt
           , MonadError PangrmError
           )

-- | 'PangrmMonad' instance for 'App'.
--
-- This delegates 'PangrmMonad' methods to the inner 'PangrmIO' layer,
-- ensuring that 'App' behaves as a fully valid 'PangrmMonad' instance.
instance PangrmMonad App where
  getState = App . lift $ getState
  putState = App . lift . putState
  logOutput = App . lift . logOutput

{- Note for contributors:
Pangrm uses a dual logging strategy:

* Logging within the 'PangrmMonad' via 'report' and 'logOutput'
  (Both write to 'stderr' for immediate feedback.)

* The CLI does NOT accumulate logs separately — Logging is streamed directly via
'logOutput'.

This ensures a clear separation of:
- Logs & diagnostics (on 'stderr')
- Data output (on 'stdout')

Correct usage example:

  $ pangrm input.ldif --to cql > output.cql

  [info] Reading input.ldif   -- logged to stderr (visible)
  [debug] Parsing complete    -- logged to stderr (visible)
  (cql statements)            -- program output on stdout (redirected)

Do NOT mix logging and program output — only use 'stdout' for result data.
-}

-- | Run an 'App' computation using the provided CLI options.
--
-- Internally invokes 'runIO' and returns structured errors or results.
--
-- This function is used by the CLI entry point to launch the Pangrm pipeline.
runApp :: App a -> Opt -> IO (Either PangrmError a)
runApp app ops = runIO $ runReaderT (unApp app) ops

