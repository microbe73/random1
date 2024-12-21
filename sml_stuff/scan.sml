structure Scan : sig
  val nextToken : char list -> (LexicalToken.token * char list) option
  val scan : string -> LexicalToken.token list
end = struct
  structure T = LexicalToken

  fun nextToken clist =
    (case clist
       of (c :: cls) => if Char.isSpace(c) then nextToken cls else
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
             | (num :: cs) =>
                 let
                   val n = Char.ord(num) - 48
                 in
                   if n >= 0 andalso n < 10 then SOME ((T.Nat n, cs)) else raise
                   Fail "Unable to parse number"
                 end
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



