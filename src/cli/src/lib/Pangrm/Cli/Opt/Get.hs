module Pangrm.Cli.Opt.Get
  ( cliVerbosity
  , cliTracing
  , cliFrom
  , cliInput
  , cliTo
  , cliOutput
  , cliStrictMode
  , cliStripComments
  , cliPrettify
  , cliBindings
  , cliPrefixes
  ) where

import Data.Text
import qualified Data.Map.Strict as Map
import Optics

import Pangrm.Shared.Logging (Verbosity)

import Pangrm.Cli.Opt

-- * GlbOpts

-- | Get the CLI verbosity setting (e.g., 'DEBUG', 'INFO', 'WARNING', 'QUIET').
cliVerbosity :: Opt -> Verbosity
cliVerbosity = view (opGlb % goVbl)

-- | Whether developer tracing ('--trace') is enabled.
cliTracing :: Opt -> Bool
cliTracing = view (opGlb % goTrc)

-- *JobSpec

-- | Get the input file path from CLI arguments.
cliInput :: Opt -> FilePath
cliInput = view (opJob % jsSrc)

-- | Get the optional output file path.
-- Returns 'Nothing' if writing to stdout.
cliOutput :: Opt -> Maybe FilePath
cliOutput = view (opJob % jsTgt)

-- | Get the input format tag (e.g., @"ldif"@).
cliFrom :: Opt -> Text
cliFrom = view (opJob % jsFrom)

-- | Get the output format tag (e.g., @"cql"@).
cliTo :: Opt -> Text
cliTo = view (opJob % jsTo)

-- * RdrOpts

-- | Whether strict parsing mode ('--strict') is enabled.
cliStrictMode :: Opt -> Bool
cliStrictMode = view (opRdr % roStrict)

-- | Whether comments should be stripped during parsing.
cliStripComments :: Opt -> Bool
cliStripComments = view (opRdr % roStripComments)

-- * WrtOpts

-- | Whether pretty-printing of output is enabled.
cliPrettify :: Opt -> Bool
cliPrettify = view (opWrt % woPrettify)

-- | Get key-value bindings passed via '--binding' or '--bindings'.
cliBindings :: Opt -> Map.Map Text Text
cliBindings = view (opWrt % woBindings)

-- | Get prefix mappings passed via '--prefix' or '--prefixes'.
cliPrefixes :: Opt -> Map.Map Text Text
cliPrefixes = view (opWrt % woPrefixes)

