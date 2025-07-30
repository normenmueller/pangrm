{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE OverloadedStrings #-}

-- |
-- Module      : Pangrm.Formats.Ldif.Reader
-- Description : Format-specific reader instance for LDIF.
--
-- This module defines the LDIF 'Reader', which parses input text into an
-- LDIF-specific AST and unifies it into a generic Pangrm 'Graph'.
--
-- This stub implementation is intended for integration and testing purposes
-- only — it does not perform real LDIF parsing.
--
-- The reader demonstrates how to pass and evaluate format-specific options such
-- as strict mode or comment skipping.
module Pangrm.Formats.Ldif.Reader
  ( reader
  ) where

import Data.Proxy
import Optics

import qualified Pangrm.Core.Graph as G

import Pangrm.Core
import Pangrm.Shared

import Pangrm.Formats.Ldif.Format

-- | A dummy LDIF reader for testing and integration purposes.
--
-- Parses input into a placeholder AST depending on the given reader options.
-- Demonstrates how format-specific options can influence parsing behavior.
reader :: PangrmMonad m => Reader LDIF m
reader =
  Reader
    { rdrTag = tag @LDIF Proxy
    , rdrInject =
        \opts _txt ->
          let dummy =
                if opts ^. roStrict
                  then "strict-dummy"
                  else "lenient-dummy"
           in return
                $ LdifEntry
                    { ldifEty = error "LDIF Reader inject dummy: please replace"
                    , ldifEtyName = dummy
                    , ldifEtyAttr = []
                    , ldifEtyLine = 1
                    , ldifEtyColumn = 1
                    , ldifEtyOrigin = Nothing
                    }
    , rdrUnify = \_ast -> return G.empty
    }

