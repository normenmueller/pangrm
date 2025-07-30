{-|
Module      : Pangrm.Core
Description : The internal framework foundation of Pangrm.

This module defines the core concepts, contracts, and types for all Pangrm
plugins.

It provides the foundational type classes, state management, and shared types
that form the backbone of the Pangrm ecosystem.

**Note:** This module is intended for Pangrm plugin authors.
-}
module Pangrm.Core
  ( module Pangrm.Core.Graph
  , module Pangrm.Core.Format
  , module Pangrm.Core.PangrmMonad
  , module Pangrm.Core.PangrmState
  ) where

import Pangrm.Core.Graph
import Pangrm.Core.Format
import Pangrm.Core.PangrmMonad
import Pangrm.Core.PangrmState

