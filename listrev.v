Require Import Toy.UnifySL.implementation.
Require Import Toy.Imp.
Require Import Toy.Language.
Require Import Toy.Embeddings.
Require Import Toy.BasicRules.
Require Import Coq.Lists.List.
Import T.
Import Denote_Aexp Denote_Bexp Denote_Com.
Import Assertion_Shallow AssertionDerivationRules.
Import Validity tacticforOSA.
Import implementation.
Import BasicRulesSound.

Definition w : var := 1%nat.
Definition v : var := 2%nat.
Definition t : var := 3%nat.
Definition p : var := 4%nat.

Definition initialization : com :=
  CSeq (CAss_load w (ANum 0)) (CAss_load v (AId p)).

Definition loopcontrol : com :=
  CIf (BEq (AId v) (ANum 0)) CBreak CSkip.
  
Definition loopbody1 : com :=
  CAss_load t (ADeref (APlus (AId v) (ANum 1))).

Definition loopbody2 : com :=
  CAss_store (APlus (AId v) (ANum 1)) (AId w).

Definition loopbody3 : com := 
  CAss_load w (AId v).

Definition loopbody4 : com :=
  CAss_load v (AId t).

Definition loop : com :=
  CFor CSkip (CSeq loopcontrol (CSeq loopbody1 (CSeq loopbody2 
    (CSeq loopbody3 loopbody4)))).

Definition listrev : com :=
  CSeq initialization loop.

Fixpoint listrep (p : Z) (l : list Z) : Assertion :=
  match l with
    | nil => fun st => p = 0
    | cons x l' => sepcon (sepcon (mapsto p x) (exp (fun q => andp (mapsto (p + 1) q) (listrep q l')))) truep
  end.

Definition precon (p : Z) (l : list Z) : Assertion := listrep p l.
Definition postcon (w : Z) (l : list Z) : Assertion := listrep w (rev l).

Theorem listrev_spec : forall l x y,
  valid (andp (eqp (AId p) x) (listrep x l)) listrev 
    (andp (eqp (AId w) y) (listrep y (rev l))) falsep falsep.
Proof.
  unfold valid. intros.
  split.
  { unfold not; intros.
    simpl in *.
  
