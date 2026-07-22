
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
   

## Block 4. Strategische Business-Cases

### Frage 3: Welcher Kanal bringt das meiste Geld pro investiertem Dollar?

Der Kanal *Organic* hat mit 8,02 den höchsten ROAS. Das bedeutet 8,02 USD Umsatz pro 1 USD Marketingkosten. Auf dem zweiten Platz liegt *Email* mit einem ROAS von 6,50. Den niedrigsten Wert hat *Paid Search* mit 1,33. Gleichzeitig erhält *Paid Search* mit 450.959 USD rund 45,95 % des gesamten Budgets.

Das bedeutet: Der größte Teil des Budgets fließt in den Kanal mit der geringsten relativen Effizienz. Allerdings generiert *Paid Search* mit 598.703 USD den höchsten absoluten Umsatz. Daher sollte man diesen Kanal nicht einfach als „schlecht“ bewerten. Es ist wichtig, seine Grenzeffizienz und die tatsächliche Rentabilität nach Abzug der Produktmarge zu prüfen.

### Frage 4: Stimmen die ROAS-Ergebnisse mit dem langfristigen Kundenwert (LTV) überein?

Die Rankings stimmen nicht überein. *Organic* und *Email* sind führend beim ROAS, aber *Influencer* und *Referral* haben den höchsten durchschnittlichen LTV – 1.985,73 USD und 1.791,82 USD. *Organic* hat einen LTV von 1.316,13 USD, *Email* von 1.074,46 USD, *Social Ads* von 822,09 USD und *Paid Search* von 648,10 USD.

*Organic* bietet die beste Balance zwischen kurzfristiger Effizienz und langfristigem Wert. *Influencer* und *Referral* bringen wertvollere Kunden, obwohl ihr ROAS niedriger ist. *Paid Search* schneidet bei beiden relativen Kennzahlen am schlechtesten ab.

### Frage 5: Wie soll das Budget neu verteilt werden? Welche Risiken hat diese Empfehlung?

Der empfohlene erste Schritt ist ein kontrollierter Pilot-Test. Dabei werden 15–20 % des *Paid Search*-Budgets (ca. 67,6–90,2 Tsd. USD) abgezogen. Dieses Geld soll in mehreren Testwellen auf *Email*, *Influencer*, *Referral* und *Organic* verteilt werden.

1. **Organic und Email:** Das Budget schrittweise erhöhen und prüfen, ob der ROAS bei Skalierung hoch bleibt.
2. **Influencer und Referral:** In die Qualität der Partner und in Empfehlungsmechanismen investieren, da diese Kanäle Kunden mit dem höchsten LTV bringen.
3. **Paid Search:** Nicht den gesamten Kanal abschalten, sondern nur schwache Kampagnen, Keywords, Zielgruppen und Regionen reduzieren.
4. **Kontrolle:** Neben dem ROAS auch den inkrementellen Umsatz, CPA, die Wiederkaufsrate, Rückgaben und den Bruttogewinn bewerten.

*   **Sättigungsrisiko:** Effiziente Kanäle können ihren hohen ROAS verlieren, wenn das Budget zu schnell steigt.
*   **Attributionsrisiko:** Der zugeschriebene Umsatz spiegelt möglicherweise nicht den realen inkrementellen Beitrag des Kanals wider.
*   **Kohorten-Altersrisiko:** Kunden aus verschiedenen Kanälen hatten möglicherweise unterschiedlich viel Zeit, um ihren LTV aufzubauen.
*   **Kapazitätsrisiko:** *Influencer* und *Referral* haben möglicherweise ein begrenztes Skalierungspotenzial.

### Case B: Welche Kategorien schaffen wirklich Wert?

#### Frage 6: Welche Kategorie erzeugt die „Illusion von Volumen“?

*Electronics* erzielt mit 2.097.901,06 USD den größten Umsatz, hat aber nur eine Produktmarge von 12 % und die höchste Rückgabequote von rund 15,97 %. Diese Kategorie ist wichtig für die Skalierung, aber ein hoher Umsatz bedeutet nicht automatisch einen hohen Gewinn.

Die richtige Entscheidung ist es, *Electronics* nicht automatisch zu reduzieren, sondern eine Analyse auf SKU-Ebene (Produktebene) durchzuführen. Wir müssen Produkte mit niedriger Marge, hoher Rückgabequote und großen Logistikkosten identifizieren. Für eine Management-Entscheidung wird die Kennzahl des Bruttogewinns nach Rückgaben benötigt.

#### Frage 7: Gibt es einen „versteckten Diamanten“ unter den Kategorien?

*Beauty* ist der offensichtlichste „versteckte Diamant“. Die Kategorie hat einen Umsatz von 168.624,42 USD, die höchste Produktmarge von 55 % und eine geringere Rückgabequote von rund 9,97 %. *Toys* hat ebenfalls eine gute Kombination aus Marge und Rückgaben, aber ein geringeres Verkaufsvolumen.

Die Kategorie *Beauty* sollte durch ein kontrolliertes Experiment skaliert werden: Das Sortiment erweitern, separate Kampagnen starten, Cross-Selling testen und den Bruttogewinn, die Rückgaben sowie die Kannibalisierung anderer Kategorien überwachen. Das Ziel ist es, das Volumen zu erhöhen, ohne die Wirtschaftlichkeit der Kategorie zu verschlechtern.

### Case C: Rabatte und wertvolle Kunden

#### Frage 8: Bilden hohe Rabatte eine langfristige Kundenloyalität?

Im Diagramm zeigen sich 11.691 Bestellungen von Stammkunden (regulären Kunden) und 583 Bestellungen von rabattorientierten Kunden. Da die absoluten Zahlen jedoch teilweise von der unterschiedlichen Größe der Segmente abhängen, sollte die durchschnittliche Kaufhäufigkeit pro Kunde die Hauptkennzahl sein.

Bei den normalisierten Daten tätigen Kunden mit einem durchschnittlichen Rabatt von über 20 % nur 2,17 Bestellungen, verglichen mit 4,35 Bestellungen bei den restlichen Kunden. Ihr durchschnittlicher LTV ist ebenfalls deutlich niedriger. Die verfügbaren Daten bestätigen also nicht, dass tiefe Rabatte eine langfristige Loyalität aufbauen.

Dieses Ergebnis beweist keine Kausalität. Für eine genauere Bewertung müssen das Registrierungsdatum, die Kategorie, die Region, der Akquisitionskanal und der Beobachtungszeitraum kontrolliert werden.

### Case C: Rabatte und wertvolle Kunden

#### Frage 8: Bilden hohe Rabatte eine langfristige Kundenloyalität?

Im Diagramm zeigen sich 11.691 Bestellungen von Stammkunden (regulären Kunden) und 583 Bestellungen von rabattorientierten Kunden. Da die absoluten Zahlen jedoch teilweise von der unterschiedlichen Größe der Segmente abhängen, sollte die durchschnittliche Kaufhäufigkeit pro Kunde die Hauptkennzahl sein.

Bei den normalisierten Daten tätigen Kunden mit einem durchschnittlichen Rabatt von über 20 % nur 2,17 Bestellungen, verglichen mit 4,35 Bestellungen bei den restlichen Kunden. Ihr durchschnittlicher LTV ist ebenfalls deutlich niedriger. Die verfügbaren Daten bestätigen also nicht, dass tiefe Rabatte eine langfristige Loyalität aufbauen.

Dieses Ergebnis beweist keine Kausalität. Für eine genauere Bewertung müssen das Registrierungsdatum, die Kategorie, die Region, der Akquisitionskanal und der Beobachtungszeitraum kontrolliert werden.

#### Frage 9: Welchen Anteil am Umsatz bringen die Top-5-%-Kunden? Wer sind diese Personen und wie kann man sie binden?

Die Top-5-%-Kunden generieren 35,07 % des gesamten Nettoumsatzes. Die stärkste Kombination ist *Europe × Influencer*: Hier bringen 12 Kunden rund 125,9 Tsd. USD ein. Weitere starke Gruppen konzentrieren sich auf *Southeast Asia* und *North America* und kommen häufig über die Kanäle *Influencer*, *Organic* und *Referral*.

1. **VIP-Service:** Priorisierter Support, früher Zugang zu neuen Produkten und persönliche Empfehlungen.
2. **Churn-Monitoring:** Automatisches Signal im CRM-System, wenn ein Kunde sein typisches Kaufintervall überschreitet.
3. **Personalisierung:** Angebote auf Basis der Kategorie-Historie und der tatsächlichen Produktmarge statt universeller Rabatte.
4. **Feedback-Schleifen:** Separate Analyse der Rückgabegründe und der Kundenzufriedenheit unter den Top-Kunden.
5. **Kostenkontrolle der Privilegien:** Kostenloser Versand, Geschenke und Boni müssen anhand der Deckungsbeitragsmarge (Contribution Margin) bewertet werden.
