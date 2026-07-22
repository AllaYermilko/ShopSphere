
# Finalprojekt: ShopSphere: Analyse eines globalen Marktplatzes

## Angaben zum Autor
* **Studierende:** Alla Yermilko
* **Präsentationsdatum:** 29.07.2026

## Projektziel
Das Ziel dieses Abschlussprojekts ist es, einen vollständigen Analysezyklus für den globalen Marktplatz ShopSphere durchzuführen. Die Analyse umfasst die Datenaufbereitung in SQL, die Erstellung von Visualisierungen und Dashboards in Tableau, die Formulierung von Geschäftserkenntnissen sowie die Auswertung eines A/B-Tests.

Das Projekt beantwortet fünf Kernfragen: Wie entwickeln sich die Umsätze? Wie effizient wird das Marketingbudget eingesetzt? Welche Kategorien und Kunden generieren den größten Mehrwert? Wie hängen Rabatte und kostenloser Versand mit dem Kundenverhalten zusammen? Lohnt sich die Einführung eines neuen Checkout-Prozesses?

## Ausgangsdaten

| Tabelle | Granularität | Hauptzweck |
| :--- | :--- | :--- |
| **customers** | 1 Zeile = 1 Kunde | Region, Land, Alter, Geschlecht, Akquisitionskanal, Registrierungsdatum |
| **products** | 1 Zeile = 1 Produkt | Kategorie, Preis, Selbstkosten, Produktmarge |
| **orders** | 1 Zeile = 1 Bestellung | Datum, Kunde, Gerät, Kanal, Rabatt, Nettobetrag, Versand, A/B-Variante, Rückgabe |
| **order_items**| 1 Zeile = 1 Bestellposition | Produkt, Kategorie, Menge, Preis und Betrag der Position |
| **marketing** | 1 Zeile = Kanal × Monat | Budget, Impressionen, Klicks, Conversions und zugeschriebener Umsatz |

Der Analysezeitraum umfasst die Jahre 2022 bis 2024. Die Haupttabelle **orders** enthält 12.274 Bestellungen. Die Tabelle **customers** umfasst 3.000 Kunden, **products** enthält 250 Produkte, **order_items** zählt rund 26.000 Bestellpositionen und **marketing** beinhaltet 216 aggregierte Datensätze.

## Methodik und Einschränkungen

* **Datenmodell:** Für die Umsatzanalyse wird die logische Verknüpfung *customers → orders → order_items → products* verwendet. Die Tabelle *marketing* wird aufgrund eines anderen Detaillierungsgrades (Granularität) separat analysiert.
* **Marketing ROI:** Die Kennzahl wird als `attributed_revenue / budget` berechnet. Sie spiegelt den Werbeumsatz pro eingesetztem Euro (oder Dollar) wider, berücksichtigt jedoch nicht die vollständigen Selbstkosten und stellt somit keinen Netto-ROI dar.
* **LTV (Lifetime Value):** In diesem Projekt wird der tatsächlich beobachtete, kumulierte Umsatz eines Kunden im verfügbaren Zeitraum herangezogen und nicht der prognostizierte Lifetime Value.
* **Kausalität:** Der Vergleich von Rabatten und kostenlosem Versand zeigt Korrelationen in den Daten auf, beweist jedoch keine kausalen Effekte.
* **A/B-Test:** Es liegen Daten zu den Bestellungen vor, jedoch fehlen die Daten zu allen Checkout-Sitzungen (Sessions). Daher kann der durchschnittliche Bestellwert (Warenkorb) der Käufer ermittelt werden, nicht aber die vollständige Conversion-Rate zum Kauf.

### 1.1. Gesamtnettoumsatz, Anzahl der Bestellungen und durchschnittlicher Bestellwert nach Region und Jahr

* **Ziel:** Vergleich von Umfang und Dynamik der Umsätze in fünf Regionen über den Zeitraum 2022–2024.
* **Ergebnis:** Diese Abfrage bildet die Grundlage für das regionale Diagramm und ermöglicht die gleichzeitige Analyse von Umsatz, Bestellvolumen und durchschnittlichem Bestellwert.

### 1.2. Top-10-Kunden nach Gesamtausgaben

* **Ziel:** Identifikation der wertvollsten Kunden, ihrer Region, ihres Akquisitionskanals und der Anzahl ihrer Bestellungen.
* **Ergebnis:** Diese Abfrage bildet die Basis für eine personalisierte Analyse der VIP-Kunden und für die zukünftige Entwicklung von Kundenbindungsprogrammen.

### 1.3. Umsatz, durchschnittliche Marge und Rückgabequote nach Kategorien

* **Ziel:** Vergleich der Produktkategorien nicht nur nach Umsatzvolumen, sondern auch nach der Qualität der Erträge.
* **Ergebnis:** Retonierte Bestellungen werden mittels `COUNT(DISTINCT CASE...)` berechnet. Dadurch wird verhindert, dass eine einzelne Bestellung aufgrund mehrerer Bestellpositionen mehrfach gezählt wird.

### 1.4. Kunden mit überdurchschnittlichen Gesamtausgaben

* **Ziel:** Ermittlung der Anzahl der Kunden mit überdurchschnittlichen Ausgaben sowie ihres Anteils am Gesamtumsatz.
* **Ergebnis:** Diese Abfrage bewertet die Umsatzkonzentration auf Kundenebene und ergänzt die Pareto-Analyse.

### 1.5. Marketingbudget, zugeschriebener Umsatz und ROAS

* **Ziel:** Vergleich der Marketingkanäle nach Investitionsvolumen und Rentabilität (Return).
* **Ergebnis:** Der Kanal *Organic* weist mit 8,02 den höchsten ROAS auf, während *Paid Search* mit 1,33 den niedrigsten ROAS bei gleichzeitig größtem Budget verzeichnet.


## Block 2. Visualisierungen in Tableau

Jede nachfolgende Visualisierung entspricht einem separaten Aufgabenpunkt. Die begleitenden Texte sind einheitlich strukturiert: Inhalt der Darstellung, Kernergebnisse, analytische Schlussfolgerung und geschäftliche Relevanz.

### 2.1. Saisonalität: Nettoumsatz nach Monaten



* **Inhalt der Darstellung:** Ein Liniendiagramm zeigt den monatlichen Nettoumsatz von Anfang 2022 bis Ende 2024. Die Höchstwerte im Dezember sind durch separate Annotationen hervorgehoben.
* **Kernergebnisse:** Der Umsatz im Dezember stieg von 72.908 USD im Jahr 2022 auf 206.421 USD im Jahr 2023 und erreichte 759.390 USD im Jahr 2024. Die Zeitreihe weist einen deutlich steigenden Gesamttrend auf, wobei das beste Ergebnis auf den Dezember 2024 fällt.
* **Analytische Schlussfolgerung:** Die Daten zeigen wiederkehrende Spitzenwerte im Dezember. Gleichzeitig lässt sich das Wachstum dieser Spitzenwerte teilweise durch die schnelle Skalierung des Unternehmens erklären. Daher muss die Saisonalität zusammen mit dem Gesamttrend bewertet werden und nicht nur anhand der absoluten Zahlen.
* **Geschäftliche Relevanz:** Das Unternehmen muss Lagerbestände, Marketingkampagnen und operative Ressourcen frühzeitig auf das vierte Quartal (Q4) vorbereiten. Zur Bestätigung eines stabilen saisonalen Musters ist es ratsam, Daten über weitere Beobachtungsjahre hinweg zu sammeln.

### 2.2. Marketing: Budget vs. Effizienz



* **Inhalt der Darstellung:** Ein Streudiagramm (Scatter Plot) vergleicht das Gesamtbudget auf der X-Achse mit dem ROAS auf der Y-Achse. Die Punktgröße zeigt den zugeschriebenen Umsatz.

| Kanal | Budget, USD | Zugeschriebener Umsatz, USD | ROAS |
| :--- | :---: | :---: | :---: |
| **Organic** | 20.364 | 163.398 | 8,02 |
| **Email** | 37.468 | 243.610 | 6,50 |
| **Influencer** | 112.337 | 519.453 | 4,62 |
| **Referral** | 73.766 | 263.536 | 3,57 |
| **Social Ads** | 286.488 | 589.544 | 2,06 |
| **Paid Search**| 450.959 | 598.703 | 1,33 |

* **Kernergebnisse:** *Organic* und *Email* haben den höchsten ROAS bei den kleinsten Budgets. *Paid Search* erhält 45,95 % des Gesamtbudgets, hat aber den niedrigsten ROAS. Auch *Social Ads* verbindet ein großes Budget mit einem relativ geringen Ertrag.
* **Analytische Schlussfolgerung:** Die aktuelle Budgetverteilung ist nicht optimal. Die höchsten Budgets fließen in Kanäle mit niedrigem ROAS, während sehr effiziente Kanäle nur wenig Geld bekommen.
* **Geschäftliche Relevanz:** Wir sollten das Budget schrittweise testen und optimieren, anstatt *Paid Search* sofort abzuschalten. Es ist wichtig zu prüfen, wie effizient *Organic*, *Email*, *Influencer* und *Referral* bleiben, wenn wir dort das Budget erhöhen.

### 2.3. Kategorien: Umsatzvolumen vs. Rentabilität



* **Inhalt der Darstellung:** Die X-Achse zeigt den Umsatz der Kategorie, die Y-Achse die durchschnittliche Produktmarge. Die Punktgröße stellt die Rückgabequote dar.
* **Kernergebnisse:** *Electronics* generiert 2.097.901,06 USD Umsatz, hat aber nur 12 % Marge und die höchste Rückgabequote von rund 15,97 %. *Beauty* bringt 168.624,42 USD Umsatz, hat aber die höchste Marge von 55 % und eine geringere Rückgabequote von rund 9,97 %. *Toys* kombiniert ebenfalls eine hohe Marge von 40 % mit relativ wenigen Rückgaben.
* **Analytische Schlussfolgerung:** *Electronics* bringt den meisten Umsatz, ist aber nicht die profitabelste Kategorie. *Beauty* ist der beste Kandidat für weiteres Wachstum.
* **Geschäftliche Relevanz:** Bei *Electronics* müssen wir die schlechten Produkte und die Gründe für Rückgaben analysieren. Bei *Beauty* sollten wir das Sortiment erweitern und mehr Werbung machen, um den Gewinn zu steigern.

### 2.4. Regionen in der Dynamik



* **Inhalt der Darstellung:** Ein Liniendiagramm mit mehreren Linien vergleicht den Nettoumsatz von fünf Regionen über die Jahre hinweg.
* **Kernergebnisse:** Im Jahr 2024 hat *North America* mit 718,73 Tsd. USD den größten Umsatz. *Southeast Asia* erreicht 613,90 Tsd. USD, *Europe* 545,63 Tsd. USD, *Latin America* 321,39 Tsd. USD und *Middle East* 281,07 Tsd. USD. Der Umsatz in *Southeast Asia* ist im Vergleich zu 2022 um das 48-Fache gestiegen.
* **Analytische Schlussfolgerung:** *Southeast Asia* ist die am schnellsten wachsende Region. Ein Teil dieses Effekts liegt jedoch an der sehr niedrigen Basis im Startjahr. *Europe* wächst weiter, aber langsamer als die neuen Märkte.
* **Geschäftliche Relevanz:** *North America* bleibt der wichtigste Markt beim Gesamtvolumen. *Southeast Asia* braucht jetzt eine genaue Analyse des Marktpotenzials, der operativen Risiken und der Chancen für eine weitere Expansion.

### 2.5. Kundenbeitrag: Pareto-Analyse



* **Inhalt der Darstellung:** Die Balken zeigen den Umsatz von aufeinanderfolgenden 5-Prozent-Kundengruppen, und die Linie zeigt den kumulierten Anteil am Gesamtumsatz.
* **Kernergebnisse:** Die Top 5 % der Kunden (150 Personen) bringen 1.218.211,48 USD ein. Das entspricht 35,07 % des gesamten Nettoumsatzes. Die restlichen 95 % der Kunden generieren 64,93 %.
* **Analytische Schlussfolgerung:** Die klassische 80/20-Regel bestätigt sich hier nicht. Der Umsatz ist gleichmäßiger verteilt. Dennoch ist die Konzentration von über einem Drittel des Umsatzes bei nur 5 % der Kunden strategisch sehr wichtig.
* **Geschäftliche Relevanz:** Dieses Top-Segment benötigt ein eigenes Kundenbindungsprogramm, eine Überwachung der Kundenaktivität und eine personalisierte Kommunikation.


## Block 3. Dashboard für den CEO

* **Inhalt der Darstellung:** Das Dashboard kombiniert vier KPI-Karten mit vier zentralen Visualisierungen. Die KPIs zeigen einen Nettoumsatz von 3,47 Mio. USD, 12.274 Bestellungen, einen durchschnittlichen Bestellwert von 283,04 USD und eine Rückgabequote von 9,77 %. Darunter befinden sich die Saisonalität, die regionale Dynamik, die Pareto-Analyse und das Scatter-Plot der Kategorien.


Das Dashboard ist logisch aufgebaut – vom allgemeinen Zustand des Geschäfts bis hin zu den Quellen und der Qualität der Ergebnisse.

1. **KPI-Karten:** Zuerst sieht der Manager die Größe des Geschäfts und vier Kennzahlen: Umsatz, Bestellungen, durchschnittlichen Bestellwert und Rückgaben.
2. **Saisonalität und Regionen:** Danach beantwortet das Dashboard die Fragen, wann und wo das Wachstum entsteht. Das ist die Makroebene des Geschäfts.
3. **Pareto und Kategorien:** Die untere Ebene erklärt, wer den Umsatz generiert und wie gut das Produktportfolio ist.
4. **Fazit für das Management:** Der Aufbau führt vom Ergebnis zu den Ursachen: Gesamtgröße → Dynamik → Geografie → Kundenkonzentration → Qualität der Kategorien.

### Strategische Insights

1. Das Geschäft wächst schnell, aber die Rückgabequote liegt bereits bei 9,77 %. Das Wachstum muss daher immer zusammen mit der Qualität der Erträge bewertet werden.
2. *Southeast Asia* ist der wichtigste neue Wachstumstreiber, während *North America* der größte Markt bleibt. Die Strategie sollte den Schutz des bestehenden Volumens mit einer gezielten Expansion verbinden.
3. Die größte Produktkategorie ist nicht die profitabelste, und die Top 5 % der Kunden bringen 35,07 % des Umsatzes. Entscheidungen über das Sortiment und die Kundenbindung haben eine höhere Priorität als eine einfache Umsatzsteigerung.
