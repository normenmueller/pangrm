{-# OPTIONS_GHC -Wno-orphans #-}

-- |
-- Module      : Pangrm.Formats.Cql
-- Description : Full format registration for CQL.
--
-- This module ties together the CQL format tag, AST, reader, and writer.
-- It exposes CQL as a full Pangrm format via the 'Normalizable' and
-- 'Roundtrippable' instances.
--
-- This is the central integration point used by the CLI and library.
-- It must be imported and registered in the Pangrm registry to be usable.
module Pangrm.Formats.Cql
  ( module Pangrm.Formats.Cql.Format
  , module Pangrm.Formats.Cql.Reader
  , module Pangrm.Formats.Cql.Writer
  ) where

import Pangrm.Core
import Pangrm.Formats.Cql.Format
import Pangrm.Formats.Cql.Reader
import Pangrm.Formats.Cql.Writer

{- Note for contributors:
   This is a controlled orphan instance. This module defines
   the glue between the CQL format and its operational parts.
   Do NOT define 'Normalizable' or 'Roundtrippable' elsewhere!
-}

-- | Registers CQL as a format with reader and writer.
instance Normalizable CQL where
  getReader = reader
  getWriter = writer

-- | Declares CQL as a complete roundtrippable Pangrm format.
instance Roundtrippable CQL

