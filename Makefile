.PHONY: all build clean test install

# All-in-one pipeline
all: clean build test install

## Clean
clean:
  @echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>"
  @echo ">>>"
  @echo ">>> CLEAN"
  @echo ">>>"
  @echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>"
  cabal clean
  (cd src/lib && cabal clean)
  (cd src/cli && cabal clean)
  find . -name "dist-newstyle" -type d -exec rm -rf {} +

## Build
build:
  @echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>"
  @echo ">>>"
  @echo ">>> BUILD LIB"
  @echo ">>>"
  @echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>"
  (cd src/lib && cabal build --enable-tests)
  @echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>"
  @echo ">>>"
  @echo ">>> BUILD CLI"
  @echo ">>>"
  @echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>"
  (cd src/cli && cabal build exe:panmod --enable-tests)

## Run Tests
test:
  @echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>"
  @echo ">>>"
  @echo ">>> TEST LIB"
  @echo ">>>"
  @echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>"
  (cd src/lib && cabal test)
  @echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>"
  @echo ">>>"
  @echo ">>> TEST CLI"
  @echo ">>>"
  @echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>"
  (cd src/cli && cabal test)

## Install
install:
  @echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>"
  @echo ">>>"
  @echo ">>> INSTALL CLI"
  @echo ">>>"
  @echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>"
  (cd src/cli && cabal install exe:panmod --overwrite-policy=always)

