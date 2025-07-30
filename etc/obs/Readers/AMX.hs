{-# LANGUAGE OverloadedStrings #-}
module Pangrm.Readers.AMX
  ( readAMX
  ) where

-- The Open Group ArchiMate® Model Exchange File Format

import Control.Exception

import Data.Map (Map)
import qualified Data.Map as M

import Data.Text (Text)
import qualified Data.Text as T
import Data.Text.Lazy (fromStrict)

import Text.XML
import Text.XML.Cursor

import Data.Maybe (listToMaybe)

import Pangrm.Graph
import Pangrm.Graph.Types
import Pangrm.Graph.Utils

import Pangrm.Types

readAMX :: Text -> Either PangrmError Graph
readAMX src = do
  -- parse
  doc <-
    either
      (Left . PangrmError . T.pack . displayException)
      (Right . fromDocument)
      (parseText def (fromStrict src))
  -- filter
  ds <- decs doc
  es <- elms ds doc
  rs <- rels ds doc
  -- build
  mkGraph es rs

elms :: Map ID Dec -> Cursor -> Either PangrmError [Elm]
elms m c = traverse (elm m) (c $/ (element "elements" &/ element "element"))

elm :: Map ID Dec -> Cursor -> Either PangrmError Elm
elm m c = do
  i <- attr "identifier" c
  t <- attr "{http://www.w3.org/2001/XMLSchema-instance}type" c
  n <- cont "name" c
  d <- cont' "documentation" c
  p <- prps m c
  return $ Elm i n t d p

rels :: Map ID Dec -> Cursor -> Either PangrmError [Rel]
rels m c = traverse (rel m) (c $/ (element "relationships" &/ element "relationship"))

rel :: Map ID Dec -> Cursor -> Either PangrmError Rel
rel m c = do
  i <- attr "identifier" c
  s <- attr "source" c
  t <- attr "target" c
  y <- attr "{http://www.w3.org/2001/XMLSchema-instance}type" c
  n <- cont "name" c
  d <- cont' "documentation" c
  p <- prps m c
  return $ Rel i n y s t d p

prps :: Map ID Dec -> Cursor -> Either PangrmError [Prp]
prps m c = traverse (prp m) (c $/ (element "properties" &/ element "property"))

prp :: Map ID Dec -> Cursor -> Either PangrmError Prp
prp m c = do
  d <-
    attr "propertyDefinitionRef" c
      >>= lookup' m (\pid -> "Property '" <> pid <> "' not defined.")
  v <- cont "value" c
  return $ Prp (decIdn d) (decTyp d) v

decs :: Cursor -> Either PangrmError (Map ID Dec)
decs c = do
  d <-
    traverse
      dec
      (c $/ (element "propertyDefinitions" &/ element "propertyDefinition"))
  return $ M.fromList d

dec :: Cursor -> Either PangrmError (ID, Dec)
dec cur = do
  i <- attr "identifier" cur
  t <- attr "type" cur
  n <- cont "name" cur
  return (i, Dec n t)

attr :: Name -> Cursor -> Either PangrmError Text
attr n c =
  maybe
    (Left . PangrmError
       $ "'" <> (T.pack . show $ n) <> "' attribute ill-formed.")
    Right
    (listToMaybe . attribute n $ c)

cont :: Name -> Cursor -> Either PangrmError Text
cont n c =
  maybe
    (Left . PangrmError
       $ "'" <> (T.pack . show $ n) <> "' element ill-formed.")
    (Right . T.concat)
    (listToMaybe . fmap content $ c $/ element n)

cont' :: Name -> Cursor -> Either PangrmError Text
cont' n c = Right . T.concat . concatMap content $ c $/ element n
-- XXX let doc = T.unlines . fmap (T.concat . content) $ cur $/ element "documentation"


