# Analyse `archimate3_Model.xsd`

## 1️⃣  Modell-Top-Level-Struktur

Das ArchiMate-Modell wird durch das Hauptelement `<model>` definiert. Dieses enthält:

- `<elements>`: Container für Modellelemente
- `<relationships>`: Container für Beziehungen
- `<propertyDefinitions>`: Definition von zusätzlichen Eigenschaften
- Weitere Elemente wie `<organizations>` oder `<metadata>`, die für
  Strukturierungen und Metainformationen genutzt werden können.

## 2️⃣  `<elements>` - Modellelemente

### 📍 **Definition:**

`<elements>` ist ein Container für alle ArchiMate-Elemente im Modell.

- [~] Test `<elements>` absent, present and multi-present

### 📍 **Schema:**

```xml
<xs:element name="elements" type="ElementsType" minOccurs="0" maxOccurs="1">
    <xs:annotation>
        <xs:documentation>
            Der "elements"-Container enthält alle ArchiMate-Elemente des Modells.
        </xs:documentation>
    </xs:annotation>
</xs:element>
```

### 📍 **Kindelemente von `<elements>`:**

- `<element>` (1..n): Definiert ein ArchiMate-Element, basiert auf ElementType
(abstrakte Basisklasse).

- [ ] Test `<element>` absent, present and multi-present

### 📍 **Kindelemente von `<element>` (rekursiv):**

- `@identifier` _(erforderlich)_ – Eine eindeutige ID für das Element.
- `<name>` _(1..n)_ – Bezeichnung des Elements (Mehrsprachigkeit möglich).
- `<documentation>` _(0..n)_ – Optionale Dokumentation.
- `<properties>` _(0..1)_ – Enthält spezifische Eigenschaften (siehe unten).

- [ ] Test `@identifier` absent, present and multi-present
- [ ] Test `<name>` absent, present and multi-present; multi-language
- [ ] Test `<documentation>` absent, present and multi-present
- [ ] Test `<documentation>` with multi-line text
- [ ] Test `<properties>` absent, present and multi-present

### 📍 **Erlaubte Werte für `<element>` (`xsi:type` Attribute)**

Elemente müssen den `xsi:type`-Attributwert setzen, um den Typ festzulegen.

Die erlaubten Werte sind:

- **Geschäftsebene**: BusinessActor, BusinessRole, BusinessObject, etc.
- **Anwendungsebene**: ApplicationComponent, ApplicationInterface, etc.
- **Technologieebene**: Node, Device, SystemSoftware, etc.
- **Sonstige**: Grouping, Location, AndJunction, OrJunction

- [ ] Doc `@xsi:type`; *alle* validen Werte aus ArchiMate 3 Spec auflisten
- [ ] Test `@xsi:type` absent, present and multi-present; valid and invalid values

## 3️⃣  `<relationships>` - Beziehungen zwischen Elementen

### 📍 **Definition:**

`<relationships>` ist ein Container für ArchiMate-Beziehungen zwischen `<element>`-Objekten.

- [ ] Test `<relationships>` absent, present and multi-present

### 📍 **Schema:**

```xml
<xs:element name="relationships" type="RelationshipsType" minOccurs="0" maxOccurs="1">
    <xs:annotation>
        <xs:documentation>
            Container für alle Beziehungen zwischen Modellelementen.
        </xs:documentation>
    </xs:annotation>
</xs:element>
```

### 📍 **Kindelemente von `<relationships>`:**

- `<relationship>` _(1..n)_ – Eine Beziehung zwischen zwei Elementen, basiert auf RelationshipType.

- [ ] Test `<relationship>` absent, present and multi-present

### 📍 **Kindelemente von `<relationship>` (rekursiv):**

- `@identifier` _(erforderlich)_ – Eine eindeutige ID für die Beziehung.
- `@source` _(erforderlich)_ – Referenz (IDREF) auf das Quell-Element.
- `@target` _(erforderlich)_ – Referenz (IDREF) auf das Ziel-Element.
- `<name>` _(0..n)_ – Bezeichnung der Beziehung.
- `<documentation>` _(0..n)_ – Optionale Dokumentation.
- `<properties>` _(0..1)_ – Enthält spezifische Eigenschaften (siehe unten).

- [ ] Test `@identifier` absent, present and multi-present
- [ ] Test `@source` absent, present and multi-present; valid and invalid values
- [ ] Test `@target` absent, present and multi-present; valid and invalid values
- [ ] Test `<name>` absent, present and multi-present
- [ ] Test `<documentation>` absent, present and multi-present
- [ ] Test `<documentation>` with multi-line text
- [ ] Test `<properties>` absent, present and multi-present

### 📍 **Erlaubte Werte für `<relationship>` (`xsi:type` Attribute)**

Beziehungen müssen ebenfalls durch xsi:type spezifiziert werden:

- **Hierarchische Beziehungen**: Composition, Aggregation
- **Abhängigkeiten**: Assignment, Realization
- **Dynamische Beziehungen**: Triggering, Flow
- **Strukturbezogene Beziehungen**: Association, Specialization, Influence

- [ ] Doc `@xsi:type`; *alle* validen Werte aus ArchiMate 3 Spec auflisten
- [ ] Test `@xsi:type` absent, present and multi-present; valid and invalid values

## 4️⃣  `<propertyDefinitions>` - Zusätzliche Eigenschaften für Elemente und Beziehungen

### 📍 **Definition:**

`<propertyDefinitions>` definiert mögliche Eigenschaften, die `<elements>` und `<relationships>` haben können.

- [ ] Test `<propertyDefinitions>` absent, present and multi-present

### 📍 **Schema:**

```xml
<xs:element name="propertyDefinitions" type="PropertyDefinitionsType" minOccurs="0" maxOccurs="1">
    <xs:annotation>
        <xs:documentation>
            Container für Property-Definitionen.
        </xs:documentation>
    </xs:annotation>
</xs:element>
```

### 📍 **Kindelemente von `<propertyDefinitions>`:**

- `<propertyDefinition>` _(1..n)_ – Definiert eine Property mit Namen und Typ.

### 📍 **Kindelemente von `<propertyDefinition>` (rekursiv):**

- `@identifier` _(erforderlich)_ – Eindeutige ID für die Property-Definition.
- `<name>` _(1..n)_ – Name der Property (z. B. “Status”, “Version”).
- `@type` _(erforderlich)_ – Datentyp (muss aus DataType Enum stammen).

### 📍 **Erlaubte Werte für `@type`**

- string
- boolean
- currency
- date
- time
- number

- [ ] Doc `@type`; *alle* validen Werte aus XSD auflisten
- [ ] Test `@type` absent, present and multi-present; valid and invalid values

### 📍 **Eigenschaftszuweisungen (`<properties>` und `<property>`)**

Jedes `<element>` oder `<relationship>` kann `<properties>` enthalten, die sich auf `<propertyDefinitions>` beziehen.

```xml
<properties>
    <property propertyDefinitionRef="prop1">
        <value>Active</value>
    </property>
</properties>
```

### 📍 **Kindelemente von `<properties>`:**

- `<property>` _(1..n)_ – Eine spezifische Eigenschaft des Elements.

- [ ] Test `<property>` absent, present and multi-present

### 📍 **Kindelemente von `<property>` (rekursiv):**

- `@propertyDefinitionRef` _(erforderlich)_ – Verweis auf `<propertyDefinition>` (ID).
- `<value>` _(1..n)_ – Eigenschaftswert. (Mehrsprachigkeit möglich)

- [ ] Test `@propertyDefinitionRef` absent, present and multi-present; valid and invalid values
- [ ] Test `<value>` absent, present and multi-present; multi-language

# Reader

## Sind wir in Pangrm.Readers.AMX vollständig?

### 🔹 **Haben wir alle zentralen Modellelemente (`<element>`) berücksichtigt?**

🟡 Ja, aber wir müssen sicherstellen, dass alle `xsi:type`-Werte verarbeitet werden.

### 🔹 **Haben wir alle Beziehungen (`<relationship>`) berücksichtigt?**

🟡 Ja, aber wir müssen prüfen, ob source und target korrekt verknüpft werden.

### 🔹 **Haben wir alle Property-Definitionen (`<propertyDefinitions>`) berücksichtigt?**

🟡 **Teilweise!** Wir müssen sicherstellen, dass @type richtig verarbeitet wird.

🔹 **Sind wir rekursiv genug (`<name>`, `<documentation>`, `<properties>` …)?**

🟡 **Zum Teil!** Wir müssen sicherstellen, dass `<documentation>` und `<properties>` vollständig extrahiert werden.

🔹 **Haben wir Mehrsprachigkeit berücksichtigt (`xml:lang` Attribute)?**

❌ Nein!

## Nächste Schritte in Pangrm.Readers.AMX

Siehe die "inline" TODOs 😉

**🚀 Damit haben wir eine präzise Roadmap zur Optimierung von `Pangrm.Readers.AMX`!**
