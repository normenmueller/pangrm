{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE OverloadedStrings #-}

-- |
-- Module      : Pangrm.Formats.Cql.Writer
-- Description : Format-specific writer instance for CQL.
module Pangrm.Formats.Cql.Writer
  ( writer
  ) where

import Data.Proxy
import Optics

import Pangrm.Core
import Pangrm.Shared
import Pangrm.Formats.Cql.Format

writer :: PangrmMonad m => Writer CQL m
writer =
  Writer
    { wrtTag = tag @CQL Proxy
    , wrtEject =
        \_g ->
          return
            $ CqlEntry
                { cqlEty = error "CQL Writer eject dummy: please replace"
                , cqlEtyName = "dummy"
                , cqlEtyAttr = []
                , cqlEtyLine = 1
                , cqlEtyColumn = 1
                , cqlEtyOrigin = Nothing
                }
    , wrtRender =
        \opts _ast ->
          if opts ^. woPrettify
            then report (LogDebug "-- pretty CQL output:\n") >> return mempty
            else report (LogDebug "-- compact CQL output:") >> return mempty
    }

