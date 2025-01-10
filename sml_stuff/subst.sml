structure Subst : sig

  val fv : AST.term -> VarSet.set
  val sub : string * AST.term * AST.term -> AST.term

end = struct

  structure V = VarSet
  structure A = AST
  fun fv start_term =
  let fun fv_2_term (t : A.term * A.term) : V.set =
    let
      val t1 = fvg (#1(t))
      val t2 = fvg (#2(t))
    in
      V.union (t1, t2)
    end
    and fv_list t =
      (case t
         of [] => V.empty
          | (t :: rest) => V.union (fvg t, fv_list rest)
      )
    and fvg term =
    (case term
       of A.Var s => V.ins(s, V.empty)
        | A.Lam (x, typ, t1) => V.rem(x, fv t1)
        | A.Add (t1, t2) => fv_2_term (t1, t2)
        | A.And (t1, t2) => fv_2_term (t1, t2)
        | A.Sub (t1, t2) => fv_2_term (t1, t2)
        | A.Or(t1, t2) => fv_2_term (t1, t2)
        | A.Mul (t1, t2) => fv_2_term (t1, t2)
        | A.Div (t1, t2) => fv_2_term (t1, t2)
        | A.Concat(t1, t2) => fv_2_term (t1, t2)
        | A.Comp(t1, t2) => fv_2_term (t1, t2)
        | A.Lt(t1, t2) => fv_2_term (t1, t2)
        | A.Gt(t1, t2) => fv_2_term (t1, t2)
        | A.App (t1, t2) => fv_2_term (t1, t2)
        | A.If (t1, t2, t3) => V.union (fvg t1, V.union (fvg t2, fvg t3))
        | A.Head (t1) => fvg t1
        | A.List lst => fv_list lst
        | _ => V.empty
    )
  in
    fvg start_term
  end
  val inc = ref 0
  fun new_var () =
    let
      val x = !(inc)
      val _ = inc := !(inc) + 1
    in
      "A" ^ Int.toString(x)
    end
  fun sub (x : (string * A.term * A.term)) : A.term =
    let fun subst (xt2term : (string * A.term * A.term)) : A.term =
    let
      val x = #1(xt2term)
      val t2 = #2(xt2term)
      val term = #3(xt2term)
    in
      (case term
        of A.Var s => if s = x then t2 else term
          | A.Lam (y, typ, t1) =>
              if x <> y andalso V.mem(y, fv t2) = false then
                A.Lam(y, typ, subst (x, t2, t1))
              else
                if x = y then term else
                  let
                    val y' = new_var()
                    val t1' = subst (y, A.Var y', t1)
                  in
                    A.Lam (y', typ, subst (x, t2, t1'))
                  end
          | A.Add (t1, t3) => A.Add (subst (x, t2, t1), subst (x, t2, t3))
          | A.And (t1, t3) => A.And (subst (x, t2, t1), subst (x, t2, t3))
          | A.Sub (t1, t3) => A.Sub (subst (x, t2, t1), subst (x, t2, t3))
          | A.Or (t1, t3) => A.Or (subst (x, t2, t1), subst (x, t2, t3))
          | A.If (t1, t3, t4) =>
              A.If (subst (x, t2, t1), subst (x, t2, t3), subst (x, t2, t4))
          | A.Mul (t1, t3) => A.Mul (subst (x, t2, t1), subst (x, t2, t3))
          | A.Div (t1, t3) => A.Div (subst (x, t2, t1), subst (x, t2, t3))
          | A.Concat (t1, t3) => A.Concat (subst (x, t2, t1), subst (x, t2, t3))
          | A.Comp (t1, t3) => A.Comp (subst (x, t2, t1), subst (x, t2, t3))
          | A.Lt (t1, t3) => A.Lt (subst (x, t2, t1), subst (x, t2, t3))
          | A.Gt (t1, t3) => A.Gt (subst (x, t2, t1), subst (x, t2, t3))
          | A.App (t1, t3) => A.App (subst (x, t2, t1), subst (x, t2, t3))
          | A.Head t => A.Head (subst (x, t2, t))
          | A.List lst => A.List (sub_list (x, t2, lst))
          | A.FRead t => A.FRead (subst (x, t2, t))
          | A.Nat n => A.Nat n
          | A.True => A.True
          | A.False => A.False
          | A.Char c => A.Char c
          | A.Real r => A.Real r
          | A.Exn s => A.Exn s
          | A.Binor (t1, t3) => A.Binor (subst (x, t2, t1), subst (x, t2, t3))
          | A.Binand (t1, t3) => A.Binand (subst (x, t2, t1), subst (x, t2, t3))
          | A.Let (t1, t2, t3) => raise Fail "Removing let bindings failed"
          | A.Map (t1, t3) => A.Map (subst (x, t2, t1), subst (x, t2, t3))
        )
    end
      and sub_list (xt2list : (string * A.term * A.term list)) : A.term list =
        let
          val x = #1(xt2list)
          val t2 = #2(xt2list)
          val lst = #3(xt2list)
        in
          (case lst
             of [] => lst
              | (trm :: rest) => 
                  (subst (x, t2, trm)) :: sub_list (x, t2, rest)
          )
        end
    in
      subst x
    end
end

