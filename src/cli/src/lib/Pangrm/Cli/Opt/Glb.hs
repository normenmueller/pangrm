{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE OverloadedStrings #-}

module Pangrm.Cli.Opt.Glb
  ( GlbOpts(GlbOpts)
  , glbOpts
  , goVbl, goTrc
  ) where

import Data.Default
import Optics.TH (makeLenses)
import Options.Applicative

import Pangrm.Shared.Logging (Verbosity (..))

-- | Global options that apply to all Pangrm CLI commands.
--
-- Includes:
--
-- * Verbosity level (e.g., --debug, --quiet)
-- * Developer tracing toggle (--trace)
data GlbOpts = GlbOpts
  { _goVbl :: Verbosity
  , _goTrc :: Bool
  } deriving (Eq, Show)

makeLenses ''GlbOpts

instance Default GlbOpts where
  def = GlbOpts
    { _goVbl = WARNING
    , _goTrc = False
    }

-- | Parser for the CLI-visible subset of 'GlobalOptions'.
--
-- Includes:
--
--   * Verbosity flags: --debug / --verbose / --quiet
--   * Tracing flag:    --trace
--
-- Returns a 'GlobalOptions' value populated from CLI arguments.
glbOpts :: Parser GlbOpts
glbOpts = GlbOpts <$> verbosity <*> tracing

-- | CLI verbosity flag parser.
--
-- Selects a 'Verbosity' level using one of:
--
-- > --debug    (most verbose)
-- > --verbose  (informational)
-- > --quiet    (only errors)
--
-- Defaults to 'WARNING' if omitted.
verbosity :: Parser Verbosity
verbosity =
  flag' DEBUG (long "debug" <> help "Enable debug output (very verbose)")
    <|> flag' INFO (long "verbose" <> help "Enable verbose output (informational)")
    <|> flag' QUIET (long "quiet" <> help "Suppress all output except errors")
    <|> pure WARNING

-- | Developer-only debug tracing toggle.
--
-- > --trace
--
-- Emits internal debug traces at runtime (stderr). Default: False.
tracing :: Parser Bool
tracing =
  switch
    (long "trace"
       <> help "Enable developer tracing (low-level debug output to stderr)")

