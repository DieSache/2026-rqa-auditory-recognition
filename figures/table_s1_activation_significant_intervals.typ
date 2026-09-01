#import "design.typ": portrait-figure

#let format-time(value) = {
  str(calc.round(float(value) * 1000) / 1000)
}

#let intervals(correction, melody, network, condition) = {
  let rows = csv(
    "../output/3_timeseries/" + correction + "/significance_windows_" + melody + "_bn_" + str(network) + ".csv",
    row-type: dictionary,
  ).filter(row => row.condition == condition)

  if rows.len() == 0 {
    [--]
  } else {
    rows.map(row => [#format-time(row.start)#sym.dash.en#format-time(row.end)]).join([; ])
  }
}

#let interval-table(correction, size: 9pt, inset: 5pt) = {
  text(size: size)[
    #set par(justify: false)
    #table(
      columns: (auto, auto, 1fr, 1fr),
      align: (center, center, left, left),
      inset: inset,
      stroke: none,
      table.hline(stroke: black + 0.6pt),
      [*Melody*], [*Network*], [*M vs. early change (s)*], [*M vs. late change (s)*],
      table.hline(stroke: black + 0.3pt),
      [M3], [1], [#intervals(correction, "m3", 1, "NTE")], [#intervals(correction, "m3", 1, "NTL")],
      [], [2], [#intervals(correction, "m3", 2, "NTE")], [#intervals(correction, "m3", 2, "NTL")],
      [], [3], [#intervals(correction, "m3", 3, "NTE")], [#intervals(correction, "m3", 3, "NTL")],
      table.hline(stroke: black + 0.3pt),
      [M5], [1], [#intervals(correction, "m5", 1, "NTE")], [#intervals(correction, "m5", 1, "NTL")],
      [], [2], [#intervals(correction, "m5", 2, "NTE")], [#intervals(correction, "m5", 2, "NTL")],
      [], [3], [#intervals(correction, "m5", 3, "NTE")], [#intervals(correction, "m5", 3, "NTL")],
      table.hline(stroke: black + 0.3pt),
      [M7], [1], [#intervals(correction, "m7", 1, "NTE")], [#intervals(correction, "m7", 1, "NTL")],
      [], [2], [#intervals(correction, "m7", 2, "NTE")], [#intervals(correction, "m7", 2, "NTL")],
      [], [3], [#intervals(correction, "m7", 3, "NTE")], [#intervals(correction, "m7", 3, "NTL")],
      table.hline(stroke: black + 0.6pt),
    )
  ]
}

#portrait-figure[
#figure(
  interval-table("cluster", size: 9pt, inset: 5pt),
  kind: "supplementary-table",
  supplement: [Table S],
  numbering: "1",
  caption: [
    *Cluster-corrected activation differences.* Significant intervals are reported in seconds from melody onset for the comparisons shown in @fig:activation-time-series. A dash indicates that no significant cluster was detected.
  ],
)<tab:activation-significant-intervals>
]
