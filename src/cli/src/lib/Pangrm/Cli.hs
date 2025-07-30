{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE LambdaCase #-}

{-|
Module      : Pangrm.Cli
Description : CLI-facing entry point for executing Pangrm transformations.

This module defines the CLI command dispatcher `pangrm`, which:
  * Executes the Pangrm transformation pipeline
  * Delegates format-specific parsing and rendering to registered formats
  * Handles input/output via safe file IO

@Note@:
The `Pangrm.Cli` module serves as the orchestrator for CLI-driven use cases.
It wraps common operations like reader/ writer lookup, error handling, and file
IO.

Pangrm's core processing pipeline:

@
raw <- slurp' input
graph <- withReader fromFormat readerOpts raw
result <- withWriter toFormat writerOpts graph
flush' output result
@

-}
module Pangrm.Cli
  ( pangrm
  , module Pangrm.Cli.Opt
  , module Pangrm.Cli.Arg
  , module Pangrm.Cli.Fio
  , module Pangrm.Cli.Run
  ) where

import Control.Monad (forM_, unless)
import Control.Monad.Except
import Control.Monad.IO.Class (liftIO)
import Control.Monad.Reader (ask)
import Data.Default
import Data.Maybe
import Data.Text (Text)

import qualified Pangrm.Registry as Reg
import Pangrm.Core
import Pangrm.Shared

import Pangrm.Cli.Run
import Pangrm.Cli.Arg
import Pangrm.Cli.Fio
import Pangrm.Cli.Opt
import Pangrm.Cli.Opt.Get

-- | Read input, transform via Pangrm, and write output.
--
-- This is the CLI entry point that:
--
-- * Validates format tags
-- * Loads and logs input text
-- * Dispatches to registered Reader and Writer
-- * Produces output text and writes it to file or stdout
pangrm :: App ()
pangrm = do
  opt <- ask
  let verbosity = cliVerbosity opt
      fromTag   = cliFrom opt
      toTag     = cliTo opt
      inPath    = cliInput opt
      outPath   = cliOutput opt

  setVerbosity verbosity

  forM_ [("input", fromTag), ("output", toTag)] $ \(kind, tagName) ->
    unless (isRegisteredFormat tagName)
      $ throwError
      $ vErr
      $ "Unknown " <> kind <> " format: " <> tagName

  raw <- slurp' inPath
  report $ LogInfo "Input read."
  report $ LogDebug ("Raw content:\n" <> raw)
  grf <- withReader (cliFrom opt) (def @RdrOpts) raw
  raw' <- withWriter (cliTo opt) (def @WrtOpts) grf
  flush' outPath raw'

  where
    isRegisteredFormat :: Text -> Bool
    isRegisteredFormat tagName = isJust (Reg.entryFor @App tagName)

-- | Wrapper around 'slurp' with Pangrm error handling.
--
-- Used to read CLI input files. Converts IO exceptions into structured errors.
slurp' :: FilePath -> App Text
slurp' fp = do
  result <- liftIO $ slurp fp
  case result of
    Left err -> throwError $ ioErr "Unable to read input" err
    Right txt -> return txt

-- | Executes a registered Reader pipeline.
--
-- Looks up the Reader for a format tag, parses the raw text into AST,
-- then converts it to a Pangrm Graph.
withReader :: Text -> RdrOpts -> Text -> App Graph
withReader tagName opts input =
  getFormat tagName >>= \case
    Left err -> throwError err
    Right (Reg.Entry _ reader _) ->
      rdrInject reader opts input >>= rdrUnify reader

-- | Executes a registered Writer pipeline.
--
-- Looks up the Writer for a format tag, converts a Graph into AST,
-- then renders it as formatted Text.
withWriter :: Text -> WrtOpts -> Graph -> App Text
withWriter tagName opts graph =
  getFormat tagName >>= \case
    Left err -> throwError err
    Right (Reg.Entry _ _ writer) ->
      wrtEject writer graph >>= wrtRender writer opts

-- | Lookup a registered format entry by tag name.
--
-- Returns 'Left' if the format is not found.
getFormat :: Text -> App (Either PangrmError (Reg.Entry App))
getFormat tagName =
  pure
    $ maybe
        (Left $ fmtErr $ "Unknown format: " <> tagName)
        Right
        (Reg.entryFor @App tagName)

-- | Wrapper around 'flush' with Pangrm error handling.
--
-- Used to write output either to a file or stdout.
flush' :: Maybe FilePath -> Text -> App ()
flush' mfp out = do
  result <- liftIO $ flush mfp out
  case result of
    Left err -> throwError $ ioErr "Unable to write output" err
    Right () -> return ()

