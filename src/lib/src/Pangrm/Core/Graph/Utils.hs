{-|
Module      : Pangrm.Core.Graph.Utils
Description : Low-level utilities for building and manipulating Pangrm Graphs.

This module provides thin wrappers around `fgl` graph operations
with Pangrm's unified node and edge types ('Elm' and 'Rel').

Recommended for:
  * Programmatic graph construction
  * Controlled multi-relation edge handling
  * Integration with `fgl` algorithms

For higher-level optics and UUID-based manipulation, see
'Pangrm.Core.Graph.Optics'.
-}
module Pangrm.Core.Graph.Utils
  ( empty
  , singleton
  , addNode
  , addEdge
  , addRelInfo
  ) where

import qualified Data.Graph.Inductive as G
import Data.List (find)

import Pangrm.Core.Graph.Types

-- | An empty Pangrm Graph (no nodes, no edges).
empty :: Graph
empty = Graph G.empty

-- | Create a graph with a single node and no edges.
singleton :: Int -> Elm -> Graph
singleton nid e = Graph $ G.insNode (nid, e) G.empty

-- | Add a node with a given Int node ID to the graph.
addNode :: Int -> Elm -> Graph -> Graph
addNode nid e (Graph g) = Graph $ G.insNode (nid, e) g

-- | Add an edge with a given Int node ID pair and a relation.
addEdge :: Int -> Int -> Rel -> Graph -> Graph
addEdge src tgt rel (Graph g) = Graph $ G.insEdge (src, tgt, rel) g

-- | Add or extend a multi-relation edge between two nodes.
--
-- - If an edge exists between @from@ and @to@: extend its relation list.
-- - If not: insert a new edge with this single 'RelInfo'.
--
-- This operation is pure and side-effect-free: the original graph is not
-- modified, and no duplicates are removed from the relation list.
--
-- @TODO@ Warning: No duplicate protection — identical 'RelInfo' entries are not
-- checked or merged.
addRelInfo :: Int -> Int -> RelInfo -> Graph -> Graph
addRelInfo src tgt info (Graph g) =
  case findEdge (G.labEdges g) (src, tgt) of
    Nothing -> Graph $ G.insEdge (src, tgt, Rel src tgt [info]) g
    Just _ -> Graph $ G.emap (extendRel src tgt info) g

-- | Extend a relation's info list if it matches @from@ and @to@.
--
-- @TODO@ Warning: No duplicate protection — identical 'RelInfo' entries are not
-- checked or merged.
extendRel :: Int -> Int -> RelInfo -> Rel -> Rel
extendRel src tgt info rel
  | relSrc rel == src && relTgt rel == tgt = rel {relInfo = info : relInfo rel}
  | otherwise = rel

-- | Find an edge by (from,to) node IDs.
findEdge :: [G.LEdge Rel] -> (Int, Int) -> Maybe (G.LEdge Rel)
findEdge es (f, t) = find (\(f', t', _) -> f' == f && t' == t) es

