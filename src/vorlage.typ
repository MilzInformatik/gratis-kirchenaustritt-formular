// =============================================================
//  Kirchenaustritt: Briefvorlage
//
//  Die Werte kommen als JSON über `sys.inputs.data` aus dem
//  Web-Formular. Aufbau der Datei:
//    1. Angaben einlesen
//    2. Masse (Seite, Adressfeld, Abstände)
//    3. Bausteine (Absender, Empfänger, Personalien)
//    4. Der Brief
// =============================================================

// ---------------------------- 1. Angaben ---------------------

#let daten = json.decode(sys.inputs.at("data", default: "{}"))
#let feld(key) = daten.at(key, default: "")

#let person = (
  vorname: feld("vorname"),
  name: feld("name"),
  geburtsdatum: feld("geburtsdatum"),
  strasse: feld("strasse"),
  plz: feld("plz"),
  ort: feld("ort"),
)

#let kirchgemeinde = (
  name: feld("kg_name"),
  strasse: feld("kg_strasse"),
  plz_ort: feld("kg_plz_ort"),
)

#let brief = (
  ort_datum: feld("ort_datum"),
  konfession: feld("konfession"),
  keine_kontaktaufnahme: daten.at("keine_kontaktaufnahme", default: true),
)

#let vollname = (person.vorname, person.name).filter(s => s != "").join(" ")

// ---------------------------- 2. Masse -----------------------

#let rand = (left: 25mm, right: 20mm, top: 20mm, bottom: 20mm)

// Adressfeld für Schweizer Fenstercouverts mit Fenster rechts
// (C5/6 mit A4 dreifach gefaltet, C5 mit A4 einfach gefaltet).
// Das Fenster ist 100 x 45 mm gross und sitzt 20 mm vom rechten
// Couvertrand. Auf dem A4-Blatt liegt es damit ungefähr bei
// 100 bis 200 mm von links und 47 bis 95 mm von oben. Das
// Adressfeld bleibt mit Sicherheitsabstand innerhalb dieser Zone.
#let adressfeld = (x: 105mm, y: 57mm, breite: 85mm)

// Ab hier beginnt der Text unterhalb des Fensters.
#let textbeginn = 100mm

#let unterschrift_platz = 2.2cm

#set page(paper: "a4", margin: rand)
#set text(font: ("Arial", "Arimo"), size: 11pt, lang: "de", region: "ch")
#set par(justify: false, leading: 0.6em, spacing: 1.2em)

// ---------------------------- 3. Bausteine -------------------

#let absender = [
  #vollname \
  #person.strasse \
  #person.plz #person.ort
]

#let empfaenger = block(width: adressfeld.breite)[
  #set par(leading: 0.55em)
  #text(size: 7.5pt)[#vollname, #person.strasse, #person.plz #person.ort]
  #v(-0.3em)
  #line(length: 100%, stroke: 0.4pt)
  #v(0.2em)
  #kirchgemeinde.name \
  #kirchgemeinde.strasse \
  #kirchgemeinde.plz_ort
]

#let personalien = grid(
  columns: (4cm, 1fr),
  row-gutter: 0.6em,
  [Name], [#vollname],
  [Geburtsdatum], [#person.geburtsdatum],
  [Adresse], [#person.strasse, #person.plz #person.ort],
)

// ---------------------------- 4. Der Brief -------------------

// Absender oben links, Empfänger im Fensterbereich. Beide werden
// absolut platziert, die Masse gelten ab Blattkante.
#place(top + left, absender)
#place(
  top + left,
  dx: adressfeld.x - rand.left,
  dy: adressfeld.y - rand.top,
  empfaenger,
)

#v(textbeginn - rand.top)

#brief.ort_datum

#v(0.8cm)

*Austritt aus der Kirche*

#v(0.2cm)

Sehr geehrte Damen und Herren

Ich erkläre hiermit meinen Austritt aus der #brief.konfession. Bitte
streichen Sie mich aus dem Mitgliederverzeichnis Ihrer Kirchgemeinde.

Zu meiner Person:

#block(above: 0.5em, below: 1.4em, personalien)

Bitte bestätigen Sie mir den Austritt schriftlich.

#if brief.keine_kontaktaufnahme [
  Ich bitte Sie, von einer Kontaktaufnahme oder einem Gespräch zu
  diesem Entscheid abzusehen.
]

Freundliche Grüsse

#v(unterschrift_platz)

#line(length: 6cm, stroke: 0.5pt)
#v(-0.4em)
#vollname
