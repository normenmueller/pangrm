{-# LANGUAGE DeriveGeneric #-}

{-|
Module      : Pangrm.Core.Graph.Types
Description : Core graph data model for Pangrm.

Defines the universal internal graph model used by Pangrm to represent arbitrary
graph structures in a normalized, uniform way.

The design supports:
  * Multigraph semantics via 'RelInfo' grouping (multiple logical relations per edge)
  * Flexible, nested property model with 'Prp'
  * Clear distinction between Nodes ('Elm') and Edges ('Rel')
  * Seamless integration with 'fgl' graph algorithms

Example usage for a multi-relation edge:
@
let nodeA = Elm 1 "A" "Person" mempty
let nodeB = Elm 2 "B" "System" mempty

let mrel = Rel 1 2
  [ RelInfo 101 "manages" "owns" mempty
  , RelInfo 102 "uses"    "depends_on" mempty
  ]

let graph = insEdges [(1, 2, mrel)] $ insNodes [(1, nodeA), (2, nodeB)] empty
@
-}
module Pangrm.Core.Graph.Types
  ( Prp(..)
  , Elm(..)
  , RelInfo(..)
  , Rel(..)
  , Graph(..)
  ) where

import Data.Graph.Inductive.PatriciaTree (Gr)
import Data.Map.Strict (Map)
import Data.Scientific (Scientific)
import Data.Text (Text)
import GHC.Generics (Generic)

-- | Property values in the graph (supports nested structures)
data Prp
  = PrpString Text
  | PrpNumber Scientific
  | PrpBool Bool
  | PrpMap (Map Text Prp)
  deriving (Eq, Ord, Show, Generic)

-- | Graph node (element) — identified by Int (stable within graph)
data Elm = Elm
  { elmIdn :: Int -- ^ Unique element ID (graph-internal)
  , elmNme :: Text -- ^ Human-readable name
  , elmTyp :: Text -- ^ Semantic type (e.g. "Application", "Class")
  , elmPrp :: Map Text Prp -- ^ Attached properties
  } deriving (Eq, Show, Generic)

-- | Logical relation metadata (multiple per edge possible)
data RelInfo = RelInfo
  { relIdn :: Int -- ^ Unique relation ID (per relation)
  , relNme :: Text -- ^ Human-readable name
  , relTyp :: Text -- ^ Semantic type (e.g. "uses", "depends_on")
  , relPrp :: Map Text Prp -- ^ Relation properties
  }
  deriving (Eq, Ord, Show, Generic)

-- | Directed edge between two nodes — may group multiple logical relations
data Rel = Rel
  { relSrc :: Int -- ^ Source node ID (must match 'elmIdn')
  , relTgt :: Int -- ^ Target node ID (must match 'elmIdn')
  , relInfo :: [RelInfo] -- ^ All logical relations between source and target
  }
  deriving (Eq, Ord, Show)

-- | Pangrm Graph — wraps an fgl graph with Elm as node label, Rel as edge label
newtype Graph = Graph
  { unGraph :: Gr Elm Rel
  } deriving (Eq, Show, Generic)

