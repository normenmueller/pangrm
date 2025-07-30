{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE LambdaCase #-}

{-|
Module      : Pangrm.Cli.Arg
Description : Validation of parsed CLI arguments.

This module provides validation for parsed CLI options.

It performs the following levels of checks:

* Source file existence validation ('validateSource')
* Output file location validation ('validateTarget')

These validations ensure that Pangrm fails fast on CLI misuse
and provides clear diagnostics before running any transformations.
-}
module Pangrm.Cli.Arg
  ( validateArgs
  ) where

import qualified Data.Text as T
import System.Directory
import System.FilePath

import Pangrm.Shared
import Pangrm.Cli.Opt
import Pangrm.Cli.Opt.Get

-- | Validate CLI arguments.
--
-- Checks:
--
-- * Input file existence
-- * Output file validity (directory check, parent check)
-- * Known format tags (input & output)
--
-- Returns:
--
-- * @Right opts@ — if all checks pass
-- * @Left [Text]@ — with validation error messages
validateArgs :: Opt -> IO (Either PangrmError Opt)
validateArgs opt =
  (validateSource . cliInput $ opt) >>= \case
    Left err -> pure . Left $ err
    Right () ->
      (validateTarget . cliOutput $ opt) >>= \case
        Left err -> pure . Left $ err
        Right () -> pure . Right $ opt

-- | Checks whether the input file exists.
-- Returns 'Left' if the file is missing, with a diagnostic message.
validateSource :: FilePath -> IO (Either PangrmError ())
validateSource path = do
  exists <- doesFileExist path
  pure $
    if exists
      then Right ()
      else Left $ vErr ("Input file does not exist: " <> T.pack path)

-- | Validates that the output path (if present) is not a directory,
-- and that its parent directory exists.
--
-- Note: Write permissions are not checked here (delegated to 'flush').
validateTarget :: Maybe FilePath -> IO (Either PangrmError ())
validateTarget Nothing = pure . Right $ ()
validateTarget (Just path) = do
  isDir <- doesDirectoryExist path
  if isDir
    then pure . Left . vErr $ "Output path is a directory: " <> T.pack path
    else do
      let parent = takeDirectory path
      parentExists <- doesDirectoryExist parent
      pure $
        if parentExists
          then Right ()
          else Left . vErr $ "Output directory does not exist: " <> T.pack parent

