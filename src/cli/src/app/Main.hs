{-# LANGUAGE LambdaCase #-}

{-|
Module      : Main
Description : Main entry point for the Pangrm CLI application.

This module handles:
  * Command-line argument parsing
  * Validation of user input
  * Delegation to the Pangrm CLI application logic ('Pangrm.Cli')

Fails fast on invalid input and prints diagnostics to stderr.

Example usage:
@
> pangrm --from ldif --to cql input.ldif -o output.cql
@
-}
module Main where

import Options.Applicative
import System.IO (hSetEncoding, stderr, stdin, stdout, utf8)

import Pangrm.Cli
import Pangrm.Shared

-- | The main CLI entry point.
--
-- Parses CLI arguments, validates them, and dispatches to the Pangrm
-- application logic. Terminates with a failure code if validation or execution
-- fails.
main :: IO ()
main = do
  -- Ensure all I/O uses UTF-8
  hSetEncoding stdin utf8
  hSetEncoding stdout utf8
  hSetEncoding stderr utf8
  args <- execParser cmdln
  validateArgs args >>= \case
    Left err -> handleError (Left err)
    Right opts -> runApp pangrm opts >>= handleError

