structure Test = struct
  structure T = LexicalToken
  structure A = AST
  fun scan () =
    let
      val _ = () (* Check.expect (Scan.scan "0" [T.Nat 0], "scan1") *)
    in
      TextIO.print "Scan testing done\n"
    end
end
