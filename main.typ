#import "figures/manuscript_data.typ": *
#import "figures/literature.typ": *
#import "figures/stimulus.typ": stimulus-figure
#import "figures/tables.typ": behavioural-table, participant-table, rqa-table

#set text(font: "EB Garamond", lang: "en", hyphenate: true)
#set par(justify: true)
#set par.line(numbering: "1")
#set page(paper: "a4")

#show figure.caption: it => align(left)[
  #it.supplement#if it.numbering != none [#if it.kind != "supplementary" and it.kind != "supplementary-table" [ ]#counter(figure.where(kind: it.kind)).display(it.numbering)]#it.separator#it.body
]

#show ref: it => {
  let target = it.element
  if target != none and target.func() == figure and (target.kind == "supplementary" or target.kind == "supplementary-table") {
    let numbers = counter(figure.where(kind: target.kind)).at(target.location())
    [#target.supplement#numbering(target.numbering, ..numbers)]
  } else {
    it
  }
}

= #text(hyphenate: false)[Recurrent organization of low-structure whole-brain dynamics predicts auditory recognition performance beyond activation magnitude]

#heading(level: 2)[
  K. F. Christensen@mib,
  M. Klarlund@mib,
  G. Fernandez-Rubio@mib,
  M. Rosso@mib,
  S. Streton@mib,
  M. Schiassi@mib,
  M. L. Kringelbach@mib@hedonia@oxpsych,
  P. Vuust@mib,
  and
  L. Bonetti@mib@hedonia@oxpsych@corresponding
  #hide[#footnote[Center for Music in the Brain, Department of Clinical Medicine, Aarhus University & The Royal Academy of Music, Aarhus/Aalborg, Denmark]<mib>]
  #hide[#footnote[Centre for Eudaimonia and Human Flourishing, Linacre College, University of Oxford, Oxford, United Kingdom]<hedonia>]
  #hide[#footnote[Department of Psychiatry, University of Oxford, Oxford, United Kingdom]<oxpsych>]
  #hide[#footnote(
    numbering: (..nums) => [\*],
  )[Corresponding author: #link("leonardo.bonetti@psych.ox.ac.uk") (L.B.)]<corresponding>]#counter(footnote).update(n => n - 1)
]
#v(0.2cm)
*Abstract*: Understanding cognition requires explaining not only which neural processes are engaged, but how their relationships evolve through time. We tested whether the recurrent organization of low-dimensional whole-brain dynamics relates to auditory recognition behaviour beyond activation magnitude. After a brief learning phase, #integer(participant("Overall").n) participants underwent magnetoencephalography (MEG) while recognizing three-, five-, and seven-sound auditory sequences, presented unchanged or with a single early or late tone alteration. BROAD-NESS identified broadband latent networks from source-reconstructed activity and represented their joint activation as trajectories through a multidimensional state space; recurrence quantification analysis characterized their temporal organization. Memorized melodies elicited more recurrent states and longer, more deterministic and persistent recurrence structures, together with lower divergence, than changed melodies. Across participants, structured recurrence was consistently associated with higher accuracy and faster responses, whereas recurrence frequency showed no consistent behavioural association. After adjustment for condition, melody length, their interaction, and matched root-mean-square activation amplitude, recurrence measures increased marginal $R^2$ by #fixed(matched-result("all_eight").incremental_marginal_R2). Nested participant-wise cross-validation reduced held-out prediction error by #fixed(ridge-result.RMSE_improvement_percent, digits: 2)% (95% CI: #fixed(ridge-result.bootstrap_CI_low, digits: 2)%--#fixed(ridge-result.bootstrap_CI_high, digits: 2)%). These findings support a view of cognition in which performance depends critically on how low-dimensional neural processes jointly organize and evolve over time, beyond how strongly they are activated.

#set page(columns: 2)

= Introduction

A central challenge in cognitive neuroscience is to explain how distributed neural activity gives rise to behaviour. Neural processes unfold continuously and collectively, yet neural--behaviour relationships are commonly studied through the magnitude or timing of responses measured in individual regions, components, or frequency bands @bidelman2021@mathias2016@pomper2023@chow2025@lefebvre2016@lim2015@beckers2025@tian2025@yu2017@wostmann2015. These measures reveal when and how strongly particular processes are engaged, but they provide limited information about how distributed processes evolve together. If cognition emerges from coordinated neural dynamics, identifying which processes are active is only part of the explanation and their joint temporal organization may be equally or even more important.

The low-dimensional hypothesis for cognition formalizes this idea through two linked principles @bonetti2026perspective. First, coordinated whole-brain activity gives rise to a limited number of latent processes that can be recruited and reconfigured according to internal and external demands. Second, cognition depends on the interactions and changing relationships among these processes. Cognitive richness may therefore arise not from an unlimited number of independent neural dimensions, but from the ways in which a smaller set of processes combine, constrain one another, and reorganize over time. This account makes a specific prediction: cognitive performance should reflect not only the presence or activation strength of latent processes, but also the temporal organization produced by their joint evolution.

Several lines of research support parts of this account. More broadly, low-dimensional organization has emerged as a fundamental property of complex dynamical systems, whose apparently high-dimensional behaviour can often be captured by a much smaller set of interacting degrees of freedom @thibeault2024. In the brain, neural-manifold studies reveal low-dimensional trajectories, hidden-state analyses reveal recurring configurations and transitions between brain states, and dynamic-connectivity and latent-network models reveal reconfiguration at rest and during cognitive tasks @cunningham2014@gao2017@recanatesi2022@taghia2018@shine2019@gu2021@iyer2022@song2023@perl2025. Together, these findings indicate that brain activity is organized through a relatively small set of latent processes whose configurations and dynamics vary with cognitive context. What remains unresolved is what about this organization specifically matters for cognition and how it translates into behaviour. In particular, it is unclear whether behavioural performance primarily reflects the recruitment and activation strength of latent processes, or whether it also depends on the temporal organization that emerges as these processes evolve together. If their joint dynamics are consequential for cognition, this organization should explain individual cognitive performance beyond the activation strength of the latent processes themselves.

Despite growing evidence for low-dimensional neural organization, studies directly relating neural activity to behavioural performance have predominantly focused on more conventional measures of local response strength and timing. This is especially apparent in electrophysiological studies of memory and recognition. Evoked-response amplitudes and latencies have been related to auditory working-memory capacity, successful sound and melody recognition, and recognition precision, while oscillatory power has been associated with auditory-memory accuracy, response speed, and benefits from selective attention. In a targeted screen of #literature-total recent human electrophysiological studies directly relating a neural measure to memory, recognition, or sequence-learning performance, #literature-share(magnitude-count)% used evoked-response magnitude or timing or oscillatory magnitude (@tab:literature-method-summary; individual study classifications are reported in @tab:literature-evidence-map). These findings establish that response strength and timing are behaviourally relevant but leave unresolved whether cognitive performance is also supported by how distributed neural processes organize and evolve together over time.

Auditory sequence recognition provides a particularly stringent test of this possibility because successful recognition depends inherently on temporal integration: each sound must be interpreted in relation to what preceded it, compared with a learned representation, and used to constrain what should follow. MEG studies have traced how such sequences are encoded, recognized, reactivated, and mentally manipulated across time @fernandezrubio2026reactivation@fernandezrubio2026encoding@bonetti2025workingmemory@bonetti2025shared@bonetti2024concept@quirogamartinez2024. Related work has shown that recognition and prediction errors recruit distributed auditory, cingulate, medial temporal, and prefrontal systems whose contributions evolve across the sequence @bonetti2024aging@bonetti2024wholebrain@bonetti2024hierarchies@bonetti2023@fernandezrubio2022complex@fernandezrubio2022workingmemory. Combined with the temporal resolution of MEG, this paradigm makes it possible to follow whole-brain trajectories as recognition unfolds and to test whether their temporal organization is related to behavioural performance.

To this aim, participants evaluated three-, five-, and seven-tone excerpts extracted from a previously memorized musical piece, presented unchanged or with a single early or late tone alteration, while MEG was recorded. We analysed the source-reconstructed activity with the BROAD-NESS toolbox @bonetti2025, developed in the context of the NESS framework @rosso2025@malvaso2026@andersen2026, an integrated platform that identifies broadband latent networks and represents their simultaneous activation as trajectories through a multidimensional state space. Within this framework, recurrence quantification analysis characterized the returns, repeated sequences, persistence, and divergence of the trajectories. We asked whether recurrent organization differed between memorized and changed melodies, whether individual variation in this organization was associated with recognition accuracy and response speed, and whether it explained behaviour beyond the mere activation of the same latent processes. We predicted that memorized melodies would elicit more stable and structured trajectories, that stronger diagonal and vertical recurrence structure would accompany better performance, and that greater trajectory divergence would accompany poorer performance.

= Methods

== Participants

To increase the sample while broadening its cultural representation, we recruited #integer(participant("Overall").n) participants in Denmark: #integer(participant("Danish").n) Danish participants and #integer(participant("Chinese").n) recently arrived Chinese immigrants. The sample comprised #integer(participant("Overall").female_n) female and #integer(participant("Overall").male_n) male participants. Mean age was #fixed(participant("Overall").age_mean, digits: 1) years ($"SD" = #fixed(participant("Overall").age_sd, digits: 1)$; range #integer(participant("Overall").age_min)--#integer(participant("Overall").age_max)). All participants were healthy and reported normal hearing (see @tab:participant-characteristics).

The study was approved by the Institutional Review Board (IRB) of Aarhus University (case number: DNC-IRB-2023-009) and conducted in accordance with the Declaration of Helsinki -- Ethical Principles for Medical Research. All participants provided informed consent prior to the experiment and received #integer(participant("Overall").compensation_dkk) DKK for their participation.

#participant-table()<tab:participant-characteristics>

=== Data Inclusion and Missingness

Some melody-length blocks were excluded during MaxFilter processing because of data-quality problems. The retained samples therefore comprised #sample-n("retained", melody: 3) participants for three-tone melodies (M3), #sample-n("retained", melody: 5) for five-tone melodies (M5), and #sample-n("retained", melody: 7) for seven-tone melodies (M7). These block-specific sample sizes should not be interpreted as successive stages of participant exclusion. #(sample-n("initial") - sample-n("complete")) participants were missing only one of the three melody-length blocks: #(sample-n("initial") - sample-n("retained", melody: 3)) lacked M3, #(sample-n("initial") - sample-n("retained", melody: 5)) lacked M5, and #(sample-n("initial") - sample-n("retained", melody: 7)) lacked M7. Each of these participants still contributed data to analyses of the other two melody lengths. Consequently, analyses conducted separately by melody length used all #sample-n("retained", melody: 5)--#sample-n("retained", melody: 7) available participants, whereas cross-melody repeated-measures analyses were restricted to the #sample-n("complete") participants represented at all three melody lengths. Thus, the reduction to #sample-n("complete") reflects the requirement for a complete set of three blocks within each participant, rather than the loss of all data from those participants.

Trial-level quality exclusions were shared across the behavioural and neural analyses: 152 trials overlapping recorded bad-data segments and three trials lacking a corresponding MEG epoch were removed. Behavioural summaries retained correct, incorrect, and no-response trials after these exclusions. The condition-specific neural averages supplied to BROAD-NESS used only correct-response trials from the same retained set.

No participant had a recurrence rate of zero in any analysed condition. The RQA samples therefore matched the retained block samples: #sample-n("rqa", melody: 3) participants for M3, #sample-n("rqa", melody: 5) for M5, and #sample-n("rqa", melody: 7) for M7, representing #sample-n("initial") unique participants. Cross-melody RQA analyses included the #sample-n("rqa_complete") participants with all three blocks.

== Experimental Design

Participants completed an auditory recognition task during MEG recording. They first listened twice to the first four bars of the right-hand part of Johann Sebastian Bach's Prelude No. 2 in C Minor, BWV 847, and were instructed to memorize it. A 20-s rest period followed the learning phase. During recognition, participants heard excerpts containing three (M3), five (M5), or seven tones (M7) and judged whether each excerpt had been taken unchanged from the memorized piece (memorized; M) or contained a change.

Three memorized excerpts were used at each melody length and were each presented 12 times, giving 36 memorized trials per block. Changed excerpts were derived from the same musical material by replacing a single tone. The replacement occurred either relatively early or at the end of the excerpt: tone 2 or 3 in M3, tone 3 or 5 in M5, and tone 5 or 7 in M7, see @stimulus for a graphical representation of this. Variants of the replacement pitch served as stimulus exemplars and were pooled within change position. Each melody-length block therefore comprised 72 trials: 36 memorized, 18 early-change, and 18 late-change trials. Consecutive tones had an onset-to-onset interval of 350 ms.

#stimulus-figure()<stimulus>

The order of the three melody-length blocks was randomized across participants, and all memorized and changed trials were randomized together within each block. Before each block, participants were informed of the number of tones in the upcoming excerpts. They responded using one button for memorized and another for changed. Responses were accepted for 3.0 s in M3, 3.7 s in M5, and 4.5 s in M7, measured from excerpt onset. A trial on which no response was registered before the corresponding deadline was classified as a no-response trial. The task was presented using PsychoPy, and stimulus-onset triggers were sent to the MEG acquisition system.

== Behavioural Analysis

Responses were classified as correct when a memorized excerpt received a memorized response or a changed excerpt received a changed response. All other registered responses were classified as incorrect, while trials reaching the response deadline were classified as no responses. After applying the shared trial-quality mask, response proportions were calculated separately for every combination of participant, melody length, and condition. Reaction times were averaged separately for correct and incorrect responses within each melody-length and condition combination; no-response trials did not contribute to reaction-time means. A reaction-time mean was treated as missing when a participant made no registered response for that combination.

The proportions of correct, incorrect, and no responses were each submitted to a 3 × 3 repeated-measures analysis of variance (ANOVA), with condition (memorized, early change, and late change) and melody length (M3, M5, and M7) as within-participant factors. The same factorial design was applied separately to mean reaction times for correct and incorrect responses. These omnibus tests assessed the main effects of condition and melody length and their interaction. Omnibus $p$-values were FDR-corrected across the three effects within each response category, and effect sizes were expressed as partial $eta^2$.

Comparisons displayed by significance brackets in the behavioural figures were based on paired-samples $t$-tests of participant-level values. Only participants with finite values in both conditions contributed to a given reaction-time comparison. The resulting $p$-values were adjusted using FDR correction across the family of brackets displayed in the relevant figure. Adjusted significance was denoted by \* for $p < .05$, \*\* for $p < .01$, and \*\*\* for $p < .001$.

== Neural Data Acquisition

=== MEG Acquisition

MEG was recorded in a magnetically shielded room at Aarhus University Hospital using an Elekta Neuromag TRIUX system with 306 channels (204 planar gradiometers and 102 magnetometers). Data were acquired at 1000 Hz with an analogue passband of 0.1--330 Hz. Before recording, the participant's head shape and the locations of four head-position-indicator coils were registered relative to three anatomical landmarks using a Polhemus Fastrak 3D digitizer. The coils tracked head position continuously during acquisition and enabled subsequent movement correction. Bipolar electrooculography and electrocardiography channels recorded eye movements, blinks, and cardiac activity for artefact identification.

=== MRI Acquisition

Structural MRI was acquired on a CE-approved 3 T Siemens scanner at Aarhus University Hospital on a separate day from MEG. T1-weighted images were obtained using a fat-saturated MPRAGE sequence with 1 mm isotropic resolution, echo time 2.61 ms, repetition time 2300 ms, a reconstructed matrix of 256 × 256, echo spacing 7.6 ms, and bandwidth 290 Hz/pixel.

== MEG Preprocessing

Raw MEG recordings were first processed with MaxFilter (version 2.2.15). Signal-space separation and temporal signal-space separation were used to suppress external interference, with continuous movement compensation based on the head-position-indicator coils. During this step, data were downsampled from 1000 to 250 Hz and a correlation limit of 0.98 was used to separate the internal and external signal subspaces.

The data were converted to Statistical Parametric Mapping format and processed in MATLAB using the Oxford Centre for Human Brain Activity Software Library and custom LBPD routines, incorporating functionality from SPM, FieldTrip, and FSL. Continuous recordings were visually inspected for large artefacts. Independent component analysis was then used to identify ocular and cardiac components by their relation to the EOG and ECG channels and by their characteristic spatial patterns; confirmed artefactual components were removed before signal reconstruction.

The cleaned data were segmented from 100 ms before to 3400 ms after excerpt onset and baseline-corrected relative to the 100-ms prestimulus interval. Trials containing residual artefacts were marked as bad. Correct-response trials remaining after these quality exclusions were organized by melody length and as memorized, early-change, or late-change trials before trial averaging and source reconstruction.

== Source Reconstruction

Source activity was reconstructed with a linearly constrained minimum-variance beamformer. Individual MEG data were co-registered to the corresponding T1-weighted MRI using the digitized head shape, anatomical landmarks, and coil positions. A single-shell forward model was constructed on an 8-mm grid in standard space; when an individual anatomical scan was unavailable, the MNI152 T1 template was used. Lead fields were reduced to a single orientation at each location, and normalized beamformer weights were applied independently at every time point. Sensor covariance was estimated from trials pooled across the experimental conditions. This yielded condition-specific, trial-averaged time series at 3559 brain locations from -0.1 to 3.4 s.

== BROAD-NESS Network Estimation

Broadband brain networks were estimated from the source-reconstructed time series using the PCA implementation of BROAD-NESS. The decomposition was performed independently for M3, M5, and M7 so that the network structure at each melody length was estimated from its own retained participant sample. Within each melody length, source activity was first averaged across participants and across the three conditions. Principal component analysis was then applied to the resulting matrix of 3559 source time series. The components were ordered by explained variance and their signs were oriented so that the source with the largest absolute loading had a positive weight.

The group-level component weights defined the spatial pattern of each network. Participant- and condition-specific activation time series were then reconstructed by projecting each participant's original source activity onto these common weights. Thus, all participants and conditions within a melody length were represented in the same component space, while retaining their individual temporal dynamics.

To estimate the number of relevant brain networks captured by the decomposition, we computed the effective dimensionality (ED) of the eigenspectrum using the participation ratio:

$
"ED" =
round(
  (sum_i lambda_i)^2
  /
  sum_i(lambda_i^2)
)
$

where $lambda_i$ is the variance explained by the $i$-th component. ED summarizes how many components contribute materially to the eigenspectrum without imposing an arbitrary cumulative-variance threshold.@gao2017@recanatesi2022 ED was two for M3 and three for both M5 and M7. Effective dimensionality was calculated directly from each decomposition at analysis time and determined the components used for phase-space reconstruction and matched RMS amplitude. The first three components were retained for the activation time-series overview and activation--behaviour control analysis at every melody length.

== Activation Time-Series Analysis

For each network and melody length, participant-level activation time series were compared between memorized and early-change trials and between memorized and late-change trials. At each time point, the within-participant condition difference was assessed with a two-sided paired-samples $t$-statistic. Temporally adjacent samples exceeding the two-sided cluster-forming threshold of $p < .05$ were grouped into clusters, and cluster mass was defined as the sum of the absolute $t$-statistics within the cluster.

Statistical significance was assessed with 2000 sign-flip permutations. On each permutation, the sign of the complete condition-difference time series was reversed for a random subset of participants, preserving its temporal dependence, and the largest cluster mass was retained. Observed clusters were compared with this maximum-statistic null distribution and considered significant at $p < .05$. As a complementary analysis, pointwise paired tests were corrected across time using FDR correction; these results are reported in the Supplementary Materials.

== Recurrence Quantification Analysis

The joint dynamics of the BROAD-NESS networks retained by effective dimensionality were characterized using phase-space reconstruction and recurrence quantification analysis (RQA). For each participant and condition, the activation time series of the retained components were treated as orthogonal axes of the state space. The reconstruction was therefore two-dimensional for M3 and three-dimensional for M5 and M7. Each sample represented the system's network state at one time point. Analyses began at stimulus onset and extended until 800 ms after the final tone onset, giving windows of 0--1.5 s for M3, 0--2.2 s for M5, and 0--2.9 s for M7.

For every pair of time points, Euclidean distance was calculated between their phase-space coordinates. A pair was classified as recurrent when its distance was below 10% of the maximum distance observed for that participant and condition. Diagonal and vertical lines were required to contain at least two samples. Eight standard RQA measures were extracted: recurrence rate (RR), the proportion of recurrent points; mean diagonal line length ($L$), reflecting temporal predictability; determinism (DET), the proportion of recurrent points forming diagonal lines; diagonal-line entropy (ENTR), reflecting the diversity of diagonal durations; trapping time (TT), the mean vertical line length; laminarity (LAM), the proportion of recurrent points forming vertical lines; maximum vertical line length ($V_max$), the longest period of state persistence; and divergence (DIV), the inverse of the longest diagonal line.

RQA metrics were calculated independently for each participant, melody length, and condition. Participants with RR equal to zero in any condition were excluded from all RQA analyses because their trajectories contained no recurrence points.

== RQA Statistical Analysis

Each RQA metric was analysed with a 3 × 3 repeated-measures ANOVA containing condition and melody length as within-participant factors. These models tested the main effects of condition and melody length and their interaction. FDR correction was applied across the eight RQA metrics separately for each omnibus effect. Partial $eta^2$ was used as the omnibus effect-size measure.

Follow-up analyses included paired comparisons among the three conditions, condition comparisons performed separately within each melody length, and the linear change from M3 to M7. Additional one-factor repeated-measures ANOVAs assessed melody-length effects within each condition. Paired tests used only participants with finite values for both observations and were summarized with Cohen's $d_z$. Cross-melody analyses used complete cases across all observations entering the relevant model.

A sensitivity analysis repeated the RQA calculations at 5%, 7.5%, 12.5%, and 15% of the participant- and condition-specific maximum distance, using the same exclusion rule and inferential models; the prespecified 10% analysis remained primary.

== RQA-Behaviour Associations

Associations between network dynamics and behavioural performance were assessed with two-sided Pearson correlations between each RQA metric and either response accuracy or mean reaction time across registered responses; no-response trials were excluded from the reaction-time means. Correlations were first calculated separately for each melody-length and condition combination. To characterize broader patterns, values were also averaged within participant across melody lengths for each condition and across conditions for each melody length before correlation. For each comparison and behavioural outcome, FDR correction was applied across the eight RQA metrics.

As an additional repeated-measures analysis, mixed models tested the overall RQA--behaviour association and whether this association varied by condition or melody length. Each behavioural outcome was modelled from condition, melody length, their interaction, the standardized RQA value, the RQA-by-condition interaction, and the RQA-by-melody-length interaction, with a random intercept for participant. Degrees of freedom were estimated using the Satterthwaite approximation. For each model term and behavioural outcome, FDR correction was applied across the eight RQA metrics.

== Activation-Behaviour Control Analysis

To test whether network activation amplitude adequately accounted for behavioural performance, activation was correlated across participants with accuracy and mean reaction time across registered responses at every time point, separately for each of the first three networks, melody length, and condition. All three networks were evaluated at every melody length so that the activation control used a common dimensional scope independent of the effective dimensionality selected for RQA. Pearson correlations were tested two-sided, and FDR correction was applied across all time points within each network-by-condition-by-outcome series.

For a formally matched test, activation magnitude was summarized as the root-mean-square (RMS) amplitude across the same retained components and time interval used for RQA in each participant, melody length, and condition. Accuracy was modelled from condition, melody length, their interaction, and standardized RMS activation amplitude, with a random intercept for participant. The primary inferential test compared this RMS-amplitude-adjusted model with a model additionally containing all eight standardized RQA measures, using maximum-likelihood estimation and an eight-degree-of-freedom likelihood-ratio test. Incremental marginal $R^2$ quantified model fit. Metric-level coefficients and one-degree-of-freedom drop-one tests were treated as descriptive because of collinearity among the RQA measures, with FDR correction across the eight tests.

Predictive generalization was evaluated with nested participant-wise ridge regression. The outer cross-validation left one participant out, and three-fold participant-grouped cross-validation within each outer training set selected the ridge penalty from 29 logarithmically spaced values between $10^2$ and $10^(-5)$. Condition, melody length, their interaction, and RMS activation amplitude were unpenalized; only the eight RQA measures were regularized. Continuous predictors were standardized using parameters estimated within the relevant training fold. Prediction uncertainty was quantified by 10,000 participant-level bootstrap resamples of the paired outer-fold errors, and a two-sided paired sign-flip test used 100,000 permutations.

== Software and Reproducibility

MEG preprocessing and source reconstruction were performed in MATLAB R2016b using MaxFilter 2.2.15, OSL 2017Sep06 (`osl-core` commit `cf79690`), SPM12 revision 6906, FSL 5.0.9, the bundled FieldTrip distribution, and custom LBPD routines. All analyses following BROAD-NESS network estimation were performed in MATLAB R2026a Update 5 using BROAD-NESS and custom scripts; Connectome Workbench 2.2.1 was used for cortical visualization. The experiment was presented using PsychoPy. The code is available at the following link: #link("https://github.com/DieSache/2026-rqa-auditory-recognition"). The multimodal neuroimaging data will be provided upon reasonable request.

= Results

== Experimental and Analytical Overview

Participants judged whether three-, five-, and seven-tone excerpts were memorized or contained a single early or late tone change (@stimulus). We first characterized response accuracy, errors, omissions, and reaction times. Source-reconstructed MEG activity was then decomposed separately for each melody length with BROAD-NESS, yielding low-dimensional network activation time series shared across conditions and participants. We compared these activation time series between memorized and changed melodies and reconstructed joint trajectories from the two, three, and three networks retained for M3, M5, and M7, respectively. Recurrence quantification analysis (RQA) was used to test whether the temporal organization of these trajectories differed between conditions and whether individual differences in recurrent dynamics were related to behavioural performance.

== Behavioural Performance Varied with Change Position

Correct-response proportions differed among memorized, early-change, and late-change melodies (#f-test(correct-condition), FDR-adjusted #adjusted-p(correct-condition), partial $eta^2 = #eta-value(correct-condition)$), varied with melody length (#f-test(correct-length), FDR-adjusted #adjusted-p(correct-length), partial $eta^2 = #eta-value(correct-length)$), and showed a condition-by-melody-length interaction (#f-test(correct-interaction), FDR-adjusted #adjusted-p(correct-interaction), partial $eta^2 = #eta-value(correct-interaction)$; @fig:behaviour-response-proportions). Aggregate response proportions are shown in @fig:behaviour-response-proportions-stacked. For M3 and M5, early changes produced more correct responses than both memorized and late-change melodies. For M7, late changes produced more correct responses than both memorized and early-change melodies. The complementary analysis of incorrect responses showed a condition effect (#f-test(incorrect-condition), FDR-adjusted #adjusted-p(incorrect-condition), partial $eta^2 = #eta-value(incorrect-condition)$) and a condition-by-melody-length interaction (#f-test(incorrect-interaction), FDR-adjusted #adjusted-p(incorrect-interaction), partial $eta^2 = #eta-value(incorrect-interaction)$). No-response proportions were comparatively stable: neither condition, melody length, nor their interaction was significant (all FDR-adjusted $p >= #number(calc.min(..no-response-tests.map(row => float(row.p_value_fdr))), digits: 2)$).

Reaction times for correct responses showed effects of condition (#f-test(correct-rt-condition), FDR-adjusted #adjusted-p(correct-rt-condition), partial $eta^2 = #eta-value(correct-rt-condition)$), melody length (#f-test(correct-rt-length), FDR-adjusted #adjusted-p(correct-rt-length), partial $eta^2 = #eta-value(correct-rt-length)$), and their interaction (#f-test(correct-rt-interaction), FDR-adjusted #adjusted-p(correct-rt-interaction), partial $eta^2 = #eta-value(correct-rt-interaction)$; @fig:behaviour-reaction-times). The large melody-length effect reflected the later completion of longer excerpts when reaction time was measured from excerpt onset. Within melody lengths, correct responses to early changes were faster than responses to late changes for M3, M5, and M7; early changes were also faster than memorized melodies for M5 and M7. Only 17 participants had finite incorrect-response reaction-time means in all nine condition-by-melody-length combinations; the incorrect-response RT ANOVA was therefore based on these 17 complete cases. Incorrect-response times increased with melody length (#f-test(incorrect-rt-length), FDR-adjusted #adjusted-p(incorrect-rt-length), partial $eta^2 = #eta-value(incorrect-rt-length)$), but showed no condition effect or interaction (both FDR-adjusted $p = #number(calc.max(..incorrect-rt-null.map(row => float(row.p_value_fdr))), digits: 2)$). Correct responses were faster than incorrect responses in #rt-response-count of the nine melody-length and condition combinations after correction for the displayed comparisons. The underlying behavioural descriptive statistics are reported in @tab:behavioural-descriptives.

#behavioural-table()<tab:behavioural-descriptives>

== Melody-Specific Low-Dimensional Network Dynamics

The first three BROAD-NESS components explained #number(variance(3).BN1, digits: 1)%, #number(variance(3).BN2, digits: 1)%, and #number(variance(3).BN3, digits: 1)% of the variance in M3; #number(variance(5).BN1, digits: 1)%, #number(variance(5).BN2, digits: 1)%, and #number(variance(5).BN3, digits: 1)% in M5; and #number(variance(7).BN1, digits: 1)%, #number(variance(7).BN2, digits: 1)%, and #number(variance(7).BN3, digits: 1)% in M7. The corresponding effective dimensionality was #integer(variance(3).effective_dimensionality) networks for M3, #integer(variance(5).effective_dimensionality) for M5, and #integer(variance(7).effective_dimensionality) for M7. Thus, despite differences in excerpt duration, the dominant source dynamics at each melody length were captured by a small number of distributed components.

Although BROAD-NESS was performed independently for each melody length, the resulting components showed qualitatively similar spatial patterns. The first component in each decomposition, which explained most of the variance, was dominated by bilateral primary and secondary auditory cortices together with medial and posterior cingulate regions. The second components retained bilateral auditory contributions but extended more strongly into memory- and prediction-related regions, including the hippocampal and inferior temporal cortices, insula, anterior cingulate cortex, and ventromedial prefrontal cortex. The third components explained substantially less variance and showed more heterogeneous temporal and frontotemporal distributions; they contributed to the effective state spaces for M5 and M7 but not M3. Across melody lengths, the reconstructed trajectories therefore described the joint evolution of decomposition-specific components encompassing dominant auditory--cingulate activity and additional medial temporal, insular, and prefrontal systems rather than anatomically unspecified dimensions.

Memorized and changed melodies followed overlapping activation time courses but diverged during discrete periods (@fig:activation-time-series). Cluster-corrected differences were present in the first two networks at all three melody lengths. For M3, these differences spanned #number(m3-clusters.at(0), digits: 2) to #number(m3-clusters.at(1), digits: 2) s; M5 showed several intervals between #number(m5-clusters.at(0), digits: 2) and #number(m5-clusters.at(1), digits: 2) s. M7 differences extended from #number(m7-clusters.at(0), digits: 2) to #number(m7-clusters.at(1), digits: 2) s across the retained networks. No significant clusters were detected in the third network for M3 or M5. Exact cluster-corrected intervals are reported in @tab:activation-significant-intervals. Pointwise FDR-corrected comparisons are shown in @fig:activation-time-series-fdr.

== Memorized Melodies Followed More Structured Recurrent Trajectories

The geometry of the joint network trajectories differed consistently between memorized and changed melodies (@fig:rqa-condition-distributions; descriptive and inferential statistics in @tab:rqa-descriptives). Condition affected all eight RQA metrics. Relative to both early- and late-change melodies, memorized melodies had a higher recurrence rate, longer diagonal and vertical structures, greater determinism, entropy, and laminarity, and lower divergence. The recurrence-rate effect was smaller than the effects for line structure (partial $eta^2 = #number(rqa-stat("RR").partial_eta_squared, digits: 3)$ versus #number(calc.min(..line-metrics.map(metric => float(rqa-stat(metric).partial_eta_squared))), digits: 3)$--#number(calc.max(..line-metrics.map(metric => float(rqa-stat(metric).partial_eta_squared))), digits: 3)$). Activity evoked by memorized melodies therefore returned more often to earlier states and, more prominently, formed longer, more persistent, and more predictable recurrence structures.

Condition effects were broadly stable across thresholds: six structural metrics remained significant from 5% to 15%, while $L$ missed significance specifically at 5% and RR at 15% (full sensitivity results in @tab:rqa-threshold-sensitivity).

All eight RQA metrics varied with melody length (all FDR-adjusted $p <= #number(calc.max(..rqa-anova.filter(row => row.effect == "melody_length").map(row => float(row.p_value_fdr_8way))), digits: 3)$). Recurrence rate and all line-structure measures were highest for M3, whereas divergence was lowest for M3 and highest for M5. These melody-length effects describe trajectories reconstructed using the effective dimensionality of each decomposition and therefore reflect both excerpt-specific dynamics and the corresponding two-, three-, and three-dimensional state spaces. Condition-by-melody-length interactions survived correction for $L$, DET, ENTR, TT, and LAM (all FDR-adjusted $p <= #number(calc.max(..rqa-interactions-significant.map(row => float(row.p_value_fdr_8way))), digits: 3)$), but not for RR, $V_max$, or DIV (all FDR-adjusted $p >= #number(calc.min(..rqa-interactions-null.map(row => float(row.p_value_fdr_8way))), digits: 3)$). The memorized-versus-change distinction was present in the pooled condition contrasts for every metric, but its magnitude varied with melody length for several aspects of line structure. Condition-by-melody and melody-length distributions are provided in @fig:rqa-condition-length-distributions and @fig:rqa-length-distributions.

#rqa-table()<tab:rqa-descriptives>

== Recurrent Organization Was Related to Behaviour

Participants with more structured recurrent trajectories tended to perform more accurately and respond more quickly (@fig:rqa-behaviour-correlations). When values were averaged within melody length, accuracy correlated positively with the line-based RQA metrics across all three lengths ($r = #number(length-accuracy-lines.at(0), digits: 3)$--$#number(length-accuracy-lines.at(1), digits: 3)$, all FDR-adjusted $p <= #number(correlation-p-max(rqa-by-length, "accuracy"), digits: 3)$) and negatively with divergence ($r = #number(length-accuracy-div.at(0), digits: 3)$ to $#number(length-accuracy-div.at(1), digits: 3)$, all FDR-adjusted $p <= #number(correlation-p-max(rqa-by-length, "accuracy", include-div: true), digits: 3)$). The same pattern was present when values were averaged within condition: for memorized, early-change, and late-change melodies, accuracy increased with all line-based metrics ($r = #number(condition-accuracy-lines.at(0), digits: 3)$--$#number(condition-accuracy-lines.at(1), digits: 3)$, all FDR-adjusted $p <= #number(correlation-p-max(rqa-by-condition, "accuracy"), digits: 3)$) and decreased with divergence ($r = #number(condition-accuracy-div.at(0), digits: 3)$ to $#number(condition-accuracy-div.at(1), digits: 3)$, all FDR-adjusted $p <= #number(correlation-p-max(rqa-by-condition, "accuracy", include-div: true), digits: 3)$).

Reaction-time associations had the complementary direction. Within melody lengths, greater line structure was related to faster responses ($r = #number(length-rt-lines.at(0), digits: 3)$ to $#number(length-rt-lines.at(1), digits: 3)$, all FDR-adjusted $p <= #number(correlation-p-max(rqa-by-length, "mean_rt"), digits: 3)$), whereas greater divergence was related to slower responses ($r = #number(length-rt-div.at(0), digits: 3)$--$#number(length-rt-div.at(1), digits: 3)$, all FDR-adjusted $p <= #number(correlation-p-max(rqa-by-length, "mean_rt", include-div: true), digits: 3)$). Across condition averages, all line-based associations survived correction for memorized, early-change, and late-change melodies (all FDR-adjusted $p <= #number(correlation-p-max(rqa-by-condition, "mean_rt"), digits: 3)$). Divergence was related to slower responses for memorized melodies ($r = #number(rqa-by-condition.find(row => row.condition_family == "old" and row.metric == "DIV" and row.outcome == "mean_rt").r, digits: 3)$, FDR-adjusted $p = #number(rqa-by-condition.find(row => row.condition_family == "old" and row.metric == "DIV" and row.outcome == "mean_rt").p_value_fdr_8way, digits: 3)$), but narrowly missed correction for both change conditions. Recurrence rate showed no consistent relationship with either behavioural outcome. Condition-specific correlations are reported in @fig:rqa-condition-correlations-1 and @fig:rqa-condition-correlations-2.

In repeated-measures mixed models, the overall RQA slope survived FDR correction for accuracy for every RQA metric except RR. For reaction time, the overall slopes for $L$ and TT also survived correction; no RQA interaction term survived correction. Because these models account for repeated observations but do not separate within- and between-participant RQA variation, the behavioural associations were clearest and most extensive for accuracy, while the reaction-time pattern was supported by both the aggregate correlations and the two corrected overall slopes.

== Recurrent Dynamics Explained Accuracy Beyond Matched RMS Activation Amplitude

Direct correlations between network activation amplitude and behaviour were sparse after correction across time (@fig:activation-behaviour-m3, @fig:activation-behaviour-m5, and @fig:activation-behaviour-m7). The clearest effect was a negative association between first-network activation and reaction time during late-change M3 trials, which survived FDR correction at #significant-activation-count("m3", 1, 3, "mean_rt") time points; #significant-activation-count("m3", 1, 3, "accuracy") samples in the same series were positively related to accuracy. Smaller M3 effects related early-change reaction time to BN1 and BN2 at #significant-activation-count("m3", 1, 2, "mean_rt") and #significant-activation-count("m3", 2, 2, "mean_rt") samples, respectively. For M5, #significant-activation-count("m5", 2, 3, "mean_rt") late-change samples in BN2 were related to reaction time. M7 effects were confined to memorized-trial reaction time in BN2 (#significant-activation-count("m7", 2, 1, "mean_rt") sample), memorized-trial accuracy and reaction time in BN3 (#significant-activation-count("m7", 3, 1, "accuracy") and #significant-activation-count("m7", 3, 1, "mean_rt") samples), and early-change accuracy in BN3 (#significant-activation-count("m7", 3, 2, "accuracy") samples). No corrected time points were detected in the remaining network-by-condition series. Activation amplitude therefore showed localized associations but did not provide the broad account of behavioural performance observed for recurrent dynamics.

The formally matched analysis provided a direct model comparison. After adjustment for the condition-by-melody-length interaction and RMS activation amplitude, adding the eight RQA measures jointly increased marginal $R^2$ by #fixed(matched-result("all_eight").incremental_marginal_R2) ($chi^2(8) = #number(matched-result("all_eight").likelihood_ratio_chisq)$, $p = #scientific(matched-result("all_eight").p_value)$). In nested participant-wise cross-validation, the ridge-regularized RQA model reduced held-out RMSE from #fixed(ridge-result.baseline_RMSE) to #fixed(ridge-result.ridge_RMSE), an improvement of #fixed(ridge-result.RMSE_improvement_percent, digits: 2)% (participant-bootstrap 95% CI: #fixed(ridge-result.bootstrap_CI_low, digits: 2)%--#fixed(ridge-result.bootstrap_CI_high, digits: 2)%; paired sign-flip $p = #scientific(ridge-result.paired_signflip_p)$). Prediction improved for #integer(ridge-result.participants_improved) of #integer(ridge-result.n_subjects) held-out participants. Thus, recurrent dynamics explained accuracy variation beyond whole-window RMS activation magnitude and improved prediction for held-out participants under regularization designed for the collinear RQA measures. The joint block test was the primary inference; descriptive metric-level mixed-model and ridge results are reported in @tab:matched-rqa.

= Discussion

The present study asked whether cognitive performance is related not only to the activation of low-dimensional neural processes, but also to the temporal organization that emerges from their joint evolution. Three findings provide convergent support for this account. First, memorized melodies elicited more structured recurrent trajectories than melodies containing a single changed tone. Second, participants whose trajectories showed stronger recurrent organization were generally more accurate and faster. Third, these dynamics accounted for variation in accuracy beyond the root-mean-square (RMS) activation amplitude of the same latent processes and improved prediction for held-out participants. Together, the results indicate that behaviour is related to how distributed neural activity is organized over time, beyond what can be learned from its overall response magnitude alone.

The distinction between the frequency and organization of recurrence is central to this conclusion. Memorized melodies produced a modest increase in recurrence rate, showing that their neural trajectories returned more often to previously occupied regions of state space. Recurrence rate, however, showed no consistent corrected association with behaviour. Performance was instead related to the structure of those returns. Participants who performed better exhibited longer and more deterministic diagonal patterns, greater vertical persistence and laminarity, and lower divergence. Diagonal-line entropy also increased alongside determinism and line length, suggesting that effective trajectories were neither random nor confined to one rigid sequence, but contained a varied repertoire of temporally ordered returns. Thus, the behaviourally relevant property was not simply how often the system revisited a state, but whether those returns formed sustained and coherent temporal structures.

This result does not imply that activation magnitude is unimportant. Evoked-response amplitude, oscillatory power, and response timing have repeatedly been associated with auditory memory and recognition @lefebvre2016@wostmann2015@yu2017@cui2025@paraskevoudi2023@albouy2022@borderie2024@kausel2024, and the present activation time series contained some localized behavioural associations. The more specific conclusion is that activation magnitude did not provide a sufficient account of the present data. In the formally matched comparison, adding the eight RQA measures to a model containing condition, melody length, their interaction, and RMS activation amplitude increased marginal variance explained by #fixed(matched-result("all_eight").incremental_marginal_R2). The regularized model also reduced held-out prediction error by #fixed(ridge-result.RMSE_improvement_percent, digits: 2)%. Because the RQA measures were strongly collinear, this evidence applies to their joint contribution rather than to any single metric considered independently. Nevertheless, both the model comparison and participant-wise cross-validation show that recurrent organization contained information about accuracy that was not captured by matched whole-window RMS amplitude.

These findings are consistent with the two linked principles of the low-dimensional hypothesis for cognition @bonetti2026perspective. The source-reconstructed MEG activity was dominated by a small number of latent networks, while individual behaviour was associated with the organization of their joint trajectory. The second observation is critical because low dimensionality alone does not explain cognition: a compact set of processes may be present across participants and conditions while differing substantially in how it evolves. Low dimensionality and dynamical organization therefore describe complementary aspects of neural activity: the former constrains the set of processes through which distributed activity is expressed, whereas the latter captures how those processes combine and reorganize through time @song2023@perl2025. Within the integrated BROAD-NESS framework @bonetti2025, this distinction can be examined directly because the latent networks define the principal processes organizing whole-brain activity while their simultaneous evolution defines the trajectory of the system. The present findings suggest that the cognitive relevance of low-dimensional organization lies not only in reducing neural activity to a compact set of processes, but critically in the repertoire of temporal relationships that can emerge among them. In this view, cognitive performance might not simply depend on which latent processes are recruited or how strongly they are activated, but on how their relationships are dynamically organized as cognition unfolds.

This interpretation also complements previous work relating behaviour to functional connectivity, neural entrainment, intersubject synchronization, and multivariate representations @pashkov2025@batterink2017@cohen2016@he2026@dash2025@wu2022@staudigl2019@crivellidecker2018. Those studies established that distributed relationships and temporally expressed representations can carry behaviourally relevant information. The present contribution is to show that the temporal organization emerging from the joint evolution of low-dimensional whole-brain processes is directly related to individual cognitive performance and carries behaviourally relevant information beyond their activation magnitude.

Melody recognition is particularly informative in this respect because every tone is interpreted in the context established by the preceding sequence. An unchanged continuation can remain compatible with a learned temporal structure, whereas an altered tone changes that context and may redirect the system into a different region of its joint state space. Consistent with this interpretation, a single changed tone was associated with shorter and less deterministic recurrence structures, reduced persistence, and greater divergence. MEG makes this rapidly unfolding organization accessible at the timescale of the sequence. Because RQA summarized an extended analysis window, however, the present results do not localize the recurrent reorganization to the precise moment of the altered tone. The prediction-error interpretation is therefore plausible and consistent with the BROAD-NESS account of auditory predictive processing @bonetti2025, but it remains to be tested directly with time-resolved or event-specific trajectory analyses.

The spatial patterns of the latent networks provide a tentative anatomical context for these dynamics. Across melody lengths, the dominant components showed qualitatively similar contributions from bilateral auditory and cingulate areas, while additional components included medial temporal, insular, and prefrontal regions. The recurrent trajectories therefore summarized coordinated activity across systems relevant to auditory processing, memory, salience, and prediction rather than fluctuations in an isolated region, consistent with our previous findings in a similar experimental scenario @bonetti2025.

Several limitations should be acknowledged to contextualize the current results and define directions for future work. Neural trajectories were derived from condition averages of correct-response trials, and the behavioural associations therefore capture between-participant relationships between performance and the dynamics expressed during successful recognition, rather than trial-level predictors of individual responses. Extending the framework to single-trial trajectories will be important for determining whether recurrent organization predicts recognition success from trial to trial and how such organization develops around behaviourally relevant events. Similarly, the observational design establishes robust associations between joint neural dynamics and behaviour but does not determine whether these dynamics play a causal role in performance, an important question for future experimental and perturbational studies. Strong collinearity among RQA measures was very much expected and does not represent a problem in itself, but further means that their behavioural contribution is most appropriately interpreted as evidence for recurrent organization as a whole rather than for unique effects of individual metrics. Nested participant-wise cross-validation demonstrated that this organization improved prediction in held-out participants within the present cohort, providing evidence that the behavioural relationship extends beyond in-sample model fit; however, validation in independent cohorts is called to provide the next, even stronger test of its generalizability. Finally, the sample included Danish and Chinese participants living in Denmark, offering an opportunity for future work to examine whether cultural or experiential background shapes low-dimensional neural dynamics and their relationship to cognition. Despite its relevance often being overlooked, we advocate for the importance of replication across independent cohorts, stimulus sets, and cognitive domains, together with trial-resolved and temporally localized analyses, to establish how broadly the present strong principles generalize.

In conclusion, melody recognition was associated with the recurrent temporal organization of low-dimensional whole-brain activity. More structured dynamics accompanied better performance and explained behavioural variation beyond matched activation magnitude. These findings suggest that the cognitive significance of low-dimensional neural organization lies not only in which processes are engaged or how strongly, but in how their relationships evolve over time. Understanding cognition may therefore require explaining both the processes that organize distributed neural activity and the dynamics that emerge from their joint evolution.

#set page(columns: 1)
#pagebreak()
#include "figures/2_behavioural_response_distributions.typ"

#pagebreak()
#include "figures/3_activation_timeseries_cluster.typ"

#pagebreak()
#include "figures/4_rqa_distributions_by_condition.typ"

#pagebreak()
#include "figures/5_rqa_behaviour_correlations.typ"

#pagebreak()
#set page(columns: 2, flipped: false, margin: auto)

#bibliography("bibliography.yaml", style: "nature")

#set page(columns: 1)
== Supplementary materials

#set figure(kind: "supplementary", supplement: [Figure S], numbering: "1")

#literature-supplement()

#pagebreak()
#include "figures/s1_behavioural_response_proportions.typ"
#pagebreak()
#include "figures/s2_reaction_times.typ"
#pagebreak()
#include "figures/s3_activation_timeseries_fdr.typ"
#pagebreak()
#include "figures/table_s1_activation_significant_intervals.typ"
#pagebreak()
#include "figures/s4_rqa_condition_length_distributions.typ"
#pagebreak()
#include "figures/s5_s7_activation_behaviour_correlations.typ"
#pagebreak()
#include "figures/s8_s9_rqa_cell_correlations.typ"
#pagebreak()
#include "figures/s10_rqa_distributions_by_length.typ"

#pagebreak()
#include "figures/table_s2_matched_rqa.typ"

#pagebreak()
#include "figures/table_s5_threshold_sensitivity.typ"
