
# Finalprojekt: ShopSphere: Analyse eines globalen Marktplatzes

## Angaben zum Autor
* **Studierende:** Alla Yermilko
* **Präsentationsdatum:** 29.07.2026
  
## Einleitung
ShopSphere ist ein globaler Online-Marktplatz, der Produkte aus sieben Kategorien in fünf Weltregionen vertreibt. Für die Analyse wurden Daten zu 3.000 Kundinnen und Kunden, 250 Produkten, rund 12.300 Bestellungen, etwa 26.000 Bestellpositionen und 216 Marketingkampagnen aus den Jahren 2022–2024 verwendet.

## Projektziel
Ziel des Projekts ist es, die finanzielle Entwicklung des Unternehmens, die Effizienz der Marketingkanäle, die Rentabilität der Produktkategorien, die regionale Entwicklung, den Kundenwert sowie die Ergebnisse eines A/B-Tests des neuen Checkouts zu untersuchen. Die Analyse verbindet SQL, Tableau, betriebswirtschaftliche Interpretation und statistisches Denken.



## Block 1. SQL: Datenaufbereitung
### 1.1. Berechnen Sie den Nettoumsatz, die Anzahl der Bestellungen und den durchschnittlichen Bestellwert nach Region und Jahr

```sql
SELECT
    c.region,
    o.order_year,
    ROUND(SUM(o.net_amount), 2) AS total_net_revenue,
    COUNT(o.order_id) AS orders_count,
    ROUND(AVG(o.net_amount), 2) AS avg_order_value
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.region, o.order_year
ORDER BY o.order_year, total_net_revenue DESC;
```
Die Abfrage verknüpft `orders` und `customers` über den Schlüssel `customer_id` und erstellt anschließend eine Auswertung nach Region und Jahr. Das Ergebnis dient dem Vergleich von Umsatz, Bestellanzahl und durchschnittlichem Bestellwert zwischen den Regionen und Zeiträumen.


### 1.2. Ermitteln Sie die zehn umsatzstärksten Kundinnen und Kunden

```sql
SELECT
    c.customer_id,
    c.region,
    c.acquisition_chan,
    COUNT(o.order_id) AS orders_count,
    ROUND(SUM(o.net_amount), 2) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY 
    c.customer_id,
    c.region,
    c.acquisition_chan
ORDER BY total_spent DESC
LIMIT 10;
```
Die Abfrage ordnet die Kundinnen und Kunden nach ihren kumulierten Nettoausgaben und ergänzt Region, Akquisitionskanal und Bestellanzahl. Dadurch lässt sich das Profil der wertvollsten Kundengruppe bestimmen.


### 1.3. Berechnen Sie für jede Kategorie Umsatz, durchschnittliche Marge und Retourenquote

```sql
SELECT
    p.category,
    ROUND(SUM(oi.line_total), 2) AS total_revenue,
    ROUND(AVG(p.margin_pct), 2) AS avg_margin_pct,
    ROUND(100.0 * SUM(o.is_returned) / COUNT(DISTINCT o.order_id), 2) AS return_rate_pct
FROM order_items oi
JOIN products p 
    ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
GROUP BY p.category
ORDER BY total_revenue DESC;
```
Die separate Bildung eindeutiger Paare aus Kategorie und Bestellung verhindert, dass eine Retoure mehrfach gezählt wird, wenn eine Bestellung mehrere Positionen derselben Kategorie enthält.


### 1.4. Ermitteln Sie Kundinnen und Kunden mit überdurchschnittlichen Ausgaben und deren Umsatzanteil
```sql
WITH customer_spending AS (
    SELECT
        customer_id,
        SUM(net_amount) AS total_spent
    FROM orders
    GROUP BY customer_id
),

avg_spending AS (
    SELECT
        AVG(total_spent) AS avg_total_spent
    FROM customer_spending
),

above_avg_customers AS (
    SELECT
        cs.customer_id,
        cs.total_spent
    FROM customer_spending cs
    CROSS JOIN avg_spending av
    WHERE cs.total_spent > av.avg_total_spent
)

SELECT
    COUNT(*) AS customers_above_average,
    ROUND(SUM(total_spent), 2) AS revenue_from_above_avg_customers,
    ROUND(
        100.0 * SUM(total_spent) / 
        (SELECT SUM(net_amount) FROM orders),
        2
    ) AS revenue_share_pct
FROM above_avg_customers;
```
Zunächst werden die Gesamtausgaben pro Kunde berechnet. Anschließend wird der durchschnittliche Kundenwert bestimmt und die Gruppe mit überdurchschnittlichen Ausgaben abgegrenzt.


### 1.5. Berechnen Sie Budget, zugerechneten Umsatz und ROI je Marketingkanal

```sql
SELECT
    channel,
    ROUND(SUM(budget), 2) AS total_budget,
    ROUND(SUM(attributed_reven), 2) AS total_attributed_revenue,
    ROUND(SUM(attributed_reven) / NULLIF(SUM(budget), 0), 2) AS roi
FROM marketing
GROUP BY channel
ORDER BY roi DESC;
```
Der ROI wird als Verhältnis des zugerechneten Umsatzes zum Marketingbudget definiert. Damit können die Kanäle nicht nur nach Ausgabenvolumen, sondern auch nach ihrer finanziellen Effizienz verglichen werden.


## Block 2. Visualisierungen in Tableau
### 2.1. Saisonalität: Visualisieren Sie den monatlichen Umsatz. Gibt es saisonale Spitzen und wann erzielt das Unternehmen den höchsten Umsatz?

![Umsatzsaisonalität](Tableau/2.1.Umsatzsaisonalität.png)

Das Liniendiagramm zeigt den monatlichen Nettoumsatz von 2022 bis 2024. Die Gesamtentwicklung ist steigend, jedoch nicht gleichmäßig: Neben dem kontinuierlichen Wachstum treten deutliche Spitzen am Ende jedes Jahres auf. Der höchste Wert des gesamten Zeitraums wurde im Dezember 2024 mit 759.390 USD erreicht.
Der Dezemberumsatz stieg von 72.908 USD im Jahr 2022 auf 206.421 USD im Jahr 2023 und schließlich auf 759.390 USD im Jahr 2024. Dies belegt sowohl einen saisonalen Effekt als auch eine deutliche Skalierung des Geschäfts. Die Visualisierung zeigt ein beschleunigtes Wachstum und zunehmend starke Dezember-Spitzen; ohne ein separates mathematisches Modell sollte der Verlauf jedoch nicht formal als exponentiell bezeichnet werden.
Betriebswirtschaftliche Schlussfolgerung: Das vierte Quartal und insbesondere der Dezember sind für den Jahresumsatz von zentraler Bedeutung. Bestände, Logistikkapazitäten, Kundenservice und Marketingmaßnahmen müssen frühzeitig geplant werden. Gleichzeitig entsteht durch die Abhängigkeit von einem einzelnen Spitzenmonat ein Risiko, weshalb Maßnahmen zur Stabilisierung der Nachfrage in schwächeren Monaten erforderlich sind.


### 2.2. Marketing: Vergleichen Sie die Kanäle nach Budget und ROI. Ist das Budget rational verteilt?



Das Streudiagramm stellt das gesamte Marketingbudget auf der X-Achse dem ROI auf der Y-Achse gegenüber. Die höchste kurzfristige Effizienz erzielen Organic mit 802 % und Email mit 650 %. Es folgen Influencer mit 462 % und Referral mit 357 %. Die niedrigsten Werte weisen Social Ads mit 206 % und Paid Search mit 133 % auf.
Paid Search erhält mit rund 451 Tsd. USD das größte Budget, erzielt jedoch den niedrigsten ROI. Social Ads verfügt ebenfalls über ein hohes Budget von etwa 286 Tsd. USD und erreicht nur den zweitniedrigsten Effizienzwert. Die größten Budgets sind somit nicht mit der höchsten finanziellen Rendite verbunden.
Betriebswirtschaftliche Schlussfolgerung: Die Budgetstruktur sollte schrittweise überprüft werden. Paid Search und Social Ads sind die wichtigsten Bereiche für eine detaillierte Analyse von Kampagnen, Zielgruppen und Keywords. Ein Teil des Budgets sollte testweise in Influencer, Referral, Email sowie SEO- und Content-Maßnahmen umgeschichtet werden. Gleichzeitig ist zu berücksichtigen, dass ein hoher ROI bei kleinem Budget nicht automatisch bei starker Skalierung erhalten bleibt.


### 2.3. Kategorien: Vergleichen Sie Umsatz, Marge und Retouren. Welche Kategorien sind „Hidden Diamonds“?



Das Streudiagramm vergleicht die Kategorien anhand des Gesamtumsatzes auf der X-Achse und der durchschnittlichen Marge auf der Y-Achse. Die Punktgröße verstärkt zusätzlich die visuelle Wahrnehmung des Margenniveaus; die Retourenquote dient als ergänzender Kontext für die Bewertung der Kategorien.
Electronics dominiert den Umsatz mit rund 2,1 Mio. USD, weist jedoch mit 12 % die niedrigste Marge auf. Die Kategorie erzeugt ein hohes Umsatzvolumen, jeder Umsatzdollar trägt jedoch deutlich weniger zur Bruttomarge bei als in anderen Kategorien.
Die höchste Marge erzielt Beauty mit 55 % bei einem Umsatz von rund 168,6 Tsd. USD. Auch Clothing mit 45 % und Toys mit 40 % weisen hohe Margen auf. Beauty ist der überzeugendste „Hidden Diamond“: Das derzeitige Umsatzvolumen liegt deutlich unter Electronics, das Potenzial für profitables Wachstum ist jedoch wesentlich höher.
Betriebswirtschaftliche Schlussfolgerung: Electronics sollte als Umsatztreiber erhalten bleiben, seine Wirtschaftlichkeit muss jedoch durch bessere Einkaufskonditionen, Preisgestaltung, Sortimentsoptimierung und Retourenkontrolle verbessert werden. Beauty sollte durch eigenständige Kampagnen, Sortimentserweiterung und Cross-Selling ohne tiefe flächendeckende Rabatte skaliert werden.

### 2.4. Regionale Entwicklung: Welche Region wächst am schnellsten und welche verliert relativ an Dynamik?



Das Mehrliniendiagramm zeigt den Nettoumsatz der fünf Regionen von 2022 bis 2024. Im Jahr 2024 führt North America mit 718,73 Tsd. USD. Es folgen Southeast Asia mit 613,90 Tsd. USD, Europe mit 545,63 Tsd. USD, Latin America mit 321,39 Tsd. USD und Middle East mit 281,07 Tsd. USD.
Southeast Asia wächst am schnellsten: Der Umsatz stieg von rund 12,72 Tsd. USD im Jahr 2022 auf 613,90 Tsd. USD im Jahr 2024 und damit um mehr als das 48-Fache. Europe wächst ebenfalls weiter, weist jedoch die niedrigste relative Wachstumsrate der fünf Regionen auf. Europe ist daher als Markt mit relativer Verlangsamung und nicht als schrumpfender Markt einzuordnen.
Betriebswirtschaftliche Schlussfolgerung: Southeast Asia ist der wichtigste Markt für die weitere Expansion, während North America beim absoluten Umsatz führend bleibt. In Europe sollte der Schwerpunkt von breiter Akquisition auf Kundenbindung, Personalisierung und eine höhere Wiederkaufsfrequenz verlagert werden.

### 2.5. Kundenbeitrag: Welchen Umsatzanteil erzielen die Top-Kundinnen und -Kunden?



Das Pareto-Diagramm ordnet die Kundinnen und Kunden nach ihren Ausgaben und zeigt den kumulierten Umsatzanteil. Die Top 5 % der Kunden, also 150 von 3.000 Personen, generieren 35,1 % des Gesamtumsatzes beziehungsweise rund 1,218 Mio. USD. Die übrigen 95 % tragen 64,9 % bei.
Das Ergebnis zeigt eine relevante Umsatzkonzentration, bestätigt jedoch nicht die klassische 80/20-Regel. Der Umsatz von ShopSphere ist breiter über die Kundenbasis verteilt, als es das traditionelle Pareto-Prinzip erwarten ließe.
Betriebswirtschaftliche Schlussfolgerung: Für die Top 5 % ist ein eigenständiges Bindungsprogramm erforderlich. Gleichzeitig darf die breite Kundenbasis nicht vernachlässigt werden, da sie nahezu zwei Drittel des Umsatzes erwirtschaftet.


### 2.6. Kreative Analyse: Untersuchen Sie einen bisher nicht analysierten Faktor und leiten Sie einen Business Insight ab

Das horizontale Balkendiagramm vergleicht die Retourenquote nach Endgerät und Versandbedingung. Bei kostenpflichtigem Versand beträgt sie rund 7 % auf Desktop, 5 % auf Mobile und 6 % auf Tablet. Bei kostenlosem Versand steigt sie auf 11 %, 11 % beziehungsweise 10 %.
Der Effekt ist auf allen Geräten konsistent: Kostenloser Versand erhöht die Retourenquote um etwa 4–6 Prozentpunkte. Der entscheidende Faktor ist in dieser Analyse daher nicht das Endgerät, sondern die Versandbedingung.
Betriebswirtschaftliche Schlussfolgerung: Kostenloser Versand kann weniger überlegte Käufe oder die Bestellung mehrerer Produktvarianten fördern. Seine Wirtschaftlichkeit muss über das Verhältnis von zusätzlicher Conversion und zusätzlichem Umsatz zu den Kosten der Hin- und Rücklogistik bewertet werden.



## Block 3. Interaktive Dashboards für die Geschäftsleitung

Die analytische Lösung besteht aus zwei miteinander verbundenen Seiten: „Geschäftsüberblick“ und „Marketing & Wachstum“. Die erste Seite zeigt den allgemeinen Geschäftszustand, Saisonalität, regionale Entwicklung und die Struktur wertvoller Kunden. Die zweite Seite überführt die Analyse auf die Ebene steuerbarer Hebel: Marketingeffizienz, langfristiger Kundenwert und Rentabilität der Produktkategorien.

### Dashboard 1. Geschäftsüberblick

![Dashboard Geschäftsüberblick](photo_11_2026-07-24_15-38-52.jpg)

Im oberen Bereich befinden sich vier KPI-Karten:
Nettoumsatz — 3,47 Mio. USD;
Bestellungen — 12.274;
durchschnittlicher Bestellwert — 283,04 USD;
Retourenquote — 9,77 %.
Unterhalb der KPI-Karten befinden sich die monatliche Umsatzentwicklung und die regionale Entwicklung. Diese Visualisierungen beantworten, wann und in welchen Regionen das Wachstum entsteht. Die untere Zeile enthält das Pareto-Diagramm und die Heatmap der Top-5-%-Kunden. Das Pareto-Diagramm zeigt die Umsatzkonzentration, während die Heatmap Herkunftsregionen und Akquisitionskanäle der wertvollsten Kunden detailliert darstellt.
Die Filter `Region` und `Jahr` gelten für die kompatiblen Arbeitsblätter der primären Datenquelle: KPI-Karten, monatlicher Umsatz und regionale Entwicklung. Pareto und Heatmap basieren auf separaten aggregierten Datenquellen und bilden den strategischen Gesamtzeitraum 2022–2024 ab. Dadurch wird nicht fälschlicherweise vermittelt, dass ein Jahresfilter die Zusammensetzung der Top 5 % automatisch neu berechnet.

### Dashboard 2. Marketing & Wachstum

![Dashboard Marketing & Wachstum](photo_12_2026-07-24_15-38-52.jpg)

Das zweite Dashboard kombiniert drei Diagramme mit einem Textblock strategischer Schlussfolgerungen:
Streudiagramm „Marketingbudget — ROI“;
Balkendiagramm zum LTV nach Akquisitionskanal;
Streudiagramm „Umsatz — Marge“ nach Produktkategorie;
zusammenfassender Entscheidungsblock zur Budget- und Produktsteuerung.
Die durchgängige Geschäftsidee lautet: Wie soll das Marketingbudget eingesetzt werden, damit nicht nur kurzfristige Rendite, sondern auch wertvolle Kunden und profitables Kategorienwachstum entstehen?
Der ROI zeigt die kurzfristige Ausgabeneffizienz, der LTV beschreibt die langfristige Qualität der gewonnenen Kunden und die Kategorienanalyse identifiziert Produkte mit dem höchsten Potenzial für profitables Wachstum. Tooltips und Markierungen ermöglichen eine vertiefte Analyse einzelner Kanäle und Kategorien, ohne das Dashboard durch globale Filter zu überladen, die zwischen inkompatiblen Datenquellen nicht zuverlässig funktionieren.

### 3.2. Beschreiben Sie die Kompositionslogik: Welche Geschichte erzählen die Dashboards und warum wurde diese Reihenfolge gewählt?

Die Komposition führt vom allgemeinen Ergebnis über die Ursachen bis zu konkreten Managemententscheidungen.
Die erste Seite beginnt mit KPI-Karten, die einen unmittelbaren Überblick über Größenordnung und operative Qualität des Geschäfts geben. Danach erklären Zeit- und Regionsdiagramm, wann und wo das Ergebnis entstanden ist. Die untere Zeile zeigt die Kundenstruktur, die Umsatzkonzentration sowie das Profil der wertvollsten Käufergruppen.
Die zweite Seite beantwortet anschließend, welche Investitionen und Kategorien das weitere profitable Wachstum unterstützen sollen. Sie vergleicht zunächst Budget und ROI, ergänzt diese kurzfristige Perspektive um den langfristigen LTV und schließt die Analyse mit der Produktmarge ab.
Das übergreifende Storytelling lautet:
Ergebnis → zeitliche und regionale Wachstumstreiber → Kundenwert → Marketingeffizienz → Produktrentabilität → Managemententscheidung.


### 3.3. Welche drei Erkenntnisse soll die Leserin oder der Leser innerhalb der ersten 30 Sekunden erfassen?

ShopSphere erzielte 3,47 Mio. USD Nettoumsatz; der historische Monatsrekord lag im Dezember 2024 bei 759.390 USD. Das Wachstum ist stark, hängt jedoch wesentlich von einer saisonalen Spitze ab.
Paid Search erhält mit rund 451 Tsd. USD das größte Budget, weist jedoch den niedrigsten ROI von 133 % und den niedrigsten LTV von 648 USD auf. Die aktuelle Budgetallokation muss überprüft werden.
Die Top 5 % der Kunden generieren 35,1 % des Umsatzes, Southeast Asia ist die dynamischste Region und Beauty erzielt mit 55 % die höchste Marge. Zukünftiges Wachstum muss Kundenbindung, regionale Expansion und den Ausbau margenstarker Kategorien verbinden.

## Block 4. Strategische Business Cases
### 4.3. Welcher Kanal erzielt den höchsten beziehungsweise niedrigsten ROI und wohin fließt der größte Budgetanteil?

Den höchsten ROI erzielt Organic mit 802 %, gefolgt von Email mit 650 %. Den niedrigsten ROI weist Paid Search mit 133 % auf. Gleichzeitig erhält Paid Search mit rund 451 Tsd. USD das größte Budget. Social Ads verfügt über etwa 286 Tsd. USD und erreicht mit 206 % den zweitniedrigsten ROI.
Die derzeitige Ausgabenstruktur ist unausgewogen: Die größten Mittel fließen in Kanäle mit der niedrigsten aggregierten Rendite. Dies reicht jedoch nicht aus, um die Kanäle vollständig abzuschalten, da auch ihre Funktion im oberen Funnel, die Attributionslogik und die Grenzwirkung bei Skalierung berücksichtigt werden müssen.


### 4.4. Vergleichen Sie die Kanäle nach ROI und langfristigem Kundenwert. Stimmen die Ergebnisse überein?

![Langfristiger Kundenwert nach Akquisitionskanal](photo_7_2026-07-24_15-38-52.jpg)

Die Ergebnisse stimmen nur teilweise überein. Beim LTV führen Influencer mit 1.986 USD und Referral mit 1.792 USD. Es folgen Organic mit 1.316 USD, Email mit 1.074 USD, Social Ads mit 822 USD und Paid Search mit 648 USD.
Organic und Email erzielen die höchste kurzfristige Budgeteffizienz. Influencer und Referral gewinnen dagegen die langfristig wertvollsten Kunden. Paid Search ist bei beiden Kennzahlen der schwächste Kanal.
Betriebswirtschaftliche Schlussfolgerung: Das Marketingbudget darf nicht anhand eines einzigen KPI verteilt werden. Der ROI bewertet die aktuelle Ausgabeneffizienz, während der LTV die langfristige Qualität der gewonnenen Zielgruppe abbildet.

### 4.5. Wie soll das Budget umverteilt werden und welche Risiken entstehen?

Das Budget von Paid Search sollte in einem schrittweisen Test um 30–40 % reduziert werden. Ein Teil der frei werdenden Mittel sollte in Influencer und Referral fließen, da diese Kanäle den höchsten LTV erzielen. Email sollte aufgrund seines hohen ROI beibehalten oder moderat ausgebaut werden. Organic ist durch SEO, Content und technische Optimierung zu unterstützen. Social Ads benötigt ein Audit und eine selektive Kürzung ineffizienter Kampagnen.
Wesentliche Risiken:
Paid Search kann den Erstkontakt erzeugen, während spätere Käufe anderen Kanälen zugerechnet werden;
Influencer und Referral können nur begrenzt skalierbar sein und bei höheren Investitionen sinkende Grenzerträge aufweisen;
LTV ohne Kontrolle des Kohortenalters kann Kanäle mit einer älteren Kundenbasis überbewerten;
eine Kürzung des bezahlten Traffics im vierten Quartal kann die saisonale Umsatzspitze überproportional beeinträchtigen.
Die Umverteilung muss deshalb über kontrollierte Budgetexperimente erfolgen. Dabei sind Umsatz, Neukunden, CAC, ROI und kohortenbasierter LTV gleichzeitig zu überwachen.


### 4.6. Welche Kategorie erzeugt eine „Volumenillusion“?

Electronics erzeugt die stärkste Volumenillusion. Die Kategorie erzielt rund 2,1 Mio. USD Umsatz und liegt damit deutlich vor allen anderen Kategorien, weist jedoch mit 12 % die niedrigste Marge auf.
Zum Vergleich: Beauty erzielt 55 %, Clothing 45 %, Toys 40 %, Home & Kitchen 35 %, Sports 30 % und Books 25 % Marge. Ein Umsatzdollar in Electronics erzeugt somit deutlich weniger Bruttomarge als ein Umsatzdollar in Beauty oder Clothing.
Electronics sollte als Umsatztreiber erhalten bleiben. Seine Wirtschaftlichkeit muss jedoch über bessere Einkaufskonditionen, SKU-Optimierung, Preisgestaltung und Retourenkontrolle verbessert werden. Parallel ist der Anteil margenstarker Kategorien im Produktportfolio auszubauen.

### 4.7. Gibt es einen „Hidden Diamond“ mit kleinem Umsatz, hoher Marge und gesunder Retourenstruktur?

Der überzeugendste „Hidden Diamond“ ist Beauty. Der Umsatz beträgt rund 168,6 Tsd. USD, die Marge ist mit 55 % jedoch die höchste aller Kategorien. Das derzeitige Volumen ist vergleichsweise klein, wodurch die hohe Marge erhebliches Potenzial für profitables Wachstum bietet.
Strategische Maßnahmen:
Erweiterung des Beauty-Sortiments und Prüfung neuer Marken oder Private-Label-Angebote;
eigenständige Kampagnen ohne tiefe flächendeckende Rabatte;
Cross-Selling an die Top-5-%-Kundengruppe;
schrittweise Skalierung unter Kontrolle von Marge, Retouren, Wiederkäufen und Kannibalisierung.

### 4.8. Binden sich Kundinnen und Kunden, die überwiegend mit mehr als 20 % Rabatt kaufen, langfristig an das Unternehmen?

![Vergleich rabattorientierter Kunden mit der übrigen Kundenbasis](photo_8_2026-07-24_15-38-52.jpg)

Nein. Kundinnen und Kunden mit hohen durchschnittlichen Rabatten weisen eine deutlich geringere Loyalität auf. Im rabattorientierten Segment liegt die durchschnittliche Bestellanzahl bei 2,17, der durchschnittliche LTV bei rund 384 USD und der Anteil der Einmalkäufer bei 25,0 %. Bei den übrigen Kunden liegen diese Werte bei 4,35 Bestellungen, 1.261 USD LTV und 16,6 % Einmalkäufern.
Rabattorientierte Kunden kaufen somit ungefähr halb so häufig, weisen einen rund 70 % niedrigeren LTV auf und bleiben häufiger Einmalkäufer.
Betriebswirtschaftliche Schlussfolgerung: Flächendeckende Rabatte von mehr als 20 % schaffen keine nachhaltige Kundenbindung. Geeigneter sind personalisierte Angebote, Boni für den nächsten Einkauf, Bundles und Loyalitätsprogramme. Hohe Rabatte sollten selektiv für Abverkauf, Reaktivierung oder kontrollierte Experimente eingesetzt werden.

### 4.9. Welchen Umsatzanteil erzielen die Top 5 %, wer sind diese Kunden und wie können sie gebunden werden?

![Umsatz der Top-5-%-Kunden nach Region und Kanal](photo_9_2026-07-24_15-38-52.jpg)

Die Top 5 % der Kunden — 150 Personen — generieren 35,07 % des Gesamtumsatzes beziehungsweise rund 1.218.211 USD.
Die stärksten Kombinationen aus Region und Kanal sind:
Europe × Influencer — 125.894 USD;
Southeast Asia × Organic — 117.095 USD;
Southeast Asia × Influencer — 104.978 USD;
North America × Influencer — 95.328 USD;
North America × Organic — 89.250 USD.
Das Profil der Top-Kundengruppe bestätigt die besondere Bedeutung von Influencer und Organic sowie der Regionen Europe, Southeast Asia und North America.
Für dieses Segment ist ein VIP-Programm ohne tiefe Rabatte geeignet: früher Zugang zu neuen Produkten, priorisierter Support, personalisierte Empfehlungen, Servicevorteile und Trigger-Kommunikation bei sinkender Aktivität. Gleichzeitig muss das mittlere Kundensegment weiterentwickelt werden, um die Abhängigkeit von 150 besonders wertvollen Personen zu reduzieren.


## Block 5. Statistisches Denken: A/B-Experiment
### 5.10. Vergleichen Sie den durchschnittlichen Bestellwert der Gruppen A und B über alle Bestellungen des Experiments

Gruppe A umfasst 3.681 Bestellungen mit einem durchschnittlichen Bestellwert von 281,73 USD. Gruppe B umfasst 3.674 Bestellungen mit einem durchschnittlichen Bestellwert von 287,27 USD.
Deskriptiv liegt B um 5,54 USD beziehungsweise rund 2,0 % über A. Auf den ersten Blick erscheint Variante B daher besser. Der Gesamtmittelwert zeigt jedoch nicht, ob der Effekt für unterschiedliche Kundengruppen gleich ist, und beweist keine statistische Signifikanz.

### 5.11. Vergleichen Sie A und B getrennt für neue und wiederkehrende Kunden. Was zeigt die Segmentierung?

![Durchschnittlicher Bestellwert der A/B-Varianten nach Kundentyp](photo_10_2026-07-24_15-38-52.jpg)

Die Segmentierung ergibt:
A, Neukunden: 264 Bestellungen, durchschnittlicher Bestellwert 223,30 USD;
B, Neukunden: 256 Bestellungen, durchschnittlicher Bestellwert 266,21 USD;
A, Bestandskunden: 3.417 Bestellungen, durchschnittlicher Bestellwert 286,24 USD;
B, Bestandskunden: 3.418 Bestellungen, durchschnittlicher Bestellwert 288,85 USD.
Bei Neukunden beträgt der Anstieg 42,91 USD beziehungsweise 19,2 %. Bei Bestandskunden liegt er lediglich bei 2,61 USD beziehungsweise 0,9 %.
Die zentrale Erkenntnis lautet: Der Effekt von Variante B ist heterogen. Nahezu der gesamte praktisch relevante Anstieg konzentriert sich auf das kleine Segment der Neukunden, während der Unterschied bei Bestandskunden minimal ist. Die im Aufgabenkontext als Simpson-Paradoxon bezeichnete Segmentierung verändert die betriebswirtschaftliche Interpretation des aggregierten Ergebnisses wesentlich. Da sich die Wirkungsrichtung statistisch nicht umkehrt, ist der Begriff „verborgene Effektheterogenität“ präziser.


### 5.12. Für welche Kundengruppe soll Variante B eingeführt werden und kann sie für alle aktiviert werden?

Variante B sollte vorrangig für Neukunden eingeführt werden, da ihr durchschnittlicher Bestellwert in diesem Segment um 19,2 % höher liegt. Bei Bestandskunden beträgt der Anstieg lediglich 0,9 %, sodass ein praktisch relevanter Vorteil nicht nachgewiesen ist.
Ein vollständiger Rollout für alle Nutzer ist derzeit nicht begründet. Die geeignete Lösung ist ein zielgerichteter Rollout für Neukunden mit anschließender Überwachung von Conversion, durchschnittlichem Bestellwert, Checkout-Abbrüchen, Retouren und Deckungsbeitrag.
Vor einer endgültigen Entscheidung ist ein Signifikanztest mit Konfidenzintervall und Effektgröße erforderlich. Der durchschnittliche Bestellwert allein zeigt die Wirkung auf die Conversion nicht. Falls B den Bestellwert erhöht, gleichzeitig aber die Abschlussrate reduziert, kann der gesamte Geschäftseffekt negativ ausfallen.

### 5.13. Wie könnte Variante B manipulativ „verkauft“ oder „begraben“ werden und wie muss das Ergebnis fair präsentiert werden?

Um B zu „verkaufen“, könnte ausschließlich das Neukundenergebnis gezeigt werden: „Der durchschnittliche Bestellwert steigt um 19,2 %.“ Diese Aussage ist sachlich korrekt, aber ohne den Hinweis irreführend, dass Neukunden nur etwa 7 % der Bestellungen im Experiment ausmachen.
Um B zu „begraben“, könnte ausschließlich das Ergebnis der Bestandskunden gezeigt werden: „Der Anstieg beträgt nur 0,9 %.“ Auch diese Aussage ist korrekt, verschweigt jedoch den starken positiven Effekt bei Neukunden.
Eine faire Darstellung muss gleichzeitig enthalten:
Gesamtergebnis: +2,0 %;
Ergebnis der Neukunden: +19,2 %;
Ergebnis der Bestandskunden: +0,9 %;
Stichprobengrößen aller vier Untergruppen;
Konfidenzintervalle, p-Wert und Effektgröße nach Durchführung eines statistischen Tests;
den Hinweis, dass ohne Conversion-Kennzahl keine vollständige Bewertung des Checkouts möglich ist.
Variante B besitzt ein starkes deskriptives Potenzial für Neukunden, darf jedoch nicht als universell bessere Lösung für die gesamte Kundenbasis positioniert werden.

## Abschließende Empfehlungen für die Geschäftsleitung

Paid Search und teilweise Social Ads schrittweise reduzieren und die frei werdenden Mittel testweise in Influencer, Referral, Email, SEO und Content investieren.
Electronics als Umsatztreiber erhalten, jedoch seine Marge verbessern; Beauty als stärkste margenorientierte Wachstumschance separat skalieren.
Southeast Asia bei der Expansion priorisieren und in Europe Kundenbindung sowie Wiederkäufe stärken.
Ein VIP-Programm für die Top 5 % der Kunden einführen, die 35,1 % des Umsatzes generieren, und gleichzeitig das breitere mittlere Segment weiterentwickeln.
Tiefe flächendeckende Rabatte durch Wiederkaufsmechaniken ersetzen und Checkout B nach Prüfung von Signifikanz und Conversion-Effekt gezielt für Neukunden einführen.
