---
title: Backlog
---

# General

- [ ] Unterschied (Graph) "Definition" und "Deklaration"
- [ ] Docs im GitHub Wiki?
- [ ] List formats
    - Cf. Pandoc: "You can also use `pandoc --list-input-formats` and `pandoc --list-output-formats` to print lists of supported formats
- [ ] Input file optional?
    - If no input-files are specified, input is read from stdin. Output goes to stdout by default. For output to a file, use the -o option:
- [ ] Warn on unknown parameter
    - Wenn weder der aktuelle Reader, noch der aktuelle Writer den Parameter (bspw. `--foo`) kennen, dann wird eine Warning ausgegeben. D.h. heißt aber nur, dass dieser Parameter in dieser Reader/Writer Kombination nicht bekannt ist. In einer anderen Kombination kann dieser durchaus gültig sein.
- [ ] Use case [armlet](https://github.com/normenmueller/armlet)
    -  Lässt sich die Funktionalität von `armlet` nun nicht mit `pangrm` abbilden?

    ```haskell
    pangrm -f amx -t amx -bindings=$author=Max,$version=v0.1 in.amx -o out.amx
    ```

    Das Gleiche gilt für `.archimate`.
- [ ] Integrate [errata](https://github.com/normenmueller/errata)
- [ ] Installation Guide for MS Windows
- [ ] Abschlussbericht
    - Be prepared in case of experiment fails, e.g., "*Dieses Repo wird nicht länger maintained! Es hat sich herausgestellt, dass Pangrm sich als nicht praktikabel herausstellt hat (siehe Abschlussbericht). Sollte jedoch jemand anderer Meinung sein feel free to open an issue and Let’s start a discussion… Ich freue mich über jeden Beitrag!*"

# v0.2 - feature/rdr-ldif

🚨 No writer! Just `Reader LDIF m`

- [ ] Re-assess [pamela](<../../../../../etc/pamela.md>)
- [ ] Add fix anchors to `adl.md`
    - ... and update `dsg.md`
- [ ] Improve according to GitHub Community Standards
    - [Community Standards · normenmueller/neoject](https://github.com/normenmueller/neoject/community)
- [ ] Analyse `Documents/XPN/BAK/pamela.bak`
    - Remove?
- [ ] Add BATS tests for CLI
- [ ] Inject LDIF
    - [ ] Setup spec
        - Wie schaut die maximale Struktur eines LDIF Exports aus?
        - Anders gefragt, wie schaut das (vollständige) LDIF Schema aus?
    - [ ] Set up tests
- [ ] Unify LDIF
    - [ ] Set up spec
    - [ ] Set up tests

# v0.3 - feature/wrt-cql

🚨 No reader! Just `Writer LDIF m`

- [ ] Create `feature/wrt-cql`
- [ ] Eject CQL
    - [ ] Set up spec
    - [ ] Set up tests
- [ ] Render CQL
    - [ ] Set up specs
        - TBX: Cypher format; Was ist besser geeignet? `movies1`, `movies2` oder `movies3`?
        - 🚨 In `neopop` we used the terminology `pure` or `impure` modular graph seeds. Is this relevant for `pangrm`
    - [ ] Set up tests
    