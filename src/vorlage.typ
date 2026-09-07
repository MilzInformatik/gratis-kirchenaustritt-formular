// =============================================================
//  Kirchenaustrittserklärung — Typst-Vorlage
//  Die Angaben kommen als JSON über `sys.inputs.data` aus dem
//  Web-Formular.
// =============================================================

#let d = json.decode(sys.inputs.at("data", default: "{}"))
#let get(key) = d.at(key, default: "")

#let absender = (
  vorname: get("vorname"),
  name: get("name"),
  strasse: get("strasse"),
  plz: get("plz"),
  ort: get("ort"),
  geburtsdatum: get("geburtsdatum"),
)

#let empfaenger = (
  name: get("kg_name"),
  strasse: get("kg_strasse"),
  plz_ort: get("kg_plz_ort"),
)

#let ort_datum = get("ort_datum")
#let betreff = "Kirchenaustrittserklärung"
#let konfession = get("konfession")

#let keine_kontaktaufnahme = d.at("keine_kontaktaufnahme", default: true)
#let unterschriftsraum = 3cm

// ---------------------------- Layout -------------------------

#set page(
  paper: "a4",
  margin: (left: 2.5cm, right: 2.5cm, top: 2cm, bottom: 2cm),
)

#set text(
  font: ("Arial", "Arimo"),
  size: 11pt,
  lang: "de",
  region: "ch",
)

#set par(justify: false, leading: 0.65em, spacing: 1.4em)

#let vollname = absender.vorname + " " + absender.name
#let adressspalte = 50%

#v(2cm)

// Adressfeld rechts
#grid(
  columns: (50%, 1fr),
  block(spacing: 0em)[
    #v(3em)

    #vollname\
    #absender.strasse \
    #absender.plz #absender.ort
  ],
  block(spacing: 0em)[
    #block(below: 0.35em)[
      #text(size: 7.5pt)[
        Abs.: #vollname - #absender.strasse - #absender.plz #absender.ort
      ]
    ]
    #line(length: 100%, stroke: 0.5pt)
    #v(0.6em)
    #empfaenger.name \
    #empfaenger.strasse \
    #empfaenger.plz_ort
  ],
)

#v(3cm)

#ort_datum

#v(1cm)

*#betreff*

#v(1em)

Sehr geehrte Damen und Herren

Hiermit erkläre ich den Austritt aus der #konfession.

*Personalien:*

#block(above: 0.6em)[
  #grid(
    columns: (adressspalte, 1fr),
    row-gutter: 0.7em,
    [Voller Name:], [#absender.vorname #absender.name],
    [Geburtsdatum:],   [#absender.geburtsdatum],
    [Strasse:],        [#absender.strasse],
    [PLZ / Ort:],      [#absender.plz #absender.ort],
  )
]

#v(0.8em)

#if keine_kontaktaufnahme [
  Ich möchte zu meinem Austritt nicht kontaktiert oder befragt werden.
]

Gerne möchte ich Sie bitten, mir den Austritt zu bestätigen.

#v(1em)

Freundliche Grüsse

#v(unterschriftsraum)

#vollname
