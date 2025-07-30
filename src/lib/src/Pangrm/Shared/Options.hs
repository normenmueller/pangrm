{-# LANGUAGE TemplateHaskell #-}

{-|
Module      : Pangrm.Shared.Options
Description : Format-specific reader and writer options.
-}
module Pangrm.Shared.Options
  ( RdrOpts(RdrOpts)
  , roStrict, roStripComments
  , WrtOpts(WrtOpts)
  , woPrettify, woBindings, woPrefixes
  ) where

import Data.Default
import Data.Text
import Optics.TH (makeLenses)
import qualified Data.Map.Strict as Map

type Var = Text
type Val = Text
type Label = Text

-- | Reader options for parsing formats.
data RdrOpts = RdrOpts
  { _roStrict :: Bool
    -- ^ If 'True', fail on non-conforming input.
  , _roStripComments :: Bool
    -- ^ If 'True', remove comments during parsing.
  } deriving (Eq, Show)

makeLenses ''RdrOpts

instance Default RdrOpts where
  def = RdrOpts
    { _roStrict = False
    , _roStripComments = True
    }

-- | Writer options for rendering formats.
data WrtOpts = WrtOpts
  { _woPrettify :: Bool
    -- ^ If 'True', format output in a human-readable way.
  , _woBindings :: Map.Map Var Val
    -- ^ Optional variable bindings (for template substitution).
  , _woPrefixes :: Map.Map Label Text
    -- ^ Prefix mappings (e.g., for CURIEs).
  } deriving (Eq, Show)

makeLenses ''WrtOpts

instance Default WrtOpts where
  def = WrtOpts
    { _woPrettify = False
    , _woBindings = Map.empty
    , _woPrefixes = Map.empty
    }

