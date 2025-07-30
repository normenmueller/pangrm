# Missing `from`/`to`

````sh
cabal run pangrm -- in
cabal run pangrm -- ../lib/tst/data/ldif/well-formed/valid/empty.ldif
cabal run pangrm -- --to cql ../lib/tst/data/ldif/well-formed/valid/empty.ldif

cabal run pangrm -- --from ldif ../lib/tst/data/ldif/well-formed/valid/empty.ldif
````

# Unknown `from`/`to`

````sh
cabal run pangrm -- --from ldiF --to cql ../lib/tst/data/ldif/well-formed/valid/empty.ldif
cabal run pangrm -- --from ldif --to cqL ../lib/tst/data/ldif/well-formed/valid/empty.ldif
````

# Input does not exist

````sh
cabal run pangrm -- --from ldif --to cql ../lib/tst/data/ldif/well-formed/valid/emptyX.ldif
````

# Output invalid

````sh
cabal run pangrm -- --from ldif --to cql ../lib/tst/data/ldif/well-formed/valid/empty.ldif -o .
cabal run pangrm -- --from ldif --to cql ../lib/tst/data/ldif/well-formed/valid/empty.ldif -o ./noexist/out.cql
````

# Valid

````sh
cabal run pangrm --           --from ldif --to cql ../lib/tst/data/ldif/well-formed/valid/empty.ldif -o ./tst/data/out/out.cql
cabal run pangrm -- --verbose --from ldif --to cql ../lib/tst/data/ldif/well-formed/valid/empty.ldif -o ./tst/data/out/out.cql
cabal run pangrm -- --debug --from ldif --to cql ../lib/tst/data/ldif/well-formed/valid/empty.ldif -o ./tst/data/out/out.cql
cabal run pangrm -- --quiet --from ldif --to cql ../lib/tst/data/ldif/well-formed/valid/empty.ldif -o ./tst/data/out/out.cql
````

