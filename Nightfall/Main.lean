import Nightfall.Targets
import ActualSourceQ2107Terminal
import InfinitePiQ2Limit
import InfinitePiQ2SourceHilbertTensor
import InfinitePiQ2AllL2LabelIntertwining
import InfinitePiQ2RangeProjectionTransfer
import InfinitePiQ2UnconditionalTerminal
import Q2ShiftedConditionalTargets

/-!
# Integrated Q2 import checkpoint

This single Lean module forces the selected original finite-source proof,
the original infinite-product L² limit, scoped genuine heat-bath tensor bridges, and the conditional shifted targets
and true-label all-L² source heat-bath operator equality to compile in one dependency environment.

This shared graph also imports the unconditional infinite-product a.e. L²
C105.416 theorem; its hypothesis is the triple-original-source-residual
operator condition. Its equivalence to a chosen ANOVA degree definition
remains an independent statement-review obligation.
The theorem audit below prints axioms for ACTUAL imported declarations; no
hypothesis is discharged by printing an axiom list.
-/

#check Nightfall.Targets.finiteProductQ2_107
#check Nightfall.Observability.ActualSourceQ2107Terminal.actual_source_q2_107_unconditional
#check Nightfall.InfinitePiQ2Limit.source_q2_quadratic_limit
#check Nightfall.Q2Shifted.ConditionalTargets.conditional_coefficient_107
#check Nightfall.Q2Shifted.ConditionalTargets.conditional_coefficient_99

-- Original-product coordinate/complement independence and true L² tensor projection.
-- These are scoped source bridges, not the unconditional infinite-product Q2 terminal.
#check Nightfall.InfinitePiQ2OriginalIndependence.source_coordinate_other_indepFun
#check Nightfall.InfinitePiQ2ConditionalSourceTest.source_condExp_coordinate_test
#check Nightfall.InfinitePiQ2ConditionalSourceTest.source_condExp_coordinate_mul_other
#check Nightfall.InfinitePiQ2SourceHilbertTensor.sourceOtherProjection_tensor_ae

#print axioms Nightfall.Observability.ActualSourceQ2107Terminal.actual_source_q2_107_unconditional
#print axioms Nightfall.InfinitePiQ2Limit.source_q2_quadratic_limit
#print axioms Nightfall.Q2Shifted.ConditionalTargets.conditional_coefficient_107
#print axioms Nightfall.Q2Shifted.ConditionalTargets.conditional_coefficient_99

#print axioms Nightfall.InfinitePiQ2OriginalIndependence.source_coordinate_other_indepFun
#print axioms Nightfall.InfinitePiQ2ConditionalSourceTest.source_condExp_coordinate_test
#print axioms Nightfall.InfinitePiQ2ConditionalSourceTest.source_condExp_coordinate_mul_other
#print axioms Nightfall.InfinitePiQ2SourceHilbertTensor.sourceOtherProjection_tensor_ae

-- Genuine source/label L² operator equality and reusable Hilbert commutation.
#check Nightfall.InfinitePiQ2AllL2LabelIntertwining.sourceOtherProjectionCLM_intertwines_all_L2
#check Nightfall.InfinitePiQ2RangeProjectionTransfer.labelRangeProjection_commutes
#check Nightfall.InfinitePiQ2RangeProjectionTransfer.labelRangeProjection_triple_zero

#print axioms Nightfall.InfinitePiQ2AllL2LabelIntertwining.sourceOtherProjectionCLM_intertwines_all_L2
#print axioms Nightfall.InfinitePiQ2RangeProjectionTransfer.labelRangeProjection_commutes
#print axioms Nightfall.InfinitePiQ2RangeProjectionTransfer.labelRangeProjection_triple_zero

-- Genuinely unconditional infinite-product terminal on arbitrary-universe original products.
#check Nightfall.InfinitePiQ2UnconditionalTerminal.infinitePi_q2_105416_ae
#print axioms Nightfall.InfinitePiQ2UnconditionalTerminal.infinitePi_q2_105416_ae
