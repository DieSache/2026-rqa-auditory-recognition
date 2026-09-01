#import "design.typ": portrait-figure
#import "manuscript_data.typ": *

#let metrics = ("all_eight", "RR", "L", "DET", "ENTR", "TT", "LAM", "V_max", "DIV")
#let dash-or(value, digits: 3) = if value == "NaN" { [--] } else { number(value, digits: digits) }
#let ci-cell(metric) = {
  let row = matched-result(metric)
  if row.ci_95_low == "NaN" { [--] } else { [#number(row.ci_95_low, digits: 2)#sym.dash.en#number(row.ci_95_high, digits: 2)] }
}
#let lr-cell(metric) = {
  let row = matched-result(metric)
  [#number(row.likelihood_ratio_chisq) (#integer(row.degrees_of_freedom))]
}
#let p-cell(metric) = {
  let row = matched-result(metric)
  table-p(if row.result_type == "joint" { row.p_value } else { row.p_value_fdr_8way })
}
#let ridge-cell(metric) = if metric == "all_eight" { [--] } else { [#number(ridge-metric(metric).mean_coefficient, digits: 3)] }

#portrait-figure[
#figure(
  kind: "supplementary-table",
  supplement: [Table S],
  numbering: "1",
  caption: [
    *Joint and metric-level contributions of RQA to accuracy beyond RMS activation amplitude.* All models adjust for condition, melody length, their interaction, and RMS activation amplitude. Mixed-model rows compare this baseline with the model containing all eight standardized RQA measures; metric columns give joint-model coefficients and one-degree-of-freedom drop-one tests, with FDR correction across metrics. These individual results are descriptive because the RQA measures are collinear. Prediction rows report nested participant-wise ridge regression, in which only the RQA measures were penalized. Mean ridge coefficients summarize the #integer(ridge-result.n_subjects) outer-fold fits. The confidence interval was obtained by participant-level bootstrap resampling. $Delta R^2$, change in marginal $R^2$.
  ],
  text(size: 6.5pt)[
    #set par(justify: false)
    #table(
      columns: (1.25fr, .85fr, .78fr, .78fr, .78fr, .78fr, .78fr, .78fr, .88fr, .78fr),
      align: (left, center, center, center, center, center, center, center, center, center),
      inset: (x: 1.5pt, y: 4pt),
      stroke: none,
      table.header([*Statistic*], [*Joint*], [*RR*], [*$L$*], [*DET*], [*ENTR*], [*TT*], [*LAM*], [*$V_"max"$*], [*DIV*]),
      table.hline(stroke: 0.7pt),
      [Standardized $beta$], ..metrics.map(metric => [#dash-or(matched-result(metric).standardized_coefficient)]),
      [95% CI], ..metrics.map(ci-cell),
      [$chi^2$ (df)], ..metrics.map(lr-cell),
      [$p$ / FDR $q$], ..metrics.map(metric => [#p-cell(metric)]),
      [$Delta R^2$], ..metrics.map(metric => [#fixed(matched-result(metric).incremental_marginal_R2)]),
      [Mean ridge $beta$], ..metrics.map(ridge-cell),
      [Nested ridge RMSE], [#fixed(ridge-result.ridge_RMSE)], [--], [--], [--], [--], [--], [--], [--], [--],
      [RMSE improvement], [#fixed(ridge-result.RMSE_improvement_percent, digits: 2)%], [--], [--], [--], [--], [--], [--], [--], [--],
      [Participant-bootstrap 95% CI], [#fixed(ridge-result.bootstrap_CI_low, digits: 2)%#sym.dash.en#fixed(ridge-result.bootstrap_CI_high, digits: 2)%], [--], [--], [--], [--], [--], [--], [--], [--],
      table.hline(stroke: 0.7pt),
    )
  ],
)<tab:matched-rqa>
]
