# Pangrm

> **Pangrm** /ˈpæn.ɡræm/ — The universal graph model converter
> Inspired by [Pandoc](https://github.com/jgm/pandoc), **Pangrm** lets you convert **graph-based models** across diverse formats — reliably, reproducibly, and type-safely.

## What is Pangrm?

**Pangrm** is a Haskell-based library and CLI tool for **converting graph models** from one format to another.

The name *Pangrm* stands for **Pan** (*universal*) + **GRM** (*GRAph Model*), reflecting its core purpose:

> *Universal graph model conversion.*[^tgy]

[^tgy]: Also cf. [Pangrm Terminology](./doc/tgy.md)

Just like [Pandoc](https://github.com/jgm/pandoc) provides universal document conversion, **Pangrm** aims to do the same for **graph-based modeling formats** — such as `.dot`, `.bpmn`, `.archimate`, and more.

## Why Pangrm?

- Modeling tools are fragmented.
- Formats are incompatible.
- Round-trip conversion is error-prone.

With **Pangrm – The universal graph model converter**, graph model processing is intended to become as seamless and versatile as [Pandoc](https://github.com/jgm/pandoc) made it for documents.

**Pangrm provides:**

- 🧩 **Modular architecture** — Easily plug in new formats (cf. [How to Add a New Pangrm Format](./doc/ext.md)
- ✅ **Type safety** — Every conversion step is typed and verifiable
- 🔁 **Roundtrip capability** — Parse → Unify → Render (back and forth)
- 📦 **CLI & Library** — Use it as a developer or in pipelines
- 🧪 **Comprehensive test suite** — Roundtrip fidelity and edge-case safety
- 🔗 **Inspired by Pandoc**[^thx] — Familiar concepts, stricter semantics

[^thx]: Pangrm owes significant conceptual inspiration to [Pandoc](https://github.com/jgm/pandoc), particularly its modular format architecture, reader/writer abstraction, and normalized intermediate representation. Sincere thanks to John MacFarlane and contributors for their foundational work.

## Supported Formats

Pangrm currently supports parsing and writing the following formats:

| Tag        | Format |
|------------|--------|
| `dot`      | The [GraphViz](https://graphviz.org/) file format |
| `cql`      | [Cypher](https://neo4j.com/docs/cypher-manual/current/introduction/), [Neo4j](https://neo4j.com/)'s declarative query language |
| `puml`     | The [PlantUML](https://plantuml.com/) file format |
| `mxg`      | The [MXGraph](https://jgraph.github.io/mxgraph/) file format |
| `amx`      | The [OpenGroup](https://www.opengroup.org/) [ArchiMate Model Exchange](https://www.opengroup.org/open-group-archimate-model-exchange-file-format) file format |
| `ldif`     | The [SAP LeanIX](https://www.leanix.net/en/) [LeanIX Data Interchange](https://docs-eam.leanix.net/reference/integration-api) file format |
| `bpmn`     | The [OMG](https://www.omg.org/) [Business Process Model and Notation](https://www.bpmn.org/) file format |
| `archimate`| The [ArchiMate Tool](https://www.archimatetool.com/) proprietary file format |

More formats can be added via a clean extension mechanism.

## How It Works

```text
       [Reader]      [Writer]

         Text         Text
          ↓            ↑
      [inject]      [render]
          ↓            ↑
      AST Format    AST Format
          ↓            ↑
       [unify]      [eject]
          ↓            ↑
      [Graph as unified IR]
```

Pangrm converts from **textual input** (→ **format-specific AST** → **unified graph IR** → **format-specific AST**) → **textual output**  ...and back again. Every supported format must implement both a `Reader` and a `Writer` interface. In other words, a Pangrm format must adhere to its defining property: it must be *normalizable* — i.e., both readable and writable.

## Installation

You'll need **GHC** and **Cabal**.

### Clone the Repository

```bash
git clone https://github.com/normenmueller/pangrm.git
cd ./pangrm
```

### Build & Install using `make` (recommended)

```bash
make
```

This will:

1. Clean old builds
2. Build the core lib (`pangrm`) and CLI (`pangrm-cli`)
3. Run tests
4. Install both via Cabal

### Manual Build (without Make)

```bash
cabal update
cabal clean
```

Then:

```bash
cd lib/
cabal build --enable-tests
cabal test
cabal install
cd ../cli/
cabal build --enable-tests
cabal test
cabal install
```

✅ Pangrm is now ready to use!

## Usage

Pangrm consists of two components:

- **[`pangrm-lib`](src/lib/README.md)** — the core graph modeling library
- **[`pangrm-cli`](src/cli/README.md)** — the CLI tool

Example:

```bash
pangrm --from ldif --to cql --input example.ldif --output example.cql
```

To see all options:

```bash
pangrm --help
```

## Contributing

We welcome contributions!

### Guidelines

- Follow idiomatic Haskell style
- Run `hlint` and `fourmolu`
- Write tests for new features
- Document public interfaces
- Prefer total functions and safe types

Before submitting:

```bash
cabal test --enable-tests
```

### Format Plugin Example

To add a new format:

1. Define your format
2. Implement your format specific `Reader` *and* `Writer`
3. Register your format in the Pangrm registry
4. Test your format normalization

See [extending Pangrm](doc/ext.md) for details.

## FAQ

> **Q:** Is Pangrm a GUI modeling tool?
>
> **A:** No. Pangrm is a backend tool. Think of it like Pandoc, but for graph models.

> **Q:** Can Pangrm handle lossy formats like images or SVG?
>
> **A:** No, Pangrm is about *structural conversion of graph models* — not visual layout fidelity.

> **Q:** How does Pangrm ensure roundtrip safety?
>
> **A**: By relying on the "*normalizable*" nature of Pangrm formats — each format is both readable and writable, enabling safe roundtrips.

## License

See [LICENSE](./LICENSE)
© 2025 [nemron](https://github.com/normenmueller)

Made with ❤️  in Haskell.

