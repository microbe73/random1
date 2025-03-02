
(* The set of the group. *)
Section Group.
Variable G : Set.

(* The binary operator. *)
Variable f : G -> G -> G.

(* The group identity. *)
Variable e : G.

(* The inverse operator. *)
Variable i : G -> G.

(* For readability, we use infix <+> to stand for the binary operator. *)
Infix "<+>" := f (at level 50, left associativity).

(* The operator [f] is associative. *)
Variable assoc : forall a b c, a <+> b <+> c = a <+> (b <+> c).

(* [e] is the right-identity for all elements [a] *)
Variable id_r : forall a, a <+> e = a.

Variable id_l : forall a, e <+> a = a.
(* [i a] is the right-inverse of [a]. *)
Variable inv_r : forall a, a <+> i a = e.

Variable inv_l : forall a, i a <+> a = e.
Lemma mult_both_sides : forall a b c : G, a = b -> c <+> a = c <+> b.
Proof.
  intros. rewrite H. reflexivity.
Qed.

Lemma mult_both_sides' : forall a b c : G, a = b -> a <+> c = b <+> c.
Proof.
  intros. rewrite H. reflexivity.
Qed.
Theorem cancel_left : forall a b c : G, a <+> b = a <+> c -> b = c.
Proof.
  intros. apply mult_both_sides with (c := i a) in H.
  rewrite <- assoc in H. rewrite <- assoc in H.
  rewrite inv_l in H. rewrite id_l in H. rewrite id_l in H.
  apply H.
Qed.
Theorem cancel_right : forall a b c : G, b <+> a = c <+> a -> b = c.
Proof.
  intros. apply mult_both_sides' with (c := i a) in H.
  rewrite assoc in H. rewrite assoc in H.
  rewrite inv_r in H. rewrite id_r in H. rewrite id_r in H.
  apply H.
Qed.

Theorem id_unique : forall e1 : G, (forall d : G, e1 <+> d = d ->
  e1 = e).
Proof.
  intros. apply mult_both_sides' with (c := i d) in H.
  rewrite assoc in H. rewrite inv_r in H. rewrite id_r in H.
  apply H.
Qed.

End Group.
 

