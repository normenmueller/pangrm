{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}

{-|
Module      : Pangrm.Shared.Error
Description : Pangrm-wide error type and unified error handling.

This module defines the top-level error type for Pangrm and provides helpers
for:

* Constructing errors for IO, validation, format issues, and internal bugs
* Rendering structured and color-coded error messages for the CLI
* Mapping errors to meaningful Unix-style exit codes

The PangrmError type separates user-facing issues from developer bugs,
making both CLI interaction and library use clear and debuggable.
-}
module Pangrm.Shared.Error
  ( PangrmError(..)
  , vErr
  , ioErr
  , fmtErr
  , bug
  , handleError
  ) where

import Control.Exception (Exception)
import Data.Text (Text)
import Data.Typeable (Typeable)
import Prettyprinter
import Prettyprinter.Render.Terminal (AnsiStyle, Color(..), color, putDoc)
import System.Exit (ExitCode(..), exitWith)

-- | Top-level error type used across CLI and library
data PangrmError
  = PangrmIOError Text IOError -- ^ IO error (e.g. file not found)
  | PangrmValidationError Text -- ^ CLI argument validation failure
  | PangrmFormatError Text -- ^ Format-related (Reader/Writer) failure
  | PangrmInternalError Text -- ^ Unexpected internal error
  deriving (Eq, Show, Typeable)

instance Exception PangrmError

-- Generic `Pretty` instance (NO color!)
instance Pretty PangrmError where
  pretty (PangrmIOError msg _)       = pretty msg
  pretty (PangrmValidationError msg) = pretty msg
  pretty (PangrmFormatError msg)     = pretty msg
  pretty (PangrmInternalError msg)   = pretty msg

-- Colored CLI-rendering
renderError :: PangrmError -> Doc AnsiStyle
renderError =
  \case
    PangrmIOError msg io ->
      annotate (color Red) "[error]" <+> pretty msg <> line <> pretty (show io)
    PangrmValidationError msg -> annotate (color Red) "[error]" <+> pretty msg
    PangrmFormatError msg -> annotate (color Red) "[error]" <+> pretty msg
    PangrmInternalError msg -> annotate (color Red) "[error]" <+> pretty msg

vErr :: Text -> PangrmError
vErr = PangrmValidationError

ioErr :: Text -> IOError -> PangrmError
ioErr = PangrmIOError

fmtErr :: Text -> PangrmError
fmtErr = PangrmFormatError

bug :: Text -> PangrmError
bug = PangrmInternalError

-- Unified rendering and exit
handleError :: Either PangrmError a -> IO a
handleError =
  \case
    Right x -> pure x
    Left e -> putDoc (renderError e <> line) >> exitWith (exitCodeOf e)

-- | Maps 'PangrmError' variants to Unix-style exit codes.
exitCodeOf :: PangrmError -> ExitCode
exitCodeOf =
  \case
    PangrmIOError {} -> ExitFailure 1
    PangrmValidationError {} -> ExitFailure 2
    PangrmFormatError {} -> ExitFailure 3
    PangrmInternalError {} -> ExitFailure 4

