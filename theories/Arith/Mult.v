(***********************************************************************)
(*  v      *   The Coq Proof Assistant  /  The Coq Development Team    *)
(* <O___,, *        INRIA-Rocquencourt  &  LRI-CNRS-Orsay              *)
(*   \VV/  *************************************************************)
(*    //   *      This file is distributed under the terms of the      *)
(*         *       GNU Lesser General Public License Version 2.1       *)
(***********************************************************************)

(*i $Id$ i*)

Require Export Plus.
Require Export Minus.
Require Export Lt.
Require Export Le.

V7only [Import nat_scope.].
Open Local Scope nat_scope.

Implicit Variables Type m,n,p:nat.

(** Multiplication *)

Lemma mult_plus_distr : 
      (n,m,p:nat)((mult (plus n m) p)=(plus (mult n p) (mult m p))).
Proof.
Intros; Elim n; Simpl; Intros; Auto with arith.
Elim plus_assoc_l; Elim H; Auto with arith.
Qed.
Hints Resolve mult_plus_distr : arith v62.

Lemma mult_plus_distr_r : (n,m,p:nat) (mult n (plus m p))=(plus (mult n m) (mult n p)).
Proof.
  NewInduction n. Trivial.
  Intros. Simpl. Rewrite (IHn m p). Apply sym_eq. Apply plus_permute_2_in_4.
Qed.

Lemma mult_minus_distr : (n,m,p:nat)((mult (minus n m) p)=(minus (mult n p) (mult m p))).
Proof.
Intros; Pattern n m; Apply nat_double_ind; Simpl; Intros; Auto with arith.
Elim minus_plus_simpl; Auto with arith.
Qed.
Hints Resolve mult_minus_distr : arith v62.

Lemma mult_O_le : (n,m:nat)(m=O)\/(le n (mult m n)).
Proof.
NewInduction m; Simpl; Auto with arith.
Qed.
Hints Resolve mult_O_le : arith v62.

Lemma mult_assoc_r : (n,m,p:nat)((mult (mult n m) p) = (mult n (mult m p))).
Proof.
Intros; Elim n; Intros; Simpl; Auto with arith.
Rewrite mult_plus_distr.
Elim H; Auto with arith.
Qed.
Hints Resolve mult_assoc_r : arith v62.

Lemma mult_assoc_l : (n,m,p:nat)(mult n (mult m p)) = (mult (mult n m) p).
Proof.
Auto with arith.
Qed.
Hints Resolve mult_assoc_l : arith v62.

Lemma mult_1_n : (n:nat)(mult (S O) n)=n.
Proof.
Simpl; Auto with arith.
Qed.
Hints Resolve mult_1_n : arith v62.

Lemma mult_sym : (n,m:nat)(mult n m)=(mult m n).
Proof.
Intros; Elim n; Intros; Simpl; Auto with arith.
Elim mult_n_Sm.
Elim H; Apply plus_sym.
Qed.
Hints Resolve mult_sym : arith v62.

Lemma mult_n_1 : (n:nat)(mult n (S O))=n.
Proof.
Intro; Elim mult_sym; Auto with arith.
Qed.
Hints Resolve mult_n_1 : arith v62.

Lemma mult_le : (m,n,p:nat) (le n p) -> (le (mult m n) (mult m p)).
Proof.
  NewInduction m. Intros. Simpl. Apply le_n.
  Intros. Simpl. Apply le_plus_plus. Assumption.
  Apply IHm. Assumption.
Qed.
Hints Resolve mult_le : arith.

Lemma le_mult_right : (m,n,p:nat)(le m n)->(le (mult m p) (mult n p)).
Intros m n p H.
Rewrite mult_sym. Rewrite (mult_sym n).
Auto with arith.
Qed.

Lemma le_mult_mult :
  (m,n,p,q:nat)(le m n)->(le p q)->(le (mult m p) (mult n q)).
Proof.
Intros m n p q Hmn Hpq; NewInduction Hmn.
NewInduction Hpq.
(* m*p<=m*p *)
Apply le_n.
(* m*p<=m*m0 -> m*p<=m*(S m0) *)
Rewrite <- mult_n_Sm; Apply le_trans with (mult m m0).
Assumption.
Apply le_plus_l.
(* m*p<=m0*q -> m*p<=(S m0)*q *)
Simpl; Apply le_trans with (mult m0 q).
Assumption.
Apply le_plus_r.
Qed.

Lemma mult_lt : (m,n,p:nat) (lt n p) -> (lt (mult (S m) n) (mult (S m) p)).
Proof.
  NewInduction m. Intros. Simpl. Rewrite <- plus_n_O. Rewrite <- plus_n_O. Assumption.
  Intros. Exact (lt_plus_plus ? ? ? ? H (IHm ? ? H)).
Qed.

Hints Resolve mult_lt : arith.

Lemma lt_mult_right :
  (m,n,p:nat) (lt m n) -> (lt (0) p) -> (lt (mult m p) (mult n p)).
Intros m n p H H0.
Induction p.
Elim (lt_n_n ? H0).
Rewrite mult_sym.
Replace (mult n (S p)) with (mult (S p) n); Auto with arith.
Qed.

Theorem lt_mult_left :
 (x,y,z:nat) (lt x y) -> (lt (mult (S z) x) (mult (S z) y)).
Proof.
Intros x y z H;Elim z; [
  Simpl; Do 2 Rewrite <- plus_n_O; Assumption
| Simpl; Intros n H1; Apply lt_trans with m:=(plus y (plus x (mult n x))); [
    Rewrite (plus_sym x (plus x (mult n x)));
    Rewrite (plus_sym y (plus x (mult n x))); Apply lt_reg_l; Assumption
  | Apply lt_reg_l;Assumption ]].
Qed.

Lemma mult_le_conv_1 : (m,n,p:nat) (le (mult (S m) n) (mult (S m) p)) -> (le n p).
Proof.
  Intros. Elim (le_or_lt n p). Trivial.
  Intro H0. Cut (lt (mult (S m) n) (mult (S m) n)). Intro. Elim (lt_n_n ? H1).
  Apply le_lt_trans with m:=(mult (S m) p). Assumption.
  Apply mult_lt. Assumption.
Qed.

(** Tail-recursive mult *)

(** [tail_mult] is an alternative definition for [mult] which is 
    tail-recursive, whereas [mult] is not. This can be useful 
    when extracting programs. *)

Fixpoint mult_acc [s,m,n:nat] : nat := 
   Cases n of 
      O => s
      | (S p) => (mult_acc (tail_plus m s) m p)
    end.

Lemma mult_acc_aux : (n,s,m:nat)(plus s (mult n m))= (mult_acc s m n).
Proof.
Induction n; Simpl;Auto.
Intros p H s m; Rewrite <- plus_tail_plus; Rewrite <- H.
Rewrite <- plus_assoc_r; Apply (f_equal2 nat nat);Auto.
Rewrite plus_sym;Auto.
Qed.

Definition tail_mult := [n,m:nat](mult_acc O m n).

Lemma mult_tail_mult : (n,m:nat)(mult n m)=(tail_mult n m).
Proof.
Intros; Unfold tail_mult; Rewrite <- mult_acc_aux;Auto.
Qed.

(** [TailSimpl] transforms any [tail_plus] and [tail_mult] into [plus] 
    and [mult] and simplify *)

Tactic Definition TailSimpl := 
   Repeat Rewrite <- plus_tail_plus; 
   Repeat Rewrite <- mult_tail_mult; 
   Simpl. 
