Set Implicit Arguments.
Set Asymmetric Patterns.
Require Import List.
Open Scope list_scope.

Inductive binop : Set :=
  Plus | Times | First | Second.

Inductive exp : Set :=
  | Const : nat -> exp
  | Binop : binop -> exp -> exp -> exp.
(* take a binary operation and 2 expressions and return one expression *)
Fixpoint frs (e1 : nat) (e2 : nat) : nat := e1.
Fixpoint snd (e1 : nat) (e2 : nat) : nat := e2.

Definition binopDenote := fun b =>
  match b with
  | Plus => plus
  | Times => mult
  | First => frs
  | Second => snd
  end.

Fixpoint expDenote ( e : exp) : nat :=
  match e with
  | Const n => n
  | Binop b e1 e2 => (binopDenote b) (expDenote e1) (expDenote e2)
  end.

Eval simpl in expDenote (Const 42).
Eval simpl in expDenote (Binop Plus (Const 2) (Const 3)).
Eval simpl in expDenote (Binop First (Binop Plus (Const 2) (Const 3)) (Binop Times (Const 2) (Const 3))).
Eval simpl in expDenote (Binop Second (Binop Plus (Const 2) (Const 3)) (Binop Times (Const 2) (Const 3))).

Inductive instr : Set :=
  | iConst : nat -> instr
  | iBinop : binop -> instr.
Definition prog := list instr.
Definition stack := list nat.

Definition instrDenote (i : instr) (s: stack) : option stack :=
  match i with
  | iConst n => Some (n :: s)
  | iBinop b =>
      match s with
      | (arg1 :: arg2 :: s') => Some ((binopDenote b) arg1 arg2 :: s')
      | _ => None
      end
  end.

Fixpoint progDenote (p : prog) (s : stack) : option stack :=
  match p with
  | nil => Some s
  | i :: p' =>
      match instrDenote i s with
      | None => None
      | Some s' => progDenote p' s'
      end
  end.
(* kinda cool how all binary instructions just generalize in the stack machine [they did not but now they do!] *)

Fixpoint compile (e : exp) : prog :=
  match e with
  | Const n => iConst n :: nil
  | Binop b e1 e2 => compile e2 ++ compile e1 ++ iBinop b :: nil
  end.

Eval simpl in compile (Const 42).
Eval simpl in progDenote (compile (Binop Times (Binop Second(Const 2) (Const 3)) (Const 7))).
(* yay! *)

Lemma compile_correct' : forall e p s, progDenote (compile e ++ p) s = progDenote p (expDenote e :: s).
induction e. intros. unfold compile. unfold expDenote. unfold progDenote at 1. simpl. fold progDenote. reflexivity.
intros. unfold compile. fold compile. unfold expDenote. fold expDenote. rewrite app_assoc_reverse. rewrite IHe2.
rewrite app_assoc_reverse. rewrite IHe1. unfold progDenote at 1. simpl. fold progDenote. reflexivity.
Qed.
Lemma nr : forall e, compile e = compile e ++ nil.
intros. rewrite app_nil_r. reflexivity.
Qed.
Theorem compile_correct : forall e, progDenote (compile e) nil = Some (expDenote e :: nil).
intros. rewrite nr. rewrite compile_correct'. reflexivity.
Qed.

