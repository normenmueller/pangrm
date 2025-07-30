{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE OverloadedStrings #-}

-- |
-- Module      : Pangrm.Cli.Opt.Job
-- Description : CLI parser for input/output format tags and files.
--
-- This module defines the 'JobSpec' type, which describes the transformation
-- job to be performed by Pangrm: input format, input file, output format,
-- and output destination.
--
-- The CLI parser 'jsOpt provides these options via optparse-applicative.
--
-- === Example
--
-- @
-- pangrm --from ldif --to cql input.ldif -o output.cql
-- @
module Pangrm.Cli.Opt.Job
  ( JobSpec(JobSpec)
  , jobSpec
  , jsFrom, jsSrc, jsTo, jsTgt
  ) where

import Data.Text (Text)
import Options.Applicative
import Optics.TH (makeLenses)

-- | Specifies a Pangrm transformation job from one format to another.
-- Parsed from CLI using `jobSpec`. Passed to CLI pipeline runner.
data JobSpec = JobSpec
  { _jsFrom :: Text
    -- ^ Input format tag (e.g. "ldif")
  , _jsSrc :: FilePath
    -- ^ Input file path
  , _jsTo :: Text
    -- ^ Output format tag (e.g. "cql")
  , _jsTgt :: Maybe FilePath
    -- ^ Optional output file path (writes to stdout if 'Nothing')
  } deriving (Eq, Show)

makeLenses ''JobSpec

-- | CLI parser for a single job specification.
--
-- Parses the format tags, input file, and optional output file.
--
-- === Options
--
--   * @--from/-f FORMAT@ — input format tag
--   * @INPUT@ — input file (positional)
--   * @--to/-t FORMAT@ — output format tag
--   * @--output/-o FILE@ — optional output file
jobSpec :: Parser JobSpec
jobSpec =
  JobSpec
    <$> from
    <*> input
    <*> to
    <*> output

-- | Parse the input format tag.
from :: Parser Text
from =
  strOption
    (long "from" <> short 'f' <> metavar "FORMAT" <> help "Input format tag")

-- | Parse the input file argument.
input :: Parser FilePath
input = argument str (metavar "INPUT" <> help "Input file")

-- | Parse the output format tag.
to :: Parser Text
to =
  strOption
    (long "to" <> short 't' <> metavar "FORMAT" <> help "Output format tag")

-- | Parse the optional output file argument.
output :: Parser (Maybe FilePath)
output =
  optional
    (strOption
      (long "output" <> short 'o' <> metavar "OUTPUT" <> help "Output file"))

