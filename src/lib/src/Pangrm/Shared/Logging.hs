{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveDataTypeable #-}

{-|
Module      : Pangrm.Shared.Logging
Description : Verbosity levels and structured log messages for Pangrm.

This module defines Pangrm's internal logging levels via 'Verbosity',
and the structured log type 'LogMessage'.

It also provides rendering logic to:

* Convert 'LogMessage's to color-coded CLI output
* Attach severity to each message (via 'levelLogMsg')

This logging system is used by the Pangrm monad and CLI reporting.
-}
module Pangrm.Shared.Logging
  ( Verbosity(..)
  , LogMessage(..)
  , renderLogMsg
  , levelLogMsg
  ) where

import Data.Text (Text)
import Data.Data (Data)
import Data.Typeable (Typeable)
import Prettyprinter
import Prettyprinter.Render.Terminal (AnsiStyle, color, Color(..))
import GHC.Generics (Generic)

-- | Verbosity level for controlling log output (from QUIET to DEBUG).
-- quite < error < warning < info < debug
data Verbosity
  = QUIET
  | ERROR
  | WARNING
  | INFO
  | DEBUG
  deriving (Show, Read, Eq, Data, Enum, Ord, Bounded, Typeable, Generic)

-- | Structured log message with severity level.
data LogMessage
  = LogError Text
  | LogWarn Text
  | LogInfo Text
  | LogDebug Text
  deriving (Eq, Show)

-- Generic `Pretty` instance (NO color!)
instance Pretty LogMessage where
  pretty =
    \case
      LogError msg -> brackets "error" <+> pretty msg
      LogWarn msg -> brackets "warning" <+> pretty msg
      LogInfo msg -> brackets "info" <+> pretty msg
      LogDebug msg -> brackets "debug" <+> pretty msg

-- | Render a log message with optional ANSI color for CLI output.
renderLogMsg :: LogMessage -> Doc AnsiStyle
renderLogMsg =
  \case
    LogError msg -> annotate (color Red) "[error]" <+> pretty msg
    LogWarn msg -> annotate (color Yellow) "[warning]" <+> pretty msg
    LogInfo msg -> annotate (color Blue) "[info]" <+> pretty msg
    LogDebug msg -> "[debug]" <+> pretty msg

-- | Return the severity level associated with a log message.
levelLogMsg :: LogMessage -> Verbosity
levelLogMsg =
  \case
    LogError _ -> ERROR
    LogWarn _ -> WARNING
    LogInfo _ -> INFO
    LogDebug _ -> DEBUG

