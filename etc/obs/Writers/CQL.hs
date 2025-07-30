module Pangrm.Writers.CQL
  ( writeCQL
  ) where

import Data.Text

import Pangrm.Graph
import Pangrm.Types

writeCQL :: Graph -> Either PangrmError Text
writeCQL _ = Right . pack $ "MATCH (n) RETURN n"

