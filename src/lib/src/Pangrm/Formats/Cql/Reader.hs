{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE OverloadedStrings #-}

-- |
-- Module      : Pangrm.Formats.Cql.Reader
-- Description : Format-specific reader instance for CQL.
--
-- This module defines the CQL 'Reader', which parses input text into a
-- CQL-specific AST and unifies it into a generic Pangrm 'Graph'.
--
-- This stub implementation is intended for integration and testing purposes
-- only — it does not perform real CQL parsing.
--
-- The reader demonstrates the minimal structure of a format without
-- format-specific options.
module Pangrm.Formats.Cql.Reader
  ( reader
  ) where

import Data.Proxy

import qualified Pangrm.Core.Graph as G
import Pangrm.Core.Format
import Pangrm.Core.PangrmMonad
import Pangrm.Formats.Cql.Format

-- | A dummy CQL reader for testing and integration purposes.
--
-- Parses input into a placeholder AST and returns an empty graph.
-- Demonstrates how to structure a reader without any format-specific options.
reader :: PangrmMonad m => Reader CQL m
reader =
  Reader
    { rdrTag = tag @CQL Proxy
    , rdrInject =
        \_opts _txt ->
          return
            $ CqlEntry
                { cqlEty = error "CQL Reader inject dummy: please replace"
                , cqlEtyName = "dummy"
                , cqlEtyAttr = []
                , cqlEtyLine = 1
                , cqlEtyColumn = 1
                , cqlEtyOrigin = Nothing
                }
    , rdrUnify = \_ast -> return G.empty
    }

