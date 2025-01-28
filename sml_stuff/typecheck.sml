structure TypeCheck : sig
  type env
  val lookup : (string * env) -> Types.typ
  val add_var : (string * Types.typ * env) -> env
  val check_term : AST.term -> Types.typ
end = struct
  type env = (string * Types.typ) list
  (* efficiency is once again a skill issue *)
  structure A = AST
  fun lookup (name_env : string * ((string * Types.typ) list)) : Types.typ =
    let
      val name = #1(name_env)
      val env = #2(name_env)
    in
      (case env
         of [] => raise Fail "Variable not found in type environment"
          | ((var, vartype) :: rest) =>
              if name = var then vartype else lookup (name, rest)
      )
    end
  fun add_var (name_typ_env : string * Types.typ * env) : env =
    let
      val new_name = #1(name_typ_env)
      val new_type = #2(name_typ_env)
      val env = #3(name_typ_env)
    in
      (new_name, new_type) :: env
    end
  fun check_term t =
    let fun check (term_w_env : AST.term * ((string * Types.typ) list)) : Types.typ =
      let
        val term = #1(term_w_env)
        val env = #2(term_w_env)
      in
      (case term
         of AST.Nat n => Types.Nat
          | AST.True => Types.Bool
          | AST.False => Types.Bool
          | AST.Real r => Types.Real
          | AST.Char c => Types.Char
          | AST.Lt (t1, t2) =>
              let
                val type1 = check (t1, env)
                val type2 = check (t2, env)
              in
                (case (type1, type2)
                   of (Types.Nat, Types.Nat) => Types.Bool
                    | (Types.Real, Types.Real) => Types.Bool
                    | _ => raise Fail "Comparision between non-numbers"
                )
              end
          | AST.Gt (t1, t2) =>
              let
                val type1 = check (t1, env)
                val type2 = check (t2, env)
              in
                (case (type1, type2)
                   of (Types.Nat, Types.Nat) => Types.Bool
                    | (Types.Real, Types.Real) => Types.Bool
                    | _ => raise Fail "Comparision between non-numbers"
                )
              end
          | AST.Add (t1, t2) =>
              let
                val type1 = check (t1, env)
                val type2 = check (t2, env)
              in
                (case (type1, type2)
                   of (Types.Nat, Types.Nat) => Types.Nat
                    | (Types.Real, Types.Real) => Types.Real
                    | _ => raise Fail "Arithmetic between non-numbers"
                )
              end
          | AST.Sub (t1, t2) =>
              let
                val type1 = check (t1, env)
                val type2 = check (t2, env)
              in
                (case (type1, type2)
                   of (Types.Nat, Types.Nat) => Types.Nat
                    | (Types.Real, Types.Real) => Types.Real
                    | _ => raise Fail "Arithmetic between non-numbers"
                )
              end
          | AST.Mul (t1, t2) =>
              let
                val type1 = check (t1, env)
                val type2 = check (t2, env)
              in
                (case (type1, type2)
                   of (Types.Nat, Types.Nat) => Types.Nat
                    | (Types.Real, Types.Real) => Types.Real
                    | _ => raise Fail "Arithmetic between non-numbers"
                )
              end
          | AST.Div (t1, t2) =>
              let
                val type1 = check (t1, env)
                val type2 = check (t2, env)
              in
                (case (type1, type2)
                   of (Types.Nat, Types.Nat) => Types.Nat
                    | (Types.Real, Types.Real) => Types.Real
                    | _ => raise Fail "Arithmetic between non-numbers"
                )
              end
          | AST.Or (t1, t2) =>
              let
                val type1 = check (t1, env)
                val type2 = check (t2, env)
              in
                (case (type1, type2)
                   of (Types.Bool , Types.Bool) => Types.Bool
                    | _ => raise Fail "Logic between non-booleans"
                )
              end
          | AST.And (t1, t2) =>
              let
                val type1 = check (t1, env)
                val type2 = check (t2, env)
              in
                (case (type1, type2)
                   of (Types.Bool , Types.Bool) => Types.Bool
                    | _ => raise Fail "Logic between non-booleans"
                )
              end
          | AST.Var s => lookup (s, env)
          | AST.Lam (x, typ, t1) =>
              let
                val new_env = add_var (x, typ, env)
                val type1 = check (t1, new_env)
              in
                Types.Func (typ, type1)
              end
          | AST.App (t1, t2) =>
              let
                val type1 = check (t1, env)
                val type2 = check (t2, env)
              in
                (case type1
                   of Types.Func (dmn, rng) =>
                        if type2 = dmn then rng else
                          raise Fail "Incorrect function type"
                    | _ => raise Fail "Applying to non-function"
                )
              end
          | AST.If (t1, t2, t3) =>
              let
                val type1 = check (t1, env)
                val type2 = check (t2, env)
                val type3 = check (t3, env)
              in
                (case type1
                   of Types.Bool => if type2 = type3 then type2 else raise Fail
                   "Branches have different types"
                    | _ => raise Fail "Non boolean in If condition"
                )
              end
          | AST.Head t1 =>
              let
                val type1 = check (t1, env)
              in
                (case type1
                   of Types.List t => t
                    | _ => raise Fail "applying head to non-list"
                )
              end
          | AST.Comp (t1, t2) =>
              let
                val type1 = check (t1, env)
                val type2 = check (t2, env)
              in
                (case type2
                   of Types.List t => if type1 = t then type2 else raise Fail
                   "Combining an element of different type with a list"
                    | _ => raise Fail "combining onto a non-list"
                )
              end
          | AST.Concat (t1, t2) =>
              let
                val type1 = check (t1, env)
                val type2 = check (t2, env)
              in
                (case type2
                   of Types.List t => if type1 = type2 then type2 else raise Fail
                   "Concatenating lists of different types"
                    | _ => raise Fail "Concatenating non-lists"
                )
              end
          | AST.Binor (t1, t2) =>
              let
                val type1 = check (t1, env)
                val type2 = check (t2, env)
              in
                (case type1
                   of Types.List Types.Nat => 
                        if type1 = type2 then type2
                        else raise Fail "Invalid binor lists"
                    | _ => raise Fail "Invalid binor type"
                )
              end
          | AST.Binand (t1, t2) =>
              let
                val type1 = check (t1, env)
                val type2 = check (t2, env)
              in
                (case type1
                   of Types.List Types.Nat => 
                        if type1 = type2 then type2
                        else raise Fail "Invalid binand lists"
                    | _ => raise Fail "Invalid binand type"
                )
              end
          | AST.List lst =>
              (case lst
                 of [] => raise Fail "Unable to type empty lists (may add later)"
                  | (fst :: rest) =>
                      let
                        val type1 = check (fst, env)
                      in
                        check_list (lst, type1, env)
                      end
              )
          | A.Let (t1, t2, t3) =>
              (case t1
                 of A.Var s =>
                      let
                        val type2 = check (t2, env)
                        val new_env = add_var (s, type2, env)
                      in
                        check (t3, new_env)
                      end
                  | _ => raise Fail "non variable in Let statement"
              )
          | A.Map (t1, t2) =>
              let
                val type1 = check (t1, env)
                val type2 = check (t2, env)
              in
                (case type1
                   of Types.Func (dom, rng) =>
                        if type2 = Types.List dom then
                          Types.List rng
                        else raise Fail "Invalid value given to map"
                    | _ => raise Fail "Illegal type given to map"
                )
              end
          | A.Filter (t1, t2) =>
              let
                val type1 = check (t1, env)
                val type2 = check (t2, env)
              in
                (case type1
                   of Types.Func (dom, Types.Bool) =>
                        if type2 = Types.List dom then
                          Types.List dom
                        else raise Fail "Invalid value given to filter"
                    | _ => raise Fail "Invalid filter function"
                )
              end
          | AST.Pair (t1, t2) =>
              let
                val type1 = check (t1, env)
                val type2 = check (t1, env)
              in
                Types.Pair(type1, type2)
              end
          | A.Exn s =>
              raise Fail "Impossible"
          | A.FRead name =>
              let
                val type1 = check (name, env)
              in
                (case type1
                   of Types.List c =>
                        (case c
                           of Types.Char => Types.List (Types.Char)
                            | _ => raise Fail "FRead of non-string"
                        )
                    | _ => raise Fail "FRead of non-string"
                  )
                end
        )
      end
    and check_list (inp : AST.term list * Types.typ * ((string * Types.typ) list)) :
      Types.typ =
      let
        val term = #1(inp)
        val typ = #2(inp)
        val env = #3(inp)
      in
        (case term
             of [] => Types.List typ
              | (fst :: rest) =>
                  let
                    val type_fst = check (fst, env)
                  in
                    if type_fst = typ then
                      check_list (rest, typ, env)
                    else
                      raise Fail "multi-typed list"
                  end
          )
      end
    in
      check (t, [])
    end
end
