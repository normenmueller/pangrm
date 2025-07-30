{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE OverloadedStrings #-}

-- |
-- Module      : Pangrm.Cli.Opt
-- Description : Aggregated CLI parser for Pangrm application.
--
-- This is the main parser module used by the Pangrm CLI. It:
--
--   * Combines job specification (from/to/input/output)
--   * Adds global options (verbosity, tracing)
--   * Includes all known Reader/Writer format options (for help display)
--
-- This variant shows all available options statically to allow full --help output.
module Pangrm.Cli.Opt
  ( Opt(Opt)
  , cmdln
  , opJob, opGlb, opRdr, opWrt
  , module Pangrm.Cli.Opt.Glb
  , module Pangrm.Cli.Opt.Job
  , module Pangrm.Cli.Opt.Fmt
  , module Pangrm.Shared.Options -- contains RdrOpts & WrtOpts
  ) where

import Options.Applicative
import Options.Applicative.Help.Pretty (vsep)
import Data.Version (showVersion)
import Paths_pangrm_cli (version)
import Optics.TH (makeLenses)

import Pangrm.Shared.Options

import Pangrm.Cli.Opt.Glb
import Pangrm.Cli.Opt.Job
import Pangrm.Cli.Opt.Fmt

-- | The top-level option record passed to Pangrm runtime.
--
-- Contains:
--
--   * Input/output formats and files ('JobSpec')
--   * Global flags like verbosity and tracing ('GlbOpts')
--   * Reader options ('RdrOpts') and writer options ('WrtOpts')
data Opt = Opt
  { _opJob :: JobSpec
  , _opGlb :: GlbOpts
  , _opRdr :: RdrOpts
  , _opWrt :: WrtOpts
  } deriving (Eq, Show)

makeLenses ''Opt

-- | Top-level CLI parser including version/help/documentation.
--
-- Combines:
--
--   * Standard help/version flags
--   * Aggregated Pangrm option parser
--   * Help footer with usage example
cmdln :: ParserInfo Opt
cmdln =
  info
    (helper <*> vflag <*> opts)
    (fullDesc
       <> header "Pangrm - The universal model converter, © 2025 nemron"
       <> footer')
  where
    vflag = simpleVersioner . showVersion $ version
    footer' = footerDoc . Just .  vsep $
        [ "Example:"
        , "  pangrm --from ldif --to cql input.ldif -o output.cql"
        , ""
        , "Use --help to see all available options."
        ]

-- | Aggregated parser for all Pangrm options.
--
-- Used internally by 'cmdln'.
opts :: Parser Opt
opts = Opt
  <$> jobSpec
  <*> glbOpts
  <*> rdrOpts
  <*> wrtOpts

