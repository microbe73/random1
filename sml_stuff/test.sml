structure Test = struct
  structure T = LexicalToken
  structure A = AST
  fun test s =
    let
      val lexTokList = Scan.scan s
      val ast = Parse.parse lexTokList
      val res = Eval.eval ast
    in
      (lexTokList, ast, res)
    end
end
