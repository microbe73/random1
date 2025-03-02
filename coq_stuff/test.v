Require Import List.
Fixpoint add (a : nat) (b : nat) : nat :=
  match a with
  | 0 => b
  | S n => S (add n b)
  end.
Theorem add_assoc : forall (a b c : nat),
  (add a (add b c)) = (add (add a b) c).
Proof.
  intros a b c.
  induction a. simpl. reflexivity.
  simpl. rewrite -> IHa. reflexivity.
Qed.

Theorem add_0 : forall (a : nat ),
  (add a 0) = a.
Proof.
intros a. induction a. simpl. reflexivity.
simpl. rewrite -> IHa. reflexivity.
Qed.

Theorem add_1 : forall (b : nat ),
  (add b 1) = ( S b).
Proof.
  induction b. simpl. reflexivity.
  simpl. rewrite -> IHb. reflexivity.
Qed.
Theorem add_S : forall (a b : nat), 
  S (add b a) = (add b ( S a ) ).
Proof.
  intros a b. induction b. simpl.  reflexivity.
  simpl. rewrite -> IHb. reflexivity.
Qed.

Theorem add_refl : forall (a b : nat),
  (add a b) = (add b a).
Proof.
  intros a b. induction a. simpl. rewrite add_0. reflexivity.
  simpl. induction b. simpl. rewrite add_0. reflexivity.
  simpl. rewrite -> IHa. simpl. rewrite add_S. reflexivity.
Qed.



Fixpoint gt (a b : nat) : bool :=
  match a with
  | 0 => false
  | S n => match b with
           | 0 => true
           | S m => ( gt n m)
           end end.

Theorem preservative : forall (a b : nat),
  gt a b = true -> gt (S a) (S b) = true.
Proof.
  intros a b. induction b. firstorder. simpl.  firstorder.
Qed.
Theorem gt_0 : forall (a : nat),
  gt a 0 = false -> a = 0.
Proof.
  intros a. destruct a. simpl. reflexivity. simpl. firstorder. discriminate.
Qed.
Theorem preservative_2 : forall (a b : nat),
  gt a b = false -> gt (S a) (S b) = false.
Proof.
   intros a b. induction b. firstorder. simpl. firstorder.
Qed.
Theorem S_gt : forall (a b : nat),
  gt a b = gt (S a) (S b).
Proof.
  intros a b. induction b. simpl. reflexivity. simpl. reflexivity.
Qed.
Theorem add_gt : forall (a b c : nat),
  gt a b = gt (add c a) (add c b).
Proof.
  intros a b c. induction c. simpl. reflexivity. simpl. rewrite->IHc. reflexivity.
Qed.
Theorem trichotomy_0 : forall (b : nat),
  gt b b = false.
Proof.
  intro b. induction b. simpl. reflexivity. simpl. apply IHb.
Qed.
Theorem trichotomy_1 : forall (a b : nat),
  a = b -> gt a b = false /\ gt b a = false.
Proof.
  intros a b. firstorder. induction a. simpl. reflexivity. rewrite H. apply trichotomy_0.
  rewrite H. apply trichotomy_0.
Qed.

Fixpoint filter {X : Type} (l : list X) (test : X -> bool) : (list X) :=
  match l with
  | nil => nil
  | (x :: rest) => if test x then x :: (filter rest test) else (filter rest test)
  end.
Compute (minus 7 5).
Notation "A $ F" := (F A) (at level 80, right associativity).
(* kinda technically postfix notation *)
Compute (5 $ 7 $ plus).
Compute (7 $ (5 $ 1 $ plus) $ minus).
 
Notation "L ▽ T" := (filter L T) (at level 75, right associativity).
Definition is_0 (n : nat) : bool :=
  match n with
  | 0 => true
  | _ => false
  end.
Notation "[ x ; .. ; y ]" := (cons x .. (cons y nil) ..).
Compute ([ 0 ; 1 ; 2 ; 0 ; 3 ; 0 ; 1 ] ▽ is_0).
(*▽*)
