structure VarSet :> sig

  type set
  val empty : set

  val mem   : string * set -> bool (* membership test *)
  val ins   : string * set -> set  (* set insertion *)                          
  val rem   : string * set -> set  (* set removal *)
  val union : set * set -> set     (* set union *)

end = struct
  datatype bst
  = Node of (string * bst option * bst option)
  fun mem_bst (inp : string * bst) : bool =
    let
      val name = #1(inp)
      val vset = #2(inp)
    in
      (case vset
        of Node (curr_str, bst_left, bst_right) =>
      if name < curr_str then
        (case bst_left
           of NONE => false
            | SOME bst' => mem_bst (name, bst')
        )
      else if name > curr_str then
        (case bst_right
           of NONE => false
            | SOME bst' => mem_bst (name, bst')
        )
      else true
      )
    end
  fun ins_bst (inp : string * bst) : bst =
    let
      val name = #1(inp)
      val vset = #2(inp)
    in
      (case vset
         of Node (curr_str, bst_left, bst_right) =>
      if name < curr_str then
        (case bst_left
           of NONE => Node (name, NONE, NONE)
            | SOME bst' => Node (name, SOME (ins_bst (name, bst')), bst_right)
        )
      else if name > curr_str then
        (case bst_right
           of NONE => Node (name, NONE, NONE)
            | SOME bst' => Node (name, bst_left, SOME (ins_bst (name, bst')))
        )
      else vset
      )
    end
  fun union_bst (trees : bst * bst) : bst =
    let
      val b1 = #1(trees)
      val b2 = #2(trees)
    in
      (case b1
         of Node (str1, left1, right1) =>
              (case (left1, right1)
                 of (NONE, NONE) => ins_bst (str1, b2)
                  | (SOME left_bst, NONE) =>
                      ins_bst (str1, (union_bst (left_bst, b2)))
                  | (NONE, SOME right_bst) =>
                      ins_bst (str1, (union_bst (right_bst, b2)))
                  | (SOME left_bst, SOME right_bst) =>
                      ins_bst (str1, (union_bst (right_bst, union_bst (left_bst,
                      b2))))
              )
      )
    end
  fun rem_bst (inp : string * bst) : bst =
    let
      val name = #1(inp)
      val vset = #2(inp)
    in
      (case vset
         of Node (curr_str, bst_left, bst_right) =>
      if name < curr_str then
        (case bst_left
           of NONE => Node (name, NONE, NONE)
            | SOME bst' => Node (name, SOME (rem_bst (name, bst')), bst_right)
        )
      else if name > curr_str then
        (case bst_right
           of NONE => Node (name, NONE, NONE)
            | SOME bst' => Node (name, bst_left, SOME (rem_bst (name, bst')))
        )
      else
        (case (bst_left, bst_right)
           of (NONE, NONE) => raise Fail "todo: fix this case"
            | (SOME left_bst, NONE) => left_bst
            | (NONE, SOME right_bst) => right_bst
            | (SOME left_bst, SOME right_bst) => union_bst (left_bst, right_bst)
        )
      )
    end
  type set = string list
  (* efficiency is a skill issue *)
  val empty = []
  fun mem (inp : string * set) : bool =
    let
      val name = #1(inp)
      val vset = #2(inp)
    in
      (case vset
         of [] => false
          | (s :: rest) => if s = name then true else mem (name, rest)
      )
    end
  fun ins (inp : string * set) : set =
    let
      val name = #1(inp)
      val vset = #2(inp)
    in
      name :: vset
    end

  fun rem (inp : string * set) : set =
    let
      val name = #1(inp)
      fun isname n = n <> name
      val vset = #2(inp)
    in
      List.filter isname vset
    end

  fun union (s: set * set) : set = #1(s) @ #2(s)
end

