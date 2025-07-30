# pangrm cli

`pangrm-cli` is the command-line interface for the [Pangrm](../README.md) framework. It provides easy access to graph model conversions.

## Usage

```sh
> pangrm --help
```

## Developer Notes

To test manually on the commandline:

```shell
> cabal run pangrm -- --verbose ../lib/tst/data/well-formed/valid/empty.ldif
> cabal run pangrm -- --verbose --from ldif --to cql ../lib/tst/data/ldif/well-formed/valid/empty.ldif -o ./tst/data/out/out.cql

```

## License

See [LICENSE](./LICENSE) for details. © 2025 nemron
