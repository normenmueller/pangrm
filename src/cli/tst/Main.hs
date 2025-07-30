module Main (main) where

import Test.Hspec

import qualified Specs.ParserSpec as CliParser
import qualified Specs.ValidatorSpec as CliValidator

main :: IO ()
main = hspec $ do
  describe "CLI Tests" $ do
    describe "Command Line Interface" $ do
      CliParser.spec
      CliValidator.spec

