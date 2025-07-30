{-# OPTIONS_GHC -Wno-orphans #-}

-- |
-- Module      : Pangrm.Formats.Ldif
-- Description : Full format registration for LDIF.
--
-- This module ties together the LDIF format tag, AST, reader, and writer.
-- It exposes LDIF as a complete Pangrm format via the 'Normalizable' and
-- 'Roundtrippable' instances.
--
-- This is the central integration point used by the CLI and library.
-- It must be imported and registered in the Pangrm registry to be usable.
module Pangrm.Formats.Ldif
  ( module Pangrm.Formats.Ldif.Format
  , module Pangrm.Formats.Ldif.Reader
  , module Pangrm.Formats.Ldif.Writer
  ) where

import Pangrm.Core
import Pangrm.Formats.Ldif.Format
import Pangrm.Formats.Ldif.Reader
import Pangrm.Formats.Ldif.Writer

{- Note for contributors:
   This is a controlled orphan instance. This module defines
   the glue between the LDIF format and its operational parts.
   Do NOT define 'Normalizable' or 'Roundtrippable' elsewhere!
-}

-- | Registers LDIF as a format with reader and writer.
instance Normalizable LDIF where
  getReader = reader
  getWriter = writer

-- | Declares LDIF as a complete roundtrippable Pangrm format.
instance Roundtrippable LDIF

