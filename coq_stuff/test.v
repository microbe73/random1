Fixpoint add (a b : nat) : nat :=
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

Fixpoint abs_minus (a b : nat) : nat :=
  match a with
  | 0 => b
  | S n => match b with
           | 0 => a
           | S m => ( abs_minus n m)
           end end.

Theorem abs_minus_assoc : forall (a b c : nat),
  (abs_minus a (abs_minus b c)) = (abs_minus (abs_minus a b) c).
Proof.
  intros a b c.
  induction a. simpl. reflexivity.
  simpl. 
