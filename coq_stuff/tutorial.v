Set Implicit Arguments.
Set Asymmetric Patterns.
Require Import List.
Require Import Bool.
Require Import Arith_base.
Open Scope list_scope.

Inductive binop : Set :=
  Plus | Times | First | Second.

Inductive exp : Set :=
  | Const : nat -> exp
  | Binop : binop -> exp -> exp -> exp.
(* take a binary operation and 2 expressions and return one expression *)
Definition frs (e1 : nat) (e2 : nat) : nat := e1.
Definition snd (e1 : nat) (e2 : nat) : nat := e2.

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


Fixpoint compile (e : exp) : prog :=
  match e with
  | Const n => iConst n :: nil
  | Binop b e1 e2 => compile e2 ++ compile e1 ++ iBinop b :: nil
  end.

Eval simpl in compile (Const 42).
Eval simpl in progDenote (compile (Binop Times (Binop Second(Const 2) (Const 3)) (Const 7))).


Lemma compile_correct' : forall e p s, progDenote (compile e ++ p) s =
  progDenote p (expDenote e :: s). induction e. intros. unfold compile. unfold
  expDenote. unfold progDenote at 1. simpl. fold progDenote. reflexivity.
  intros. unfold compile. fold compile. unfold expDenote. fold expDenote. rewrite
  app_assoc_reverse. rewrite IHe2. rewrite app_assoc_reverse. rewrite IHe1.
  unfold progDenote at 1. simpl. fold progDenote. reflexivity. Qed.
Lemma nr : forall e, compile e = compile e ++ nil.
intros. rewrite app_nil_r. reflexivity.
Qed.
Theorem compile_correct : forall e, progDenote (compile e) nil = Some (expDenote e :: nil).
intros. rewrite nr. rewrite compile_correct'. reflexivity.
Qed.



Inductive arith : Set :=
  | Nt : nat -> arith
  | Ad : arith -> arith -> arith
.
Fixpoint evaluate (a : arith) : option arith :=
  match a with
  | Nt n => Some (Nt n)
  | Ad n1 n2 =>
      let s1 := evaluate n1 in
      let s2 := evaluate n2 in
      match s1 with
      | Some (Nt new1) => match s2 with
                    | Some (Nt new2) => Some (Nt (plus new1 new2))
                    | _ => None
                           end
      | _ => None
      end
  end.
  (* let a be Nat n for case 1
     for case 2, open the definition and induct on (n1, n2). Base case is that they are both
     natural numbers then it is simple that we get a natural number. If they are both not natural numbers,
     then by the inductive hypothesis their evaluation is a natural number, so actually we are done.
   *)

Theorem reduces : forall e, exists n, evaluate e = Some (Nt n).
Proof.
  intros. unfold evaluate. case e. Abort.

Inductive term : Set :=
  | Nat : nat -> term
  | True : term
  | False : term
  | Add : term -> term -> term
  | And : term -> term -> term.

Definition my_and (t1 : term) (t2 : term) : option term :=
  match t1 with
  | True => match t2 with
              | True => Some True
              | False => Some False
              | _ => None  end
  | False => Some False
  | _ => None 
  end.
Fixpoint eval (t : term) : option term :=
  match t with
  | Nat n => Some (Nat n)
  | True => Some True
  | False => Some False
  | Add n1 n2 => let s1 := eval n1 in
      let s2 := eval n2 in
      match s1 with
      | Some (Nat new1) => match s2 with
                          |  Some (Nat new2) => Some (Nat (plus new1 new2))
                          | _ => None
                           end
      | _ => None
      end
  | And n1 n2 => let s1 := eval n1 in
      let s2 := eval n2 in
      my_and n1 n2
  end.

Inductive type_term : Set :=
  | Bool
  | Natural.
Fixpoint typecheck (t: term) : option type_term :=
  match t with
  | Nat n => Some Natural
  | True => Some Bool
  | False => Some Bool
  | Add n1 n2 => 
      let s1 := typecheck n1 in
      let s2 := typecheck n2 in
      match (s1, s2) with
      | (Some Natural, Some Natural) => Some Natural
      | _ => None
      end
  | And n1 n2 =>
      let s1 := typecheck n1 in
      let s2 := typecheck n2 in
      match (s1, s2) with
      | (Some Bool, Some Bool) => Some Bool
      | _ => None
      end
  end.

Eval simpl in typecheck (Add (Add (Nat 5) (Nat 7)) (True)).

Theorem type_sound : forall e, (exists a, typecheck e = Some a) -> 
  (exists b, eval e = Some b).
Proof.
  intros. Abort.

