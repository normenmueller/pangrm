{-|
Module      : Pangrm.Cli.Fio
Description : Provides simple file IO operations for the CLI.

This module defines CLI-side file input/output helpers:

* 'slurp' — safe file read with error capture
* 'flush' — safe file write with optional stdout fallback

All functions return 'Either IOError' to allow structured error handling.

Note:
  These helpers do not perform any PangrmMonad actions
  and are intended solely for the CLI frontend.

Example:

@
case slurp "input.ldif" of
  Left ioErr -> print ("Read failed: " <> show ioErr)
  Right content -> ...
@
-}
module Pangrm.Cli.Fio
  ( slurp
  , flush
  ) where

import Control.Exception (try)
import qualified Data.Text as T
import qualified Data.Text.IO as TIO
import Data.Text (Text)
import System.IO (withFile, IOMode(..), hPutStrLn)

-- | Safely read a UTF-8 encoded file.
-- Assumes UTF-8 encoding. No BOM handling.
--
-- Returns:
-- * 'Right' with file content
-- * 'Left' with IOError on failure
slurp :: FilePath -> IO (Either IOError Text)
slurp fp = try (TIO.readFile fp)

-- | Safely write content to a file or stdout.
--
-- * If 'Nothing' → writes to stdout
-- * If 'Just filepath' → writes to the file
--
-- Returns:
-- * 'Right' on success
-- * 'Left' with IOError on failure
flush :: Maybe FilePath -> Text -> IO (Either IOError ())
flush mfp out =
  let raw = T.unpack out
   in try
        $ maybe
            (putStrLn raw)
            (\fp -> withFile fp WriteMode (`hPutStrLn` raw))
            mfp
