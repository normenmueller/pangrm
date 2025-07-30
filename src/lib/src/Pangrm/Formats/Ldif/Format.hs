{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE DeriveTraversable #-}
{-# LANGUAGE OverloadedStrings #-}

-- |
-- Module      : Pangrm.Formats.Ldif.Format
-- Description : Pangrm tag, AST, and format-specific options for LDIF.
--
-- This module dePangrm
--
--   * The LDIF tag type (used for type-level dispatch)
--   * The LDIF AST structure
--   * Format-specific reader and writer options via the 'HasOpt' instance
--
-- The AST is currently a minimal placeholder and will be replaced with a
-- complete representation in future versions.
module Pangrm.Formats.Ldif.Format
  ( LDIF(..)
  , AST(..)
  ) where

import Data.Text

import Pangrm.Core.Format

-- | Tag type for the LDIF format.
data LDIF = LDIF

instance HasTag LDIF where
  tag _ = "ldif"

instance HasAST LDIF where
  -- | AST type for LDIF
  --
  -- *Note*: This is a minimal placeholder AST for LDIF — to be replaced with a
  -- full model later.
  --
  data AST LDIF a = LdifEntry
    { ldifEty :: a
    , ldifEtyName :: Text
    , ldifEtyAttr :: [Text]
    , ldifEtyLine :: Int
    , ldifEtyColumn :: Int
    , ldifEtyOrigin :: Maybe FilePath
  } deriving (Functor, Foldable, Traversable)

  getPosition ast = Position (ldifEtyLine ast, ldifEtyColumn ast)

  getOrigin = ldifEtyOrigin

