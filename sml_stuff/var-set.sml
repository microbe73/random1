structure VarSet :> sig

  type set
  val empty : set

  val mem   : string * set -> bool (* membership test *)
  val ins   : string * set -> set  (* set insertion *)                          
  val rem   : string * set -> set  (* set removal *)
  val union : set * set -> set     (* set union *)

end = struct
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

