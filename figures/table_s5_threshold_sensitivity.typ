#import "design.typ": portrait-figure
#import "manuscript_data.typ": *

#let metrics = ("RR", "L", "DET", "ENTR", "TT", "LAM", "V_max", "DIV")
#let thresholds = (.05, .075, .1, .125, .15)
#let metric-label(metric) = if metric == "L" { [$L$] } else if metric == "V_max" { [$V_"max"$] } else { metric }
#let result-cell(metric, threshold) = {
  let row = threshold-stat(threshold, metric)
  let value = [#number(row.F_statistic, digits: 2) / #table-p(row.p_value_fdr_8way)]
  if float(row.p_value_fdr_8way) < .05 { strong(value) } else { value }
}

#portrait-figure[
#figure(
  kind: "supplementary-table",
  supplement: [Table S],
  numbering: "1",
  caption: [
    *Sensitivity of RQA condition effects to the recurrence threshold.* Cells report the omnibus three-level condition-effect $F$ statistic followed by its FDR-adjusted $q$ value. Effects were estimated across all melody lengths in the 3 × 3 repeated-measures ANOVA. FDR correction was applied across the eight metrics separately at each threshold; significant effects are bold. The 10% threshold was primary.
  ],
  text(size: 8pt)[
    #set par(justify: false)
    #table(
      columns: (auto, 1fr, 1fr, 1fr, 1fr, 1fr),
      align: (left, center, center, center, center, center),
      inset: (x: 4pt, y: 5pt),
      stroke: none,
      table.header([*Metric*], [*5%*], [*7.5%*], [*10%*], [*12.5%*], [*15%*]),
      table.hline(stroke: 0.7pt),
      ..metrics.map(metric => (
        [#metric-label(metric)],
        ..thresholds.map(threshold => [#result-cell(metric, threshold)]),
      )).flatten(),
      table.hline(stroke: 0.7pt),
    )
  ],
)<tab:rqa-threshold-sensitivity>
]
