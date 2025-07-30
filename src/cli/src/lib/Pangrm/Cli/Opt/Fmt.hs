{-# LANGUAGE OverloadedStrings #-}

-- |
-- Module      : Pangrm.Cli.Opt.Fmt
-- Description : CLI parsers for format-specific Reader and Writer options.
--
-- This module provides CLI parsers for:
--
-- * Reader options: --strict, --strip-comments
-- * Writer options: --prettify, --bindings, --prefixes
--
-- These values are collected into 'RdrOpts' and 'WrtOpts', defined in
-- "Pangrm.Shared.Options", and passed to Reader/Writer logic.
module Pangrm.Cli.Opt.Fmt
  ( rdrOpts
  , roStrict, roStripComments
  , wrtOpts
  , woPrettify, woBindings, woPrefixes
  ) where

import qualified Data.Text as T
import Data.Text (Text)
import qualified Data.Map.Strict as Map
import Data.Map.Strict (Map)
import Options.Applicative

import Pangrm.Shared.Options -- contains RdrOpts & WrtOpts!

-- | CLI parser for reader-specific options.
-- Includes:
--
-- * '--strict' — enables strict parsing mode
-- * '--strip-comments' — removes comments from input
rdrOpts :: Parser RdrOpts
rdrOpts = RdrOpts <$> strict <*> stripcmt

-- | Enables strict parsing.
-- Fails on minor deviations from spec (e.g. unknown fields).
strict :: Parser Bool
strict =
  switch
    (long "strict"
       <> help "Enable strict parsing.")

-- | Removes comments during parsing.
-- Useful for normalization or testing.
stripcmt :: Parser Bool
stripcmt =
  switch
    (long "strip-comments"
       <> help "Strip comments.")

-- | CLI parser for writer-specific options.
-- Includes:
--
-- * '--prettify' — enables pretty output
-- * '--bindings' / '--binding' — injects key-value bindings
-- * '--prefixes' / '--prefix' — defines render-time prefix mappings
wrtOpts :: Parser WrtOpts
wrtOpts = WrtOpts <$> pretty <*> bindings <*> prefixes

-- | Enables pretty-printing of output.
-- Applies indentation, line breaks, and normalized field ordering.
pretty :: Parser Bool
pretty =
  switch
    (long "prettify"
       <> help "Enable pretty output")

-- | Parses multiple bindings (key-value mappings) from the CLI.
-- Accepts:
--
-- * Repeated '--binding KEY=VAL'
-- * CSV-style '--bindings "A=B,C=D"'
--
-- Keys default to @\"true\"@ if value is omitted.
bindings :: Parser (Map Text Text)
bindings = Map.unions <$> sequenceA
  [ bindingsCsv <|> pure Map.empty
  , fmap Map.fromList $
      many $ option (eitherReader parseKV)
        ( long "binding"
       <> metavar "KEY[=VAL]"
       <> help "Add individual bindings"
        )
  ]

-- | Parses multiple bindings from a CSV string.
-- Example: @--bindings "A=1,B=2"@
bindingsCsv :: Parser (Map Text Text)
bindingsCsv =
  option csvKV
    ( long "bindings"
   <> metavar "\"KEY=VAL,...\""
   <> help "Set multiple bindings at once"
    )

-- | Parses multiple prefixes (key-to-namespace mappings).
-- Accepts:
--
-- * Repeated '--prefix KEY=VAL'
-- * CSV-style '--prefixes "ns1=http://...,ns2=..."'
--
-- Keys without =VAL default to @\"true\"@.
prefixes :: Parser (Map Text Text)
prefixes = Map.unions <$> sequenceA
  [ prefixesCsv <|> pure Map.empty
  , fmap Map.fromList $
    many $ option (eitherReader parseKV)
        ( long "prefix"
       <> metavar "KEY[=VALUE]"
       <> help "Set a prefix (key=value or key=true)"
        )
   ]

-- | Parses multiple prefixes from a CSV string.
-- Example: @--prefixes "x=http://x.org,y=http://y.org"@
prefixesCsv :: Parser (Map Text Text)
prefixesCsv =
  option csvKV
    ( long "prefixes"
   <> metavar "\"KEY=VAL,...\""
   <> help "Set multiple prefixes at once"
    )

-- | Parses a CSV string of key=value pairs into a Map.
-- Returns an error if any entry is malformed.
csvKV :: ReadM (Map Text Text)
csvKV = eitherReader $ \csv ->
  let items = splitBy ',' csv
  in fmap Map.fromList . traverse parseKV $ items

-- | Splits a list at a delimiter.
-- Behaves like 'splitOn' but implemented locally to avoid dependencies.
splitBy :: Eq a => a -> [a] -> [[a]]
splitBy delim = foldr go [[]]
  where
    go c acc@(x:xs)
      | c == delim = [] : acc
      | otherwise  = (c : x) : xs
    go _ _ = error "unreachable"

-- | Parses a single key=value or key CLI argument.
--
-- * 'a=b' yields @(\"a\", \"b\")@
-- * 'a'   yields @(\"a\", \"true\")@
--
-- Keys must not be empty.
parseKV :: String -> Either String (Text, Text)
parseKV kv =
  case break (== '=') kv of
    ("", _)         -> Left "Empty key not allowed"
    (k, '=':v)      -> Right (T.strip . T.pack $ k, T.strip . T.pack $ v)
    (k, "")         -> Right (T.strip . T.pack $ k, "true")
    (_, _nonEqRest) -> Left "Missing '=' in key=value"

