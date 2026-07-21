(* ====================================================== *)
(* Step 01: Symbolic analysis of the Gamma-based integrand *)
(* ====================================================== *)

ClearAll["Global`*"];

(* Original integrand *)
q[t_] := 1/Gamma[t] - 1;

(* 1. Verify the Gamma recurrence relation *)
gammaRecurrence = FullSimplify[
   Gamma[t + 1] == t Gamma[t],
   Assumptions -> t > 0
];

(* 2. Compute the right-hand limit at t = 0.
   The substitution t = 1/u ensures that t approaches
   zero through positive values as u approaches infinity. *)
qLimitAtZero = FullSimplify[
   Limit[1/Gamma[1/u] - 1, u -> Infinity]
];

(* 3. Series expansion near t = 0 *)
qSeriesAtZero = Series[
   1/Gamma[t] - 1,
   {t, 0, 3}
];

(* 4. Define the continuous extension of the integrand *)
qExtended[t_] := Piecewise[
   {
      {-1, t == 0}
   },
   1/Gamma[t] - 1
];

(* 5. Value of F at x = 0 *)
FAtZero = 1 + Integrate[
   qExtended[t],
   {t, 0, Sinh[0]}
];

(* 6. Display all symbolic results *)
Print["Gamma recurrence relation: ", gammaRecurrence];
Print["Right-hand limit of q(t) at zero: ", qLimitAtZero];
Print["Series of q(t) around zero: ", qSeriesAtZero];
Print["Continuous value q(0): ", qExtended[0]];
Print["Value F(0): ", FAtZero];