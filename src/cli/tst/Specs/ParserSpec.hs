module Specs.ParserSpec (spec) where

import Test.Hspec

spec :: Spec
spec = do
  it "fails if no input is given." $ do
    -- XXX fix me (how to test `Parser`?)
    --let ops = Opt QUIET "/some/path/to-a-file.ldif" Nothing
    pending

