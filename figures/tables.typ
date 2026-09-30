#import "manuscript_data.typ": *

#let participant-table() = figure(
  text(size: 9pt)[#table(
    columns: (1.35fr, 1fr),
    align: (left, center),
    inset: (x: 4pt, y: 3pt),
    stroke: none,
    table.hline(stroke: black + 0.6pt),
    [*Characteristic*], [*Overall*],
    table.hline(stroke: black + 0.3pt),
    [Participants, $n$], [#integer(participant("Overall").n)],
    [Age, mean ± SD], [#age-cell("Overall")],
    [Age range], [#age-range-cell("Overall")],
    [Female, $n$ (\%)], [#count-percent(participant("Overall").female_n, participant("Overall").n)],
    [Male, $n$ (\%)], [#count-percent(participant("Overall").male_n, participant("Overall").n)],
    [Compensation], [#integer(participant("Overall").compensation_dkk) DKK],
    table.hline(stroke: black + 0.6pt),
  )],
  kind: table,
  supplement: [Table],
  caption: [*Participant characteristics.* Percentages use the full sample as denominator.],
)

#let behavioural-table() = figure(
  text(size: 7.5pt)[
    #table(
      columns: (0.55fr, 0.9fr, 1.05fr, 1.05fr, 1.05fr, 1.25fr, 1.25fr),
      align: (center, left, center, center, center, center, center),
      inset: (x: 3.5pt, y: 3pt),
      stroke: none,
      table.header([*Melody*], [*Condition*], [*Correct (%)*], [*Incorrect (%)*], [*No response (%)*], [*Correct RT (ms)*], [*Incorrect RT (ms)*]),
      table.hline(stroke: 0.7pt),
      [M3], [Memorized], [#descriptive-cell(3, 1, "Correct")], [#descriptive-cell(3, 1, "Incorrect")], [#descriptive-cell(3, 1, "No response")], [#descriptive-cell(3, 1, "Correct RT")], [#descriptive-cell(3, 1, "Incorrect RT")],
      [], [Early change], [#descriptive-cell(3, 2, "Correct")], [#descriptive-cell(3, 2, "Incorrect")], [#descriptive-cell(3, 2, "No response")], [#descriptive-cell(3, 2, "Correct RT")], [#descriptive-cell(3, 2, "Incorrect RT")],
      [], [Late change], [#descriptive-cell(3, 3, "Correct")], [#descriptive-cell(3, 3, "Incorrect")], [#descriptive-cell(3, 3, "No response")], [#descriptive-cell(3, 3, "Correct RT")], [#descriptive-cell(3, 3, "Incorrect RT")],
      table.hline(stroke: 0.35pt),
      [M5], [Memorized], [#descriptive-cell(5, 1, "Correct")], [#descriptive-cell(5, 1, "Incorrect")], [#descriptive-cell(5, 1, "No response")], [#descriptive-cell(5, 1, "Correct RT")], [#descriptive-cell(5, 1, "Incorrect RT")],
      [], [Early change], [#descriptive-cell(5, 2, "Correct")], [#descriptive-cell(5, 2, "Incorrect")], [#descriptive-cell(5, 2, "No response")], [#descriptive-cell(5, 2, "Correct RT")], [#descriptive-cell(5, 2, "Incorrect RT")],
      [], [Late change], [#descriptive-cell(5, 3, "Correct")], [#descriptive-cell(5, 3, "Incorrect")], [#descriptive-cell(5, 3, "No response")], [#descriptive-cell(5, 3, "Correct RT")], [#descriptive-cell(5, 3, "Incorrect RT")],
      table.hline(stroke: 0.35pt),
      [M7], [Memorized], [#descriptive-cell(7, 1, "Correct")], [#descriptive-cell(7, 1, "Incorrect")], [#descriptive-cell(7, 1, "No response")], [#descriptive-cell(7, 1, "Correct RT")], [#descriptive-cell(7, 1, "Incorrect RT")],
      [], [Early change], [#descriptive-cell(7, 2, "Correct")], [#descriptive-cell(7, 2, "Incorrect")], [#descriptive-cell(7, 2, "No response")], [#descriptive-cell(7, 2, "Correct RT")], [#descriptive-cell(7, 2, "Incorrect RT")],
      [], [Late change], [#descriptive-cell(7, 3, "Correct")], [#descriptive-cell(7, 3, "Incorrect")], [#descriptive-cell(7, 3, "No response")], [#descriptive-cell(7, 3, "Correct RT")], [#descriptive-cell(7, 3, "Incorrect RT")],
      table.hline(stroke: 0.7pt),
    )
  ],
  kind: table,
  supplement: [Table],
  placement: top,
  scope: "parent",
  caption: [*Behavioural descriptive statistics*. Response values are participant-level mean percentages ± SD ($n = #sample-n("complete")$). Reaction-time values are mean milliseconds ± SD, with the number of participants contributing a finite mean in parentheses.],
)

#let rqa-table() = figure(
  text(size: 7.5pt)[
    #table(
      columns: (1.15fr, 0.85fr, 0.85fr, 0.85fr, 0.85fr, 0.85fr, 0.85fr, 0.95fr, 0.85fr),
      align: (left, center, center, center, center, center, center, center, center),
      inset: (x: 3pt, y: 3.5pt),
      stroke: none,
      table.header([*Statistic*], [*RR*], [*$L$*], [*DET*], [*ENTR*], [*TT*], [*LAM*], [*$V_"max"$*], [*DIV*]),
      table.hline(stroke: 0.7pt),
      [Memorized], [#rqa-descriptive-cell("RR", 1)], [#rqa-descriptive-cell("L", 1)], [#rqa-descriptive-cell("DET", 1)], [#rqa-descriptive-cell("ENTR", 1)], [#rqa-descriptive-cell("TT", 1)], [#rqa-descriptive-cell("LAM", 1)], [#rqa-descriptive-cell("V_max", 1)], [#rqa-descriptive-cell("DIV", 1)],
      [Early change], [#rqa-descriptive-cell("RR", 2)], [#rqa-descriptive-cell("L", 2)], [#rqa-descriptive-cell("DET", 2)], [#rqa-descriptive-cell("ENTR", 2)], [#rqa-descriptive-cell("TT", 2)], [#rqa-descriptive-cell("LAM", 2)], [#rqa-descriptive-cell("V_max", 2)], [#rqa-descriptive-cell("DIV", 2)],
      [Late change], [#rqa-descriptive-cell("RR", 3)], [#rqa-descriptive-cell("L", 3)], [#rqa-descriptive-cell("DET", 3)], [#rqa-descriptive-cell("ENTR", 3)], [#rqa-descriptive-cell("TT", 3)], [#rqa-descriptive-cell("LAM", 3)], [#rqa-descriptive-cell("V_max", 3)], [#rqa-descriptive-cell("DIV", 3)],
      table.hline(stroke: 0.35pt),
      [$F(2, #integer(rqa-stat("RR").df_error))$], [#number(rqa-stat("RR").F_statistic)], [#number(rqa-stat("L").F_statistic)], [#number(rqa-stat("DET").F_statistic)], [#number(rqa-stat("ENTR").F_statistic)], [#number(rqa-stat("TT").F_statistic)], [#number(rqa-stat("LAM").F_statistic)], [#number(rqa-stat("V_max").F_statistic)], [#number(rqa-stat("DIV").F_statistic)],
      [FDR-adjusted $p$], [#table-p(rqa-stat("RR").p_value_fdr_8way)], [#table-p(rqa-stat("L").p_value_fdr_8way)], [#table-p(rqa-stat("DET").p_value_fdr_8way)], [#table-p(rqa-stat("ENTR").p_value_fdr_8way)], [#table-p(rqa-stat("TT").p_value_fdr_8way)], [#table-p(rqa-stat("LAM").p_value_fdr_8way)], [#table-p(rqa-stat("V_max").p_value_fdr_8way)], [#table-p(rqa-stat("DIV").p_value_fdr_8way)],
      [Partial $eta^2$], [#number(rqa-stat("RR").partial_eta_squared, digits: 3)], [#number(rqa-stat("L").partial_eta_squared, digits: 3)], [#number(rqa-stat("DET").partial_eta_squared, digits: 3)], [#number(rqa-stat("ENTR").partial_eta_squared, digits: 3)], [#number(rqa-stat("TT").partial_eta_squared, digits: 3)], [#number(rqa-stat("LAM").partial_eta_squared, digits: 3)], [#number(rqa-stat("V_max").partial_eta_squared, digits: 3)], [#number(rqa-stat("DIV").partial_eta_squared, digits: 3)],
      table.hline(stroke: 0.7pt),
    )
  ],
  kind: table,
  supplement: [Table],
  placement: top,
  scope: "parent",
  caption: [*Recurrence quantification analysis (RQA) statistics by condition*. RR, recurrence rate; $L$, mean diagonal line length; DET, determinism; ENTR, diagonal-line entropy; TT, trapping time; LAM, laminarity; $V_"max"$, maximum vertical line length; DIV, divergence; SD, standard deviation; FDR, false-discovery rate. Descriptive values are participant-level means ± SD after averaging each metric across melody lengths for the #sample-n("rqa_complete") participants included in the cross-melody RQA analyses. Inferential rows report the main effect of condition.],
)
