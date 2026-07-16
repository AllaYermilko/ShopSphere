# Analyse des globalen Marktplatzes ShopSphere

ShopSphere ist ein Lernprojekt zur Analyse von E-Commerce-Daten aus den Jahren 2022–2024. Das Projekt umfasst den gesamten Analyseprozess – von Rohdaten im CSV-Format und SQL-Abfragen bis hin zu einem Tableau-Dashboard, geschäftlichen Erkenntnissen und der statistischen Auswertung eines A/B-Tests.

## Daten:
- Quelle: ShopSphere-Übungsdatensätze: customers, products, orders, order_items, marketing.
- Umfang: 3.000 Kunden, 250 Produkte, 12.274 Bestellungen, 26.068 Bestellpositionen und 216 Marketingkampagnen.
- Analysezeitraum: 2022–2024.

## Ziel:
Das Ziel des Projekts ist es, die wichtigsten Fragen des CEO zu beantworten: Welche Marketingkanäle sind am effektivsten? Welche Produktkategorien sind wirklich profitabel? Welche Kunden sind am wertvollsten? Welche Regionen haben das größte Wachstumspotenzial? Und sollte der neue Checkout für alle Nutzer eingeführt werden?

## Verwendete Tools und Arbeitsschritte:
1. SQLiteOnline: JOINs, Aggregationen, Unterabfragen und Vorbereitung der Daten für Tableau.
2. Excel / CSV: Erstellung von Zwischentabellen für die Visualisierungen.
3. Tableau Public: Mehr als fünf Visualisierungen und ein Dashboard für den CEO.
4. Python: Analyse des A/B-Tests, Berechnung der Mittelwerte und des p-Werts.

## Dashboard:
Link zu Tableau Public: ________________________________

## Kurze Zusammenfassung für den CEO:

1. ShopSphere erzielte einen Nettoumsatz von 3.474.016,03 US-Dollar, 12.274 Bestellungen, einen durchschnittlichen Bestellwert von 283,04 US-Dollar und eine Rücksendequote von 9,77 %.
2. Die größte Herausforderung liegt im Marketing: Paid Search erhält das höchste Budget, erzielt jedoch den niedrigsten ROI.
3. Im Produktportfolio ist Electronics die kritischste Kategorie. Sie generiert zwar einen hohen Umsatz, hat jedoch eine niedrige Gewinnmarge und eine hohe Rücksendequote.
4. Der A/B-Test zeigte, dass Checkout B für Neukunden bessere Ergebnisse liefert, für Bestandskunden jedoch keinen Vorteil bringt. Deshalb sollte er nicht für alle Nutzer eingeführt werden.
