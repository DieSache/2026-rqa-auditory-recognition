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

= #text(hyphenate: false)[Recurrent whole-brain trajectories predict auditory memory recognition beyond response magnitude]

#heading(level: 2)[
  K. F. Christensen,
  M. Klarlund,
  G. Fernandez-Rubio,
  M. Rosso,
  S. Streton,
  M. Schiassi,
  M. L. Kringelbach,
  P. Vuust,
  and
  L. Bonetti
  #footnote[Center for Music in the Brain, Department of Clinical Medicine, Aarhus University & The Royal Academy of Music, Aarhus/Aalborg, Denmark]<mib>
  #footnote[Centre for Eudaimonia and Human Flourishing, Linacre College, University of Oxford, Oxford, United Kingdom]<hedonia>
  #footnote[Department of Psychiatry, University of Oxford, Oxford, United Kingdom]<oxpsych>
  @corresponding,
  #hide[#footnote(
    numbering: (..nums) => [\*],
  )[Corresponding author: #link("leonardo.bonetti@psych.ox.ac.uk") (L.B.)]<corresponding>]#counter(footnote).update(n => n - 1)
]

*Abstract*: Understanding cognition requires explaining not only how strongly neural processes respond, but how distributed brain activity unfolds through time. Yet neural--behaviour relationships are still predominantly sought in response magnitude or timing. We tested whether the recurrent organization of whole-brain dynamics was associated with individual melody-recognition performance beyond RMS activation amplitude. Participants underwent magnetoencephalography while judging three-, five-, and seven-tone excerpts from a memorized Bach melody, presented unchanged or with a single early or late tone change. BROAD-NESS represented source-reconstructed activity as low-dimensional whole-brain trajectories, whose recurrent structure was quantified. Memorized melodies elicited more recurrent states together with longer, more deterministic, and more persistent recurrence structures, greater recurrence entropy and laminarity, and lower divergence than changed melodies. Crucially, participants with more structured recurrent dynamics were consistently more accurate and, less robustly, faster. Recurrence rate showed only isolated behavioural associations, indicating that performance was related more consistently to the temporal organization of returning states than to their frequency. Activation amplitude showed only sparse associations with behaviour after correction. After adjustment for condition, melody length, their interaction, and RMS activation amplitude, adding all eight RQA measures jointly increased marginal $R^2$ by #fixed(matched-result("all_eight").incremental_marginal_R2) and improved model fit ($chi^2(8) = #number(matched-result("all_eight").likelihood_ratio_chisq)$, $p < .001$). In nested participant-wise cross-validation, ridge-regularized RQA prediction reduced held-out RMSE by #fixed(ridge-result.RMSE_improvement_percent, digits: 2)% (participant-bootstrap 95% CI: #fixed(ridge-result.bootstrap_CI_low, digits: 2)%--#fixed(ridge-result.bootstrap_CI_high, digits: 2)%). By preserving the temporal geometry of the same neural activity, recurrent trajectory analysis revealed a broad brain--behaviour relationship that conventional magnitude analysis largely missed. These findings establish recurrent whole-brain organization as a powerful system-level account of cognitive performance.

#set page(columns: 2)

= Introduction

Human cognition depends on the ability to retain information from past experience and use it to interpret the present. Memory offers a particularly tractable model for investigating how brain activity supports this ability: an internal representation can be established, new information can be compared with it, and the success and speed of that comparison can be measured directly through behaviour. Recognition tasks therefore provide a controlled link between evolving neural activity, stored knowledge, and cognitive performance.

Auditory memory makes this link explicitly temporal. Recognizing a melody requires more than detecting its individual tones. Each sound must be integrated with the preceding sequence, evaluated against an internal representation, and used to constrain expectations about what should follow. A single changed tone can therefore alter the interpretation of the entire unfolding sequence. Because these operations develop continuously over time, auditory recognition is fundamentally a problem of neural dynamics: the state reached at one moment provides the context in which the next event is processed.

Most direct neural--behaviour research has approached this problem by asking whether performance varies with the magnitude or timing of a neural response. Evoked-response amplitudes and latencies have been related to auditory working-memory capacity, successful sound and melody recognition, and recognition precision @bidelman2021@mathias2016@pomper2023@chow2025. Oscillatory power has likewise been associated with auditory-memory accuracy, response speed, and behavioural benefits from selective attention @lim2015@beckers2025@tian2025. These studies establish that the strength and timing of neural responses contain behaviourally relevant information. However, measurements taken from individual responses or frequency bands do not directly describe how distributed activity is organized as a sequence unfolds.

To determine how frequently neural activity has been related to behaviour in other ways, we conducted a targeted, method-neutral screen of recent human electrophysiological studies. Among #literature-total studies that explicitly tested a neural measure against task performance, #magnitude-count (#literature-share(magnitude-count)%) used either evoked-response magnitude or timing or oscillatory magnitude (@tab:literature-method-summary). This predominance was present despite selecting studies specifically for a direct neural--behaviour test, rather than surveying electrophysiological methods in general. Response magnitude is therefore not merely historically common; it remains the principal variable through which neural activity is matched to memory, recognition, and learning performance.

Across the retained literature, relationships between neural activity and behaviour were overwhelmingly examined by reducing brain responses to quantities such as amplitude, timing, coupling strength, or representational discriminability. These approaches identify behaviourally relevant neural features, but they leave unresolved whether behaviour is related to the global temporal architecture formed as large-scale brain networks move through successive configurations. Only one retained investigation, our original BROAD-NESS study, related such temporal-state dynamics directly to behaviour, establishing the importance of this level of neural organization (@tab:literature-evidence-map).

A dynamical-systems framework makes this architecture accessible by representing simultaneously evolving neural processes as a trajectory through a multidimensional state space @gao2017@recanatesi2022. The central challenge is to obtain a representation compact enough to interpret while preserving the collective dynamics of the original system. Thibeault and colleagues provided a formal basis for this reduction: rapidly decreasing singular values allow high-dimensional nonlinear network dynamics to be expressed through a small number of collective variables, while broad classes of systems, including recurrent neural networks, admit exact reduction under defined conditions @thibeault2024. Dimensional reduction therefore need not discard the dynamics that make a complex system function; it can expose their macroscopic organization.

The reduced trajectory remains a complex object in its own right. Engelken and colleagues showed that recurrent neural-network dynamics can occupy an attractor far smaller than the ambient state space while retaining a rich organization of stable and unstable directions @engelken2023. Their full Lyapunov-spectrum analysis further demonstrated that trajectory stability, entropy rate, and attractor dimension capture distinct aspects of collective dynamics. Together, these findings establish why low-dimensional neural activity should be studied not only by the variance it contains, but by the structure of its evolution through time.

BROAD-NESS provides a whole-brain implementation of this principle: source-reconstructed electrophysiological activity is decomposed into low-dimensional broadband networks, and their joint activation is treated as an evolving trajectory @bonetti2025. Recurrence quantification analysis can then determine whether this trajectory repeatedly visits similar configurations, remains near particular states, reproduces earlier sequences, or rapidly diverges into new regions. Recurrence rate measures how often states return, while diagonal and vertical recurrence structures respectively capture repeated temporal sequences and persistence. Their length, regularity, and diversity therefore describe aspects of neural organization that are not reducible to activation amplitude. In the present study, recurrent organization is treated as the central neural phenomenon: melody-recognition performance is examined in relation to the structure of whole-brain dynamics rather than solely to the magnitude of neural activation.

This recently proposed framework is especially relevant to recognition based on learned auditory predictions. Once a melody has been memorized, each tone can confirm or violate a temporally structured representation. A matching continuation should permit ongoing neural processes to develop along a stable and repeatedly expressed trajectory. A changed tone instead introduces a prediction error that may redirect the joint neural state and reduce the recurrence of organized temporal structure. The central question addressed here is whether these recurrence properties consistently explain individual melody-recognition performance and provide information that activation amplitude does not.

We recorded MEG while participants judged three-, five-, and seven-tone excerpts taken from a memorized melody. Excerpts were either unchanged or contained a single tone change at an early or late sequence position. Source-reconstructed activity was decomposed with BROAD-NESS into orthogonal broadband networks, whose joint activation defined a low-dimensional state space for each melody length. We then quantified participant- and condition-specific trajectory recurrence and related it directly to recognition accuracy and response speed. In the same data, we tested activation amplitude against behaviour as a conventional account of the observed performance differences.

We predicted that memorized melodies would elicit more stable and structured recurrent trajectories than changed melodies. Across participants, stronger diagonal and vertical recurrence structure was expected to accompany higher accuracy and faster responses, whereas greater trajectory divergence was expected to accompany poorer performance. Recurrence rate was analysed separately to determine whether behaviour depended simply on how often neural states returned or, more specifically, on the temporal organization of those returns. By directly comparing recurrent dynamics with activation amplitude, the study tested whether melody recognition is better explained by how large-scale brain-network activity evolves than by how strongly individual networks are activated.

= Methods

== Participants

The study included #integer(participant("Overall").n) participants recruited in Denmark: #integer(participant("Danish").n) Danish participants and #integer(participant("Chinese").n) recently arrived Chinese immigrants, who were recruited as part of the study design. The sample comprised #integer(participant("Overall").female_n) female and #integer(participant("Overall").male_n) male participants. Among the #integer(participant("Overall").age_n) participants with available age data, mean age was #fixed(participant("Overall").age_mean, digits: 1) years ($"SD" = #fixed(participant("Overall").age_sd, digits: 1)$; range #integer(participant("Overall").age_min)--#integer(participant("Overall").age_max)); age was unavailable for #(int(participant("Overall").n) - int(participant("Overall").age_n)) participants. All participants were healthy and reported normal hearing (see @tab:participant-characteristics).

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

MEG preprocessing and source reconstruction were performed in MATLAB R2016b using MaxFilter 2.2.15, OSL 2017Sep06 (`osl-core` commit `cf79690`), SPM12 revision 6906, FSL 5.0.9, the bundled FieldTrip distribution, and custom LBPD routines. All analyses following BROAD-NESS network estimation were performed in MATLAB R2026a Update 5 using BROAD-NESS and custom scripts; Connectome Workbench 2.2.1 was used for cortical visualization. The experiment was presented in PsychoPy (version #highlight(fill: luma(92%))[XX.XX]). Analysis code and processed data will be available at #link("https://github.com/DieSache/2026-rqa-auditory-recognition") and \[ZENODO DATA REPOSITORY URL\], respectively.

= Results

== Experimental and Analytical Overview

Participants judged whether three-, five-, and seven-tone excerpts were memorized or contained a single early or late tone change (@stimulus). We first characterized response accuracy, errors, omissions, and reaction times. Source-reconstructed MEG activity was then decomposed separately for each melody length with BROAD-NESS, yielding low-dimensional network activation time series shared across conditions and participants. We compared these activation time series between memorized and changed melodies and reconstructed joint trajectories from the two, three, and three networks retained for M3, M5, and M7, respectively. Recurrence quantification analysis (RQA) was used to test whether the temporal organization of these trajectories differed between conditions and whether individual differences in recurrent dynamics were related to behavioural performance.

== Behavioural Performance Varied with Change Position

Correct-response proportions differed among memorized, early-change, and late-change melodies (#f-test(correct-condition), FDR-adjusted #adjusted-p(correct-condition), partial $eta^2 = #eta(correct-condition)$), varied with melody length (#f-test(correct-length), FDR-adjusted #adjusted-p(correct-length), partial $eta^2 = #eta(correct-length)$), and showed a condition-by-melody-length interaction (#f-test(correct-interaction), FDR-adjusted #adjusted-p(correct-interaction), partial $eta^2 = #eta(correct-interaction)$; @fig:behaviour-response-proportions). For M3 and M5, early changes produced more correct responses than both memorized and late-change melodies. For M7, late changes produced more correct responses than both memorized and early-change melodies. The complementary analysis of incorrect responses showed a condition effect (#f-test(incorrect-condition), FDR-adjusted #adjusted-p(incorrect-condition), partial $eta^2 = #eta(incorrect-condition)$) and a condition-by-melody-length interaction (#f-test(incorrect-interaction), FDR-adjusted #adjusted-p(incorrect-interaction), partial $eta^2 = #eta(incorrect-interaction)$). No-response proportions were comparatively stable: neither condition, melody length, nor their interaction was significant (all FDR-adjusted $p >= #number(calc.min(..no-response-tests.map(row => float(row.p_value_fdr))), digits: 2)$).

Reaction times for correct responses showed effects of condition (#f-test(correct-rt-condition), FDR-adjusted #adjusted-p(correct-rt-condition), partial $eta^2 = #eta(correct-rt-condition)$), melody length (#f-test(correct-rt-length), FDR-adjusted #adjusted-p(correct-rt-length), partial $eta^2 = #eta(correct-rt-length)$), and their interaction (#f-test(correct-rt-interaction), FDR-adjusted #adjusted-p(correct-rt-interaction), partial $eta^2 = #eta(correct-rt-interaction)$; @fig:behaviour-reaction-times). The large melody-length effect reflected the later completion of longer excerpts when reaction time was measured from excerpt onset. Within melody lengths, correct responses to early changes were faster than responses to late changes for M3, M5, and M7; early changes were also faster than memorized melodies for M5 and M7. Incorrect-response times increased with melody length (#f-test(incorrect-rt-length), FDR-adjusted #adjusted-p(incorrect-rt-length), partial $eta^2 = #eta(incorrect-rt-length)$), but showed no condition effect or interaction (both FDR-adjusted $p = #number(calc.max(..incorrect-rt-null.map(row => float(row.p_value_fdr))), digits: 2)$). Correct responses were faster than incorrect responses in #rt-response-count of the nine melody-length and condition combinations after correction for the displayed comparisons. The underlying behavioural descriptive statistics are reported in @tab:behavioural-descriptives.

#behavioural-table()<tab:behavioural-descriptives>

== Melody-Specific Low-Dimensional Network Dynamics

The first three BROAD-NESS components explained #number(variance(3).BN1, digits: 1)%, #number(variance(3).BN2, digits: 1)%, and #number(variance(3).BN3, digits: 1)% of the variance in M3; #number(variance(5).BN1, digits: 1)%, #number(variance(5).BN2, digits: 1)%, and #number(variance(5).BN3, digits: 1)% in M5; and #number(variance(7).BN1, digits: 1)%, #number(variance(7).BN2, digits: 1)%, and #number(variance(7).BN3, digits: 1)% in M7. The corresponding effective dimensionality was #integer(variance(3).effective_dimensionality) networks for M3, #integer(variance(5).effective_dimensionality) for M5, and #integer(variance(7).effective_dimensionality) for M7. Thus, despite differences in excerpt duration, the dominant source dynamics at each melody length were captured by a small number of distributed components.

The spatial organization of these components was broadly conserved across melody lengths. BN1, which explained most of the variance in every decomposition, was dominated by bilateral primary and secondary auditory cortices together with medial and posterior cingulate regions. BN2 retained bilateral auditory contributions but extended more strongly into memory- and prediction-related regions, including the hippocampal and inferior temporal cortices, insula, anterior cingulate cortex, and ventromedial prefrontal cortex. BN3 explained substantially less variance and showed a more heterogeneous temporal and frontotemporal distribution; it contributed to the effective state spaces for M5 and M7 but not M3. The reconstructed trajectories therefore described the joint evolution of a dominant auditory--cingulate network and additional medial temporal, insular, and prefrontal systems rather than anatomically unspecified dimensions.

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

== Activation Amplitude Did Not Adequately Account for Behaviour

Direct correlations between network activation amplitude and behaviour were sparse after correction across time (@fig:activation-behaviour-m3, @fig:activation-behaviour-m5, and @fig:activation-behaviour-m7). The clearest effect was a negative association between first-network activation and reaction time during late-change M3 trials, which survived FDR correction at #significant-activation-count("m3", 1, 3, "mean_rt") time points; #significant-activation-count("m3", 1, 3, "accuracy") samples in the same series were positively related to accuracy. Smaller M3 effects related early-change reaction time to BN1 and BN2 at #significant-activation-count("m3", 1, 2, "mean_rt") and #significant-activation-count("m3", 2, 2, "mean_rt") samples, respectively. For M5, #significant-activation-count("m5", 2, 3, "mean_rt") late-change samples in BN2 were related to reaction time. M7 effects were confined to memorized-trial reaction time in BN2 (#significant-activation-count("m7", 2, 1, "mean_rt") sample), memorized-trial accuracy and reaction time in BN3 (#significant-activation-count("m7", 3, 1, "accuracy") and #significant-activation-count("m7", 3, 1, "mean_rt") samples), and early-change accuracy in BN3 (#significant-activation-count("m7", 3, 2, "accuracy") samples). No corrected time points were detected in the remaining network-by-condition series. Activation amplitude therefore showed localized associations but did not provide the broad account of behavioural performance observed for recurrent dynamics.

The formally matched analysis provided a direct model comparison. After adjustment for the condition-by-melody-length interaction and RMS activation amplitude, adding the eight RQA measures jointly increased marginal $R^2$ by #fixed(matched-result("all_eight").incremental_marginal_R2) ($chi^2(8) = #number(matched-result("all_eight").likelihood_ratio_chisq)$, $p = #scientific(matched-result("all_eight").p_value)$). In nested participant-wise cross-validation, the ridge-regularized RQA model reduced held-out RMSE from #fixed(ridge-result.baseline_RMSE) to #fixed(ridge-result.ridge_RMSE), an improvement of #fixed(ridge-result.RMSE_improvement_percent, digits: 2)% (participant-bootstrap 95% CI: #fixed(ridge-result.bootstrap_CI_low, digits: 2)%--#fixed(ridge-result.bootstrap_CI_high, digits: 2)%; paired sign-flip $p = #scientific(ridge-result.paired_signflip_p)$). Prediction improved for #integer(ridge-result.participants_improved) of #integer(ridge-result.n_subjects) held-out participants. Thus, recurrent dynamics explained accuracy variation beyond whole-window RMS activation magnitude and improved prediction for unseen participants under regularization designed for the collinear RQA measures. The joint block test was the primary inference; descriptive metric-level mixed-model and ridge results are reported in @tab:matched-rqa.

= Discussion

Memory provides a controlled model for examining how evolving brain activity supports cognition: information is retained, incoming events are evaluated against it, and the quality of that evaluation is expressed in behaviour. Using melody recognition as a temporally structured instance of this process, the present study showed that behavioural performance was strongly related to the recurrent organization of large-scale network dynamics. Memorized melodies followed more structured trajectories than melodies containing a single changed tone, and participants with more organized recurrent dynamics were generally more accurate and faster. The relationship was statistically more robust for accuracy than for reaction time. In contrast, activation amplitude was inadequate for accounting for performance. Beyond the specific auditory-memory findings, this comparison demonstrates that preserving the temporal geometry of whole-brain activity can reveal behaviourally relevant information that is lost when the same data are reduced to activation magnitude. It therefore advances a different level of explanation for cognition: not how strongly individual neural processes respond, but how distributed activity develops and reorganizes over time.

The behavioural associations concerned the organization of recurrence more consistently than its frequency. Memorized melodies did show a modest increase in recurrence rate, indicating that their neural states returned more often, but RR had no corrected overall association with either behavioural outcome and only isolated aggregate associations. Across melody lengths and conditions, longer and more deterministic diagonal and vertical structures accompanied better performance, while greater divergence accompanied poorer performance. Successful recognition was therefore characterized not simply by more returns, but by returns that formed sustained and temporally ordered patterns. Diagonal-line entropy increased together with determinism and recurrent-line length, indicating that effective dynamics combined regularity with a diverse repertoire of structured temporal sequences rather than converging on a single rigid pattern.

This result extends a literature in which neural--behaviour relationships are still predominantly expressed through response magnitude. The amplitude of sustained auditory-memory responses has been related to the number of tones retained in short-term memory, while preparatory evoked activity has been associated with selective-listening accuracy @lefebvre2016@wostmann2015. Auditory-memory accuracy has also been related to alpha power, and reductions in P300 amplitude during distraction have been associated with slower responses @yu2017@cui2025. Sensory attenuation provides a further example: larger attenuation of self-initiated sounds accompanied poorer subsequent memory @paraskevoudi2023. Such findings demonstrate that response magnitude can contain behavioural information. However, the targeted review showed that magnitude or timing constituted the behavioural neural variable in 42 of 59 directly relevant studies (@tab:literature-method-summary). In the present data, applying this conventional approach to the activation of individual networks produced only sparse corrected associations. Recurrent trajectory measures, by contrast, were broadly related to performance. This is more than an incremental improvement in statistical sensitivity: it changes the object of neural--behaviour analysis from response magnitude at individual moments to the organization of an evolving whole-brain trajectory. The direct comparison shows that this change recovered behaviourally relevant structure that activation amplitude did not adequately capture in the same neural activity.

The findings also converge with studies moving beyond local response magnitude. Task-based functional connectivity has been used to predict normalized auditory digit-recall scores, and neural entrainment during statistical learning has been related to subsequent target-detection response time @pashkov2025@batterink2017. Intersubject synchronization during audiovisual narratives has predicted delayed recognition accuracy @cohen2016. Multivariate studies have further related successor representations to visual sequence-order accuracy and the differentiation of action representations to gains in correct-sequence typing speed @he2026@dash2025. Collectively, these studies indicate that cognition is supported by relationships among distributed neural processes and by representations expressed across time. The present approach takes a further step by integrating these dimensions into the temporal geometry of a joint whole-brain state. Rather than testing one connection or representation at a time, it quantifies the stability, persistence, complexity, and divergence of the network trajectory as a whole. Behaviour was associated with whether this trajectory repeatedly formed coherent temporal structures, providing a system-level account that cannot be obtained from the strength of an individual response, connection, or representation.

The condition differences provide a complementary interpretation in terms of memory-based prediction. Once the melody had been learned, an unchanged continuation could be processed within an established temporal context. A single changed tone was sufficient to reduce determinism, persistence, and recurrent-line length and to increase divergence, despite the remainder of the excerpt being drawn from the same memorized material. The changed tone may therefore redirect the joint neural state away from a trajectory supported by the learned sequence and require the system to reorganize around a prediction error. This interpretation is consistent with the recently proposed use of BROAD-NESS and recurrence analysis to characterize predictive processing in auditory-memory networks @bonetti2025. Here, the distinction between memorized and changed melodies was observed across melody lengths and was linked directly to individual recognition performance.

The anatomical composition of the trajectories clarifies what this reorganization involved. BN1 was the dominant component at every melody length and linked bilateral primary and secondary auditory cortices with medial and posterior cingulate regions. This configuration provides a large-scale substrate for representing incoming sounds while sustaining auditory processing and attention across successive tones. BN2 combined auditory cortex with the hippocampus, inferior temporal cortex, insula, anterior cingulate cortex, and ventromedial prefrontal cortex, bringing regions implicated in stored representations, salience, and memory-based prediction into the joint state. The recurrence findings therefore concern the coordinated evolution of anatomically meaningful sensory, cingulate, medial temporal, insular, and prefrontal systems. In particular, the prominence of BN1 indicates that successful recognition was scaffolded by a stable auditory--cingulate process whose evolving relationship with memory- and prediction-related systems formed the recurrent whole-brain trajectory.

The methodological contribution is therefore central to the study. Combining BROAD-NESS, phase-space reconstruction, and RQA turns high-dimensional electrophysiological activity into an interpretable account of how the whole-brain network state evolves. BROAD-NESS defines a compact set of broadband network axes, while their joint time series preserve participant- and condition-specific trajectories through the resulting state space. This follows a fundamental principle of complex-system dynamics: a small set of global observables can preserve the collective behaviour of a much larger nonlinear network, without reducing that behaviour to simple or independent processes @thibeault2024. RQA then quantifies whether these trajectories return to similar states in coherent sequences, persist around particular configurations, or diverge.

The distinction between activation amplitude and recurrent organization is equally fundamental. In recurrent-network theory, variance-based dimensionality and attractor dimensionality need not agree, and instability, dynamical entropy, and attractor dimension can vary independently rather than forming a single measure of dynamical complexity @engelken2023. The present results provide an empirical counterpart at the level of whole-brain electrophysiology: activation magnitude contained little consistent information about behaviour, whereas the temporal structure of the reduced trajectory was strongly associated with recognition performance. The framework avoids selecting individual anatomical regions, does not restrict distributed organization to pairwise coupling, and produces participant-level measures that can be related directly to behaviour. These measures are therefore not only descriptive; they explain meaningful individual variation that was largely absent from activation-amplitude analyses. This establishes recurrent whole-brain trajectory analysis as a powerful general strategy for studying the neural organization of cognition.

Several limitations motivate future work. Participant- and condition-level associations do not establish that trial-to-trial recurrence determines individual decisions. Although condition effects were broadly stable across the tested recurrence thresholds, the threshold, fixed windows, and data-driven, melody-specific dimensionalities remain analysis choices requiring further testing. Collinearity means that the matched analysis supports the joint RQA contribution, whereas individual coefficients and drop-one tests remain descriptive; ridge stabilization does not make individual metrics independently interpretable. Nested participant-wise cross-validation is not validation in an independent cohort. Finally, generalizability beyond the single memorized Bach passage requires study.

In conclusion, melody recognition was associated with the temporal organization of distributed brain-network activity. Memorized melodies elicited more deterministic, persistent, and richly structured recurrent trajectories than melodies containing a changed tone, and these properties accompanied both more accurate and faster performance, with the strongest evidence observed for accuracy. Activation amplitude did not provide a comparable account. By revealing a broad neural--behaviour relationship that conventional magnitude analysis largely missed, the study establishes recurrent whole-brain dynamics as an important framework for explaining cognitive performance. The approach offers a principled route from high-dimensional neural recordings to interpretable, behaviourally meaningful descriptions of how cognition unfolds through time.

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
#literature-supplement()

#pagebreak()
#include "figures/table_s5_threshold_sensitivity.typ"
