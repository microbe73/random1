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
Theorem trichotomy_2 : forall (a b : nat),
  gt a b = false -> gt b a = true \/ a = b.
Proof.
  intros a b. induction a. firstorder. destruct b. simpl. firstorder. simpl. firstorder.
  destruct b. simpl. discriminate. simpl.

Theorem gt_transitive : forall (a b c : nat), 
  gt a b = true /\ gt b c = true -> gt a c = true.
Proof.
  intros a b c. firstorder. induction c. destruct a. apply H. 
  simpl. reflexivity. destruct a. apply H. simpl. induction c. 
