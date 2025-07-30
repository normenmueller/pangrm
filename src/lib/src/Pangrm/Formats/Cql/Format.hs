{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveTraversable #-}
{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}

-- |
-- Module      : Pangrm.Formats.Cql.Format
-- Description : Pangrm tag, AST, and format-specific options for CQL.
--
-- This module dePangrm
--
--   * The CQL tag type (used for type-level dispatch)
--   * The CQL AST structure
module Pangrm.Formats.Cql.Format
  ( CQL(..)
  , AST(..)
  ) where

import Data.Text

import Pangrm.Core.Format

-- | Tag type for the CQL format.
data CQL = CQL

instance HasTag CQL where
  tag _ = "cql"

instance HasAST CQL where
  -- | AST type for CQL
  --
  -- *Note*: This is a minimal placeholder AST for CQL — to be replaced with a
  -- full model later.
  --
  data AST CQL a = CqlEntry
    { cqlEty :: a
    , cqlEtyName :: Text
    , cqlEtyAttr :: [Text]
    , cqlEtyLine :: Int
    , cqlEtyColumn :: Int
    , cqlEtyOrigin :: Maybe FilePath
  } deriving (Functor, Foldable, Traversable)

  getPosition ast = Position (cqlEtyLine ast, cqlEtyColumn ast)

  getOrigin = cqlEtyOrigin

