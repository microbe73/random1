structure Scan : sig
  type mode
  type pval
  val nextToken : char list -> (LexicalToken.token * char list) option
  val scan : string -> LexicalToken.token list
end = struct
  structure T = LexicalToken


  datatype mode 
  = Normal
  | Int
  | Char
  (* | Real todo: implement real number scanning *)
  datatype pval
  = Before_Dec
  | After_Dec of real
  fun nextTokenInt (cs_w_num : (char list * int)) : (T.token * char list) option
    =
    let
      val clist = #1(cs_w_num)
      val num = #2(cs_w_num)
    in
      (case clist
         of [] => SOME (T.Nat num, [])
          | (c :: cls) => 
              if Char.isDigit(c) then
            let
              val new_num = 10 * num + (Char.ord c) - 48
            in
              nextTokenInt (cls, new_num)
            end
              else
               SOME (T.Nat num, clist)

      )
    end
  fun nextTokenReal (cs_w_num : (char list * real * pval)) : (T.token * char list)
    option =
    let
      val clist = #1(cs_w_num)
      val num = #2(cs_w_num)
      val pv = #3(cs_w_num)
    in
      (case pv
         of Before_Dec =>
              (case clist
                 of [] => SOME (T.Real num, [])
                  | (#"." :: cls) => nextTokenReal (cls, num, After_Dec 0.0)
                  | (c :: cls) =>
                      if Char.isDigit(c) then
                        let
                          val new_num = 10.0 * num + (Real.fromInt(Char.ord c) - 48.0)
                        in
                          nextTokenReal (cls, new_num, Before_Dec)
                        end
                      else
                        SOME (T.Real num, clist)
              )
        | After_Dec pow =>
            (case clist
               of [] => SOME (T.Real num, [])
                | (c :: cls) =>
                    if Char.isDigit(c) then
                      let
                        val new_pow = pow - 1.0
                        val dig = Real.fromInt(Char.ord c) - 48.0
                        val new_num = num + (dig * Math.pow(10.0, new_pow))
                      in
                        nextTokenReal (cls, new_num, After_Dec new_pow)
                      end
                    else
                      SOME (T.Real num, clist)
            )
      )
    end
  fun nextToken clist =
    (case clist
       of (c :: cls) => if Char.isSpace(c) then nextToken cls else
         if Char.isDigit(c) then nextTokenInt (clist, 0) else
         (case clist
            of (#"T" :: #"r" :: #"u" :: #"e" :: cs) => SOME (T.True, cs)
             | (#"F" :: #"a" :: #"l" :: #"s" :: #"e" :: cs) => SOME (T.False,
                  cs)
             | (#"A" :: #"n" :: #"d" :: cs) => SOME (T.And, cs)
             | (#"A" :: #"d" :: #"d" :: cs) => SOME (T.Add, cs)
             | (#"(" :: cs) => SOME (T.LPar, cs)
             | (#")" :: cs) => SOME (T.RPar, cs)
             | (#"[" :: cs) => SOME (T.LBrac, cs)
             | (#"]" :: cs) => SOME (T.RBrac, cs)
             | (#"," :: cs) => SOME (T.Comma, cs)
             | (#"H" :: #"e" :: #"a" :: #"d" :: cs) => SOME (T.Head, cs)
             | (#"#" :: c :: cs) => SOME (T.Char c, cs)
             | (#"R" :: cs) => nextTokenReal (cs, 0.0, Before_Dec)
             | _ => raise Fail "Unable to parse token"
                 )
      | [] => NONE
      )
    fun scan input_list =
      let
        val c_list = explode input_list
      val res : (LexicalToken.token * char list) option = nextToken c_list
    in
    (case res
       of NONE => []
        | SOME (tok, cs) : (LexicalToken.token * char list) option => 
            let 
              val c_str = implode cs
            in
              tok::scan c_str
            end
       )
    end
      end



