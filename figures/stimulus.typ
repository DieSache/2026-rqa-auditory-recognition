#import "design.typ": EARLY_CHANGE, LATE_CHANGE, color-box

#let stimulus-tone(index, change: none) = {
  let note = box(width: 1.25em, height: 1.25em, radius: 50%, stroke: black + 0.6pt, fill: luma(94%))[
    #align(center + horizon)[#text(size: 7pt)[T#index]]
  ]
  if change != none {
    let change-color = if change == "early" { EARLY_CHANGE } else { LATE_CHANGE }
    box(radius: 50%, stroke: change-color + 0.9pt, inset: 0.18em)[#note]
  } else {
    box(inset: 0.18em)[#note]
  }
}

#let stimulus-figure() = figure(
  align(center)[
    #grid(
      columns: (2.2em, 1.55em, 1.55em, 1.55em, 1.55em, 1.55em, 1.55em, 1.55em),
      column-gutter: 0.45em,
      row-gutter: 0.55em,
      align: center + horizon,
      [M3:], stimulus-tone(1), stimulus-tone(2, change: "early"), stimulus-tone(3, change: "late"), [], [], [], [],
      [M5:], stimulus-tone(1), stimulus-tone(2), stimulus-tone(3, change: "early"), stimulus-tone(4), stimulus-tone(5, change: "late"), [], [],
      [M7:], stimulus-tone(1), stimulus-tone(2), stimulus-tone(3), stimulus-tone(4), stimulus-tone(5, change: "early"), stimulus-tone(6), stimulus-tone(7, change: "late"),
    )
  ],
  supplement: [Figure],
  caption: [
    Melody lengths and single-tone change positions are shown for #color-box(EARLY_CHANGE) early-change and #color-box(LATE_CHANGE) late-change trials.
  ],
)
