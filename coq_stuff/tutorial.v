Set Implicit Arguments.
Set Asymmetric Patterns.

Inductive binop : Set :=
  Plus | Times.

Inductive exp : Set :=
  | Const : nat -> exp
  | Binop : binop -> exp -> exp -> exp 
  | First : exp -> exp -> exp
  | Second : exp -> exp -> exp.
(* take a binary operation and 2 expressions and return one expression *)

Definition binopDenote := fun b =>
  match b with
  | Plus => plus
  | Times => mult
  end.

Fixpoint expDenote ( e : exp) : nat :=
  match e with
  | Const n => n
  | Binop b e1 e2 => (binopDenote b) (expDenote e1) (expDenote e2)
  | First e1 e2 => expDenote(e1)
  | Second e1 e2 => expDenote(e2)
  end.

Eval simpl in expDenote (Const 42).
Eval simpl in expDenote (Binop Plus (Const 2) (Const 3)).
Eval simpl in expDenote (First (Binop Plus (Const 2) (Const 3)) (Binop Times (Const 2) (Const 3))).
Eval simpl in expDenote (Second (Binop Plus (Const 2) (Const 3)) (Binop Times (Const 2) (Const 3))).


