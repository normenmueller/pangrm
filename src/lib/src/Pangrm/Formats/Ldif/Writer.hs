{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE OverloadedStrings #-}

-- |
-- Module      : Pangrm.Formats.Ldif.Writer
-- Description : Format-specific writer instance for LDIF.
module Pangrm.Formats.Ldif.Writer
  ( writer
  ) where

import Data.Proxy

import Pangrm.Core.Format
import Pangrm.Core.PangrmMonad
import Pangrm.Formats.Ldif.Format (LDIF(..), AST(..))

-- | A dummy LDIF writer for testing and integration purposes.
--
-- Converts a graph into a placeholder AST and renders it as an empty string.
-- This demonstrates writer integration and options wiring.
writer :: PangrmMonad m => Writer LDIF m
writer =
  Writer
    { wrtTag = tag @LDIF Proxy
    , wrtEject =
        \_g ->
          return
            $ LdifEntry
                { ldifEty = error "LDIF Writer eject dummy: please replace"
                , ldifEtyName = "dummy"
                , ldifEtyAttr = []
                , ldifEtyLine = 1
                , ldifEtyColumn = 1
                , ldifEtyOrigin = Nothing
                }
    , wrtRender = \_opts _ast -> return mempty
    }

