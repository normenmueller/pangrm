module Main (main) where

import Test.Hspec

import qualified Specs.GraphSpec as Graph

main :: IO ()
main = hspec $ do
  describe "Graph Tests" Graph.spec

-- @TODO@
-- Test: no duplicate tags
--
-- @
-- prop_allEntriesHaveUniqueTags :: Bool
-- prop_allEntriesHaveUniqueTags =
--   let ts = map (\(Entry tagF _ _) -> tagF Proxy) entries
--   in length ts == length (nub ts)
-- @
