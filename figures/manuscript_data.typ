#let sample-counts = csv("../output/statistics/sample_counts.csv", row-type: dictionary)
#let participant-summary = csv("../output/statistics/participant_summary.csv", row-type: dictionary)
#let behaviour-anova = csv("../output/statistics/behaviour_anova.csv", row-type: dictionary)
#let behaviour-descriptives = csv("../output/statistics/behaviour_descriptives.csv", row-type: dictionary)
#let behaviour-comparisons = csv("../output/statistics/behaviour_comparisons.csv", row-type: dictionary)
#let network-variance = csv("../output/statistics/network_variance.csv", row-type: dictionary)
#let rqa-anova = csv("../output/statistics/rqa_anova.csv", row-type: dictionary)
#let rqa-descriptives = csv("../output/statistics/rqa_descriptives.csv", row-type: dictionary)
#let rqa-models = csv("../output/statistics/rqa_behaviour_models.csv", row-type: dictionary)
#let rqa-by-length = csv("../output/5_rqa_correlations/by_length.csv", row-type: dictionary)
#let rqa-by-condition = csv("../output/5_rqa_correlations/by_condition.csv", row-type: dictionary)
#let activation-behaviour = csv("../output/statistics/activation_behaviour.csv", row-type: dictionary)
#let matched-rqa = csv("../output/statistics/matched_rqa_paper.csv", row-type: dictionary)
#let ridge-summary = csv("../output/statistics/ridge_summary.csv", row-type: dictionary)
#let ridge-stability = csv("../output/statistics/ridge_coefficient_stability.csv", row-type: dictionary)
#let threshold-anova = csv("../output/robustness/thresholds/rqa_threshold_anova.csv", row-type: dictionary)

#let number(value, digits: 2) = {
  str(calc.round(float(value), digits: digits))
}

#let fixed(value, digits: 3) = {
  let scale = calc.pow(10, digits)
  let rounded = int(calc.round(float(value) * scale))
  let value = str(calc.abs(rounded))
  while value.len() <= digits { value = "0" + value }
  let split = value.len() - digits
  (if rounded < 0 { "-" } else { "" }) + value.slice(0, split) + "." + value.slice(split)
}

#let integer(value) = str(calc.round(float(value)))

#let proportion(value) = number(float(value) * 100, digits: 1)

#let sample-n(analysis, melody: 0) = {
  int(sample-counts.find(row => row.analysis == analysis and int(row.melody_length) == melody).n)
}

#let participant(group) = participant-summary.find(row => row.group == group)

#let count-percent(count, n) = {
  [#integer(count) (#number(100 * float(count) / float(n), digits: 1)\%)]
}

#let age-cell(group) = {
  let row = participant(group)
  [#fixed(row.age_mean, digits: 1) ± #fixed(row.age_sd, digits: 1)]
}

#let age-range-cell(group) = {
  let row = participant(group)
  [#integer(row.age_min)--#integer(row.age_max)]
}

#let behaviour-stat(outcome, effect) = {
  behaviour-anova.find(row => row.outcome == outcome and row.effect == effect)
}

#let behaviour-desc(length, condition, measure) = {
  behaviour-descriptives.find(row => int(row.melody_length) == length and int(row.condition_index) == condition and row.measure == measure)
}

#let rqa-stat(metric, effect: "condition") = {
  rqa-anova.find(row => row.metric == metric and row.effect == effect)
}

#let rqa-desc(metric, condition) = {
  rqa-descriptives.find(row => row.metric == metric and int(row.condition_index) == condition)
}

#let matched-result(metric) = matched-rqa.find(row => row.metric == metric)
#let ridge-result = ridge-summary.at(0)
#let ridge-metric(metric) = ridge-stability.find(row => row.metric == metric)

#let threshold-stat(threshold, metric, effect: "condition") = {
  threshold-anova.find(row => float(row.threshold) == threshold and row.metric == metric and row.effect == effect)
}

#let variance(length) = {
  network-variance.find(row => int(row.melody_length) == length)
}

#let f-test(row) = {
  [$F(#integer(row.df_effect), #integer(row.df_error)) = #number(row.F_statistic)$]
}

#let eta-value(row) = {
  number(row.partial_eta_squared, digits: 3)
}

#let adjusted-p(row, column: "p_value_fdr") = {
  let value = float(row.at(column))
  if value < .001 { [$p < .001$] } else { [$p = #number(value, digits: 2)$] }
}

#let scientific(value, digits: 2) = {
  let value = float(value)
  if value == 0 { [0] } else {
    let exponent = calc.floor(calc.log(value, base: 10))
    let coefficient = calc.round(value / calc.pow(10, exponent), digits: digits - 1)
    [$#coefficient times 10^(#exponent)$]
  }
}

#let table-p(value) = {
  let value = float(value)
  if value >= .01 { number(value, digits: 2) } else { scientific(value) }
}

#let condition-label(index) = ("M", "Early change", "Late change").at(index - 1)

#let descriptive-cell(length, condition, measure) = {
  let row = behaviour-desc(length, condition, measure)
  if measure.ends-with("RT") {
    [#integer(row.mean) ± #integer(row.sd) (#row.n)]
  } else {
    [#proportion(row.mean) ± #proportion(row.sd)]
  }
}

#let rqa-descriptive-cell(metric, condition) = {
  let row = rqa-desc(metric, condition)
  [#number(row.mean, digits: 3) ± #number(row.sd, digits: 3)]
}

#let cluster-rows(melody, network) = {
  csv("../output/3_timeseries/cluster/significance_windows_" + melody + "_bn_" + str(network) + ".csv", row-type: dictionary)
}

#let cluster-range(melody, networks) = {
  let rows = networks.map(network => cluster-rows(melody, network)).flatten()
  let starts = rows.map(row => float(row.start))
  let ends = rows.map(row => float(row.end))
  (calc.min(..starts), calc.max(..ends))
}

#let line-metrics = ("L", "DET", "ENTR", "TT", "LAM", "V_max")

#let correlation-range(rows, outcome, include-div: false) = {
  let metrics = if include-div { ("DIV",) } else { line-metrics }
  let values = rows.filter(row => row.outcome == outcome and row.metric in metrics).map(row => float(row.r))
  (calc.min(..values), calc.max(..values))
}

#let correlation-p-max(rows, outcome, include-div: false) = {
  let metrics = if include-div { ("DIV",) } else { line-metrics }
  calc.max(..rows.filter(row => row.outcome == outcome and row.metric in metrics).map(row => float(row.p_value_fdr_8way)))
}

#let significant-activation-count(block, network, condition, outcome) = {
  activation-behaviour.filter(row => row.block == block and int(row.network_index) == network and int(row.condition_index) == condition and row.outcome == outcome and row.significant_fdr == "1").len()
}

#let correct-condition = behaviour-stat("Correct", "condition")
#let correct-length = behaviour-stat("Correct", "melody_length")
#let correct-interaction = behaviour-stat("Correct", "interaction")
#let incorrect-condition = behaviour-stat("Incorrect", "condition")
#let incorrect-interaction = behaviour-stat("Incorrect", "interaction")
#let no-response-tests = behaviour-anova.filter(row => row.outcome == "No response")
#let correct-rt-condition = behaviour-stat("Correct RT", "condition")
#let correct-rt-length = behaviour-stat("Correct RT", "melody_length")
#let correct-rt-interaction = behaviour-stat("Correct RT", "interaction")
#let incorrect-rt-length = behaviour-stat("Incorrect RT", "melody_length")
#let incorrect-rt-null = behaviour-anova.filter(row => row.outcome == "Incorrect RT" and row.effect != "melody_length")
#let rt-response-count = behaviour-comparisons.filter(row => row.comparison_family == "right_vs_wrong_within_cell" and row.significant_fdr_45way == "1").len()

#let m3-clusters = cluster-range("m3", (1, 2))
#let m5-clusters = cluster-range("m5", (1, 2))
#let m7-clusters = cluster-range("m7", (1, 2, 3))
#let rqa-interactions = rqa-anova.filter(row => row.effect == "condition_x_melody_length")
#let rqa-interactions-significant = rqa-interactions.filter(row => float(row.p_value_fdr_8way) < .05)
#let rqa-interactions-null = rqa-interactions.filter(row => float(row.p_value_fdr_8way) >= .05)

#let length-accuracy-lines = correlation-range(rqa-by-length, "accuracy")
#let length-accuracy-div = correlation-range(rqa-by-length, "accuracy", include-div: true)
#let condition-accuracy-lines = correlation-range(rqa-by-condition, "accuracy")
#let condition-accuracy-div = correlation-range(rqa-by-condition, "accuracy", include-div: true)
#let length-rt-lines = correlation-range(rqa-by-length, "mean_rt")
#let length-rt-div = correlation-range(rqa-by-length, "mean_rt", include-div: true)
