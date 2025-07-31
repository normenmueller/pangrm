---
title: Terminology
...

# Converter vs. Transformer

In software engineering, a *converter* typically refers to a component that transforms data from one type or format into another (e.g., DTO ↔ Entity), whereas a *transformer* often performs more complex adaptations or structural modifications, such as mappings involving logic or contextual interpretation (cf. Fowler, *Patterns of Enterprise Application Architecture*, 2002).

Pangrm is therefore best understood as a *converter*: Graph models are converted from one format into another. While the internal unification can be seen as a form of *transformation*, the primary goal remains format *conversion*.

<!--

In der Softwareentwicklung bezeichnet ein Converter typischerweise eine Komponente, die Daten von einem Typ oder Format in ein anderes überführt (z.B. DTO ↔ Entity), während ein Transformer oft komplexere Anpassungen oder strukturelle Änderungen an Daten vornimmt, etwa Mapping mit Logik oder Kontextbezug (vgl. Fowler, Patterns of Enterprise Application Architecture, 2002).

Pangrm lässt sich somit am besten als ein Konverter verstehen: Graphmodelle werden von einem Format in ein anderes überführt. Auch wenn die interne Vereinheitlichung eine Form von Transformation darstellt, bleibt das Ziel die Konvertierung zwischen Formaten.

-->

# Unify vs. Normalize

**Normalize**: The focus is on *standardization*. Heterogeneous input formats are flattened, redundant or unnecessary structures are removed, and the result is brought into a canonical form. The term primarily implies the alignment of formats, without necessarily establishing a shared semantic abstraction.

**Unify**: This term emphasizes the *integration of different concepts* into a common, abstract model. It goes beyond standardization, aiming to transform and map diverse structures onto a unified, semantically coherent model.

In the context of Pangrm, "unify" refers to the conversion of a specific, parser-dependent abstract syntax tree into a format-independent, unified Pangrm graph. The term "normalize" would be too narrow in this case, as it typically implies structural alignment rather than full semantic unification.

Note: If the input and output format are identical, the process can be considered a form of *normalization*.

<!--

**Normalize**: Der Fokus liegt auf Standardisierung. Heterogene Eingabeformate werden geglättet, redundante oder überflüssige Strukturen entfernt, und das Ergebnis in ein kanonisches Format überführt. Der Begriff impliziert vor allem das Angleichen von Formaten, jedoch ohne notwendigerweise eine gemeinsame semantische Abstraktion zu schaffen.

**Unify**: Hier steht das Zusammenführen unterschiedlicher Konzepte in ein gemeinsames, abstraktes Modell im Vordergrund. Es geht nicht nur um Standardisierung, sondern um die Transformation und Abbildung verschiedenartiger Strukturen auf ein einheitliches, semantisch kohärentes Modell.

Im Kontext von Pangrm bezeichnet "Unify" die Konvertierung eines spezifischen, parserabhängigen abstrakten Syntaxbaums in einen formatunabhängigen, einheitlichen Pangrm-Graphen. Der Begriff "Normalize" wäre hier zu eng gefasst, da er eher einfache Strukturangleichungen als umfassende semantische Vereinheitlichung impliziert.

Hinweis: Stimmen Eingabe- und Ausgabeformat überein, kann man in diesem Fall von einer *Normalisierung* sprechen.

-->
