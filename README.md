# Analyse des globalen Marktplatzes ShopSphere

ShopSphere ist ein Lernprojekt zur Analyse von E-Commerce-Daten aus den Jahren 2022–2024. Das Projekt umfasst den gesamten Analyseprozess – von Rohdaten im CSV-Format und SQL-Abfragen bis hin zu einem Tableau-Dashboard, geschäftlichen Erkenntnissen und der statistischen Auswertung eines A/B-Tests.

## Daten:

* **Quelle:** ShopSphere-Übungsdatensätze: `customers`, `products`, `orders`, `order_items` und `marketing`.
* **Umfang:** 3.000 Kunden, 250 Produkte, 12.274 Bestellungen, 26.068 Bestellpositionen und 216 Marketingkampagnen.
* **Analysezeitraum:** 2022–2024.
* **Marktabdeckung:** Sieben Produktkategorien und fünf Weltregionen.

## Ziel:

Das Ziel des Projekts ist es, die wichtigsten Fragen des CEO zu beantworten:

* Welche Marketingkanäle sind kurz- und langfristig am effektivsten?
* Welche Produktkategorien verbinden Umsatz mit hoher Marge?
* Welche Kundengruppen leisten den größten Umsatzbeitrag?
* Welche Regionen besitzen das höchste Wachstumspotenzial?
* Für welche Nutzergruppe sollte der neue Checkout eingeführt werden?

## Verwendete Tools und Arbeitsschritte:

* **SQLiteOnline:** Datenverknüpfung mit JOINs, Aggregationen, Unterabfragen und Common Table Expressions.
* **Excel / CSV:** Prüfung, Aufbereitung und Export von Zwischenergebnissen.
* **Tableau Public:** Erstellung interaktiver Visualisierungen und zweier Management-Dashboards.
* **Python:** Segmentierte Auswertung des A/B-Tests und Berechnung zentraler Vergleichskennzahlen.

Der Analyseprozess folgte der Struktur:

**Datenaufbereitung → explorative Analyse → Visualisierung → statistische Auswertung → Managementempfehlungen**

## Dashboard:

**Link zu Tableau Public:**  
[Zum interaktiven Tableau-Dashboard](https://public.tableau.com/views/final_project_17840384652670/Geschftsberblick?:language=en-US&publish=yes&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)


Die Tableau-Lösung besteht aus zwei thematisch getrennten Bereichen:

* **Geschäftsüberblick:** KPI, Umsatzsaisonalität, regionale Entwicklung und Kundenbeitrag.
* **Marketing & Wachstum:** Marketingeffizienz, Kunden-LTV und Rentabilität der Produktkategorien.

Die Filter nach **Region** und **Jahr** ermöglichen eine gezielte Analyse der wichtigsten Geschäftsentwicklungen.

**Ausführlicher Projektbericht:** [report.md](report.md)

## Kurze Zusammenfassung für den CEO:

| KPI | Ergebnis |
| :--- | ---: |
| Nettoumsatz | **3.474.016,03 USD** |
| Bestellungen | **12.274** |
| Durchschnittlicher Bestellwert | **283,04 USD** |
| Retourenquote | **9,77 %** |
| Umsatzanteil der Top 5 % | **35,07 %** |

* **Wachstum und Saisonalität:** Der höchste Monatsumsatz wurde im Dezember 2024 mit **759.390 USD** erreicht. Das vierte Quartal ist für Umsatz, Lagerbestand und Logistik besonders relevant.

* **Marketingeffizienz:** Organic erzielt mit **802%** den höchsten ROI, während Paid Search trotz eines Budgets von rund **450.959 USD** nur einen ROI von **133%** und den niedrigsten beobachteten Kunden-LTV aufweist.

* **Produktkategorien:** Electronics generiert mit rund **2,10 Mio. USD** den höchsten Umsatz, erreicht jedoch nur **12 % Marge** und eine Retourenquote von **15,97 %**. Beauty besitzt mit **55 %** die höchste Marge und bietet attraktives Wachstumspotenzial.

* **Regionale Entwicklung:** North America erzielt 2024 mit rund **718.727 USD** den höchsten Umsatz. Southeast Asia zeigt jedoch die stärkste Dynamik und ist seit 2022 um mehr als das **48-Fache** gewachsen.

* **Kundenwert:** Die Top 5 % der Kunden generieren **35,07 %** des Gesamtumsatzes. Zusätzlich erwirtschaften 862 Kunden mit überdurchschnittlichen Ausgaben insgesamt **72,68 %** des Umsatzes.

* **A/B-Test:** Checkout B erhöht den durchschnittlichen Bestellwert insgesamt um etwa **2,0 %**. Der stärkste Effekt zeigt sich bei Neukunden mit **+19,2 %**, während der Unterschied bei Bestandskunden mit **+0,9 %** gering bleibt. Ein gezielter Rollout für Neukunden sollte deshalb vor einer vollständigen Einführung weiter geprüft werden.

> **Zentrale Erkenntnis:** Nachhaltiges Wachstum entsteht nicht allein durch höheren Umsatz, sondern durch die gemeinsame Steuerung von Marge, Retouren, ROI, Kunden-LTV und Kundenbindung.
