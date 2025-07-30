{-# LANGUAGE OverloadedStrings #-}
module Specs.ValidatorSpec (spec) where

import Test.Hspec

import Data.Default
import Data.Either
import Pangrm.Cli

spec :: Spec
spec = do
  it "fails if no input source is given." $ do
    let opt = Opt (JobSpec "cql" "nonexistent.ldif" "cql" Nothing) def def def
    result <- validateArgs opt
    result `shouldSatisfy` isLeft

  -- XXX to be done in next release
  --      - "../../../lib/tst/data/ill-formed/ill.ldif"
  --      - "../../../lib/tst/data/well-formed/invalid/empty.ldif"
  --it "fails if invalid input source is given." $ do
  --  let ops = Opt True "" Nothing
  --  result <- exec ops lix2neo
  --  result `shouldBe` (Left . PangrmError . pack $ "File '' not found.")

  it "fails if output path is a directory" $ do
    let inp = "../../../lib/tst/data/ldif/well-formed/valid/empty.ldif"
        out = Just "../"
        opt = Opt (JobSpec "cql" inp "cql" out) def def def

    result <- validateArgs opt
    result `shouldSatisfy` isLeft

  it "fails if output path is a file path but invalid" $ do
    let inp = "../../../lib/tst/data/ldif/well-formed/valid/empty.ldif"
        out = Just "/some/path/to-a-file.ldif"
        opt = Opt (JobSpec "cql" inp "cql" out) def def def
    result <- validateArgs opt
    result `shouldSatisfy` isLeft

  it "succeeds if everything is fine" $ do
    let inp = "../lib/tst/data/ldif/well-formed/valid/empty.ldif"
        out = Just "./tst/data/out/empty.cql"
        -- `QUIET` in test suite only; `INFO` is default
        opt = Opt (JobSpec "cql" inp "cql" out) def def def
    result <- validateArgs opt
    result `shouldSatisfy` isRight

