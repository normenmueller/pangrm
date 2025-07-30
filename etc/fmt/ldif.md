# JSON-LDIF Schema

````json
{
  "factSheets": [
    {
      "id": "string",
      "type": "string",
      "data": {
        "name": "string",
        "description": "string",
        "customFields": {
          "fieldName": "value"
        },
        "relations": [
          {
            "type": "string",
            "targetID": "string",
            "comment": "string",
            "fields": {
              "fieldName": "value"
            }
          }
        ],
        "tags": ["string"],
        "subscriptions": [
          {
            "type": "string",
            "user": "string"
          }
        ]
      }
    }
  ]
}
````

(siehe [SAP Help – LDIF Import/Export](https://help.sap.com/docs/leanix/ea/integration-api?locale=en-US))

Erklärung der Hauptbestandteile:

| Feld | Typ | Bedeutung |
| ---- | --- | --------- |
| `factSheets` | Array | Liste aller Fact Sheets |
| `id` | String | Interne UUID |
| `type` | String | Fact Sheet Typ (Application, ITComponent usw.) |
| `data` | Object | Enthält Name, Beschreibung, Custom Fields, Relationen usw. |
| `relations` | Array | Ziel-Relationen mit Typ, Target-ID, optionalen Feldern |
| `customFields` | Object | Key-Value-Paare der Custom Fields |
| `tags` | Array | Zugeordnete Tags |
| `subscriptions` | Array | User- und Rollen-Zuordnung |

Meta-Daten und Data Model

Das LDIF-JSON enthält nur Instanzdaten! Das Datenmodell (Feldtypen,
Relationstypen) muss zusätzlich via GraphQL API (allFactSheetTypes) abgerufen
werden.

⸻

Quelle:

https://help.sap.com/docs/leanix/ea/integration-api
Abschnitt: “LDIF Data Format”

# Sind draw.io-Grafiken im LDIF enthalten?

**Nein**. Das LDIF-Format (LeanIX Data Interchange Format) enthält keine Informationen zu Visualisierungen oder Diagrammen, die z. B. über draw.io (diagrams.net) in LeanIX erstellt wurden.

Begründung: LDIF dient ausschließlich dem strukturierten Austausch von Fact Sheets, Relationen und Metadaten. Visualisierungen wie "Diagrams" (früher: "Architecture Diagrams") werden separat verwaltet und sind nicht Teil der Faktendatenstruktur, sondern UI-Komponenten.

Quelle: [LeanIX Docs – Data Import Format](https://docs-ea.leanix.net/docs/data-import-format), bestätigt durch [LeanIX Support Knowledge Base](https://intercom.help/leanix/en/articles/4891174-diagrams-in-leanix).

