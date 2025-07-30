{-# LANGUAGE RankNTypes #-}

{-|
Module      : Pangrm.Core.Graph.Optics
Description : High-level optics and accessors for Pangrm Graph elements.

Provides lenses, traversals, and prisms for convenient access to
'Elm', 'Rel', and 'RelInfo' structures in Pangrm graphs.

Includes graph-level traversals for:
  * All nodes
  * All edges
  * All relations on edges

See also:
  * 'Pangrm.Core.Graph.Utils' — for low-level construction helpers
-}
module Pangrm.Core.Graph.Optics
  ( -- * Lenses for Elm
    elmIdnL
  , elmNmeL
  , elmTypL
  , elmPrpL
  , -- * Lenses for Rel
    relSrcL
  , relTgtL
  , relInfoL
  , -- * Lenses for RelInfo
    relIdnL
  , relNmeL
  , relTypL
  , relPrpL
  , -- * Graph Traversals
    allNodes
  , allEdges
  , allRelations
  ) where

import qualified Data.Graph.Inductive as G
import Data.Map.Strict
import Data.Text
import Lens.Micro

import Pangrm.Core.Graph.Types

-- * Elm Lenses

-- | Accessor for element ID.
elmIdnL :: Lens' Elm Int
elmIdnL f e = fmap (\x -> e {elmIdn = x}) (f (elmIdn e))

-- | Lens for element name.
elmNmeL :: Lens' Elm Text
elmNmeL f e = fmap (\x -> e {elmNme = x}) (f (elmNme e))

-- | Lens for element type.
elmTypL :: Lens' Elm Text
elmTypL f e = fmap (\x -> e {elmTyp = x}) (f (elmTyp e))

-- | Lens for element properties.
elmPrpL :: Lens' Elm (Map Text Prp)
elmPrpL f e = fmap (\x -> e {elmPrp = x}) (f (elmPrp e))

-- * RelInfo Lenses

-- | Lens for relation ID.
relIdnL :: Lens' RelInfo Int
relIdnL f r = fmap (\x -> r {relIdn = x}) (f (relIdn r))

-- | Lens for relation name.
relNmeL :: Lens' RelInfo Text
relNmeL f r = fmap (\x -> r {relNme = x}) (f (relNme r))

-- | Lens for relation type.
relTypL :: Lens' RelInfo Text
relTypL f r = fmap (\x -> r {relTyp = x}) (f (relTyp r))

-- | Lens for relation properties.
relPrpL :: Lens' RelInfo (Map Text Prp)
relPrpL f r = fmap (\x -> r {relPrp = x}) (f (relPrp r))

-- * Rel Lenses

-- | Lens for edge source node ID.
relSrcL :: Lens' Rel Int
relSrcL f r = fmap (\x -> r {relSrc = x}) (f (relSrc r))

-- | Lens for edge target node ID.
relTgtL :: Lens' Rel Int
relTgtL f r = fmap (\x -> r {relTgt = x}) (f (relTgt r))

-- | Lens for list of logical relations grouped on an edge.
relInfoL :: Lens' Rel [RelInfo]
relInfoL f r = fmap (\x -> r {relInfo = x}) (f (relInfo r))

-- * Graph Traversals

-- | Traverse all nodes of a 'Graph'
--
-- Note: This traversal rebuilds the graph using 'mkGraph' after applying
-- updates. This is idiomatic and safe, but may be inefficient for very large
-- graphs.
allNodes :: Traversal' Graph (Int, Elm)
allNodes f (Graph g) =
  fmap
    (\nodes' -> Graph $ G.mkGraph nodes' (G.labEdges g))
    (traverse f (G.labNodes g))

-- | Traverse all edges of a 'Graph'
--
-- Note: This traversal rebuilds the graph using 'mkGraph' after applying
-- updates. For large graphs or performance-critical code, specialized update
-- strategies may be more efficient.
allEdges :: Traversal' Graph (Int, Int, Rel)
allEdges f (Graph g) =
  fmap (Graph . G.mkGraph (G.labNodes g)) (traverse f (G.labEdges g))

-- | Traverses every logical relation (RelInfo) nested in all edges.
--
-- Note: This does not expose (src, tgt) context.
allRelations :: Traversal' Graph RelInfo
allRelations = allEdges . _3 . relInfoL . traverse

