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
  (*
  fun runTests () =
    let
      val test1 = test "App(Lam(Vx, Add(Vx, 5)), 3)"
      val t1res = A.Nat 8 = A.Nat 8
    in
      [t1res, true, true]
    end
   *)
(*
 * Control.Print.printDepth := 100;
 * Control.Print.printLength := 200;
 * Control.Print.stringDepth := 200;
 * val u = Scan.scan "App(Lam(Vx, Nt, Vx), Vy)";
 * val w = Parse.parse u;
 * val z = TypeCheck.check_term w;
 * val x = Eval.unlet w;
 * val y = Eval.eval x;
 * val u = Scan.scan "App(App(Lam(Vx, Fn(Nt, Nt), Vx), Lam(Vx, Nt, Add(Vx, 7))), 5)";
 * val w = Parse.parse u;
 * val z = TypeCheck.check_term w;
 * val x = Eval.unlet w;
 * val y = Eval.eval x;
 * val u = Scan.scan "App(App(Lam(Vx, Nt, Lam(Vy, Nt, Sub(Vx, Vy))), 5), 3)";
 * val w = Parse.parse u;
 * val z = TypeCheck.check_term w;
 * val x = Eval.unlet w;
 * val y = Eval.eval x;
 * val u = Scan.scan "App(Lam(Vx, Ql, Mul(R3.75, Vx)), App(Lam(Vy, Lst(Ql), Head(Vy)), [R1.3, R3.75]))";
 * val w = Parse.parse u;
 * val z = TypeCheck.check_term w;
 * val x = Eval.unlet w;
 * val y = Eval.eval x;
 * val u = Scan.scan "App(Lam(Vx, Bl, If(Vx, 3, 12)), And(True, False))";
 * val w = Parse.parse u;
 * val z = TypeCheck.check_term w;
 * val x = Eval.unlet w;
 * val y = Eval.eval x;
 * val u = Scan.scan "App(Lam(Vx, Nt, App(Lam(Vy, Nt, Div(Vx, Vy)), 3)), 15)";
 * val w = Parse.parse u;
 * val z = TypeCheck.check_term w;
 * val x = Eval.unlet w;
 * val y = Eval.eval x;
 * val u = Scan.scan "Let(Vx, Add(Sub(6, 4), 8), App(Lam(Vx, Nt, Div(Vx, 5)), Vx))";
 * val w = Parse.parse u;
 * val z = TypeCheck.check_term w;
 * val x = Eval.unlet w;
 * val y = Eval.eval x;
 * val u = Scan.scan "Let(Vx, 6, Let(Vy, True, Let(Vz, And(True, True), If(Vz, Vx, Vy))))";
 * val w = Parse.parse u;
 * val z = TypeCheck.check_term w;
 * val x = Eval.unlet w;
 * val y = Eval.eval x;
 * val u = Scan.scan "App(Lam(Vx, Nt, Add(Vx, 7)), 8)"
 * val w = Parse.parse u;
 * val z = TypeCheck.check_term w;
 * val x = Eval.unlet w;
 * val y = Eval.eval x;
 * val u = Scan.scan "Add(2,3)";
 * val w = Parse.parse u;
 * val z = TypeCheck.check_term w;
 * val x = Eval.unlet w;
 * val y = Eval.eval x;
 * val u = Scan.scan "FRead(App(Lam(Vx, Lst(Ch), Concat(Vx, [#., #t, #x, #t])), [#t, #e, #s, #t]))"
 * val w = Parse.parse u;
 * val z = TypeCheck.check_term w;
 * val x = Eval.unlet w;
 * val y = Eval.eval x;
 * val u = Scan.scan "FRead([#t, #e, #t, #., #t, #x, #t])"
 * val w = Parse.parse u;
 * val z = TypeCheck.check_term w;
 * val x = Eval.unlet w;
 * val y = Eval.eval x;
 * val u = Scan.scan "FRead(App(Lam(Vx, Ch, Comp(Vx, [#e, #s, #t, #., #t, #x, #t])), #t))"
 * val w = Parse.parse u;
 * val z = TypeCheck.check_term w;
 * val x = Eval.unlet w;
 * val y = Eval.eval x;
 * val u = Scan.scan "Let(Vf, [#t, #e, #s, #t], Let(Vs, [#t, #x, #t], FRead(Concat(Vf, Comp(#., Vs)))))"
 * val w = Parse.parse u;
 * val z = TypeCheck.check_term w;
 * val x = Eval.unlet w;
 * val y = Eval.eval x;
 * val u = Scan.scan "App(Lam(Vf, Lst(Ch), Comp(#., Vf)), [#t, #x, #t])"
 * val w = Parse.parse u;
 * val z = TypeCheck.check_term w;
 * val x = Eval.unlet w;
 * val y = Eval.eval x;
 * val u = Scan.scan "Binor([0,1,0],[0,1])"
 * val w = Parse.parse u;
 * val z = TypeCheck.check_term w;
 * val x = Eval.unlet w;
 * val y = Eval.eval x;
 * val u = Scan.scan "Binand([0,0,1,1,0],[1,1,1,1,0,1,0,1,1])"
 * val w = Parse.parse u;
 * val z = TypeCheck.check_term w;
 * val x = Eval.unlet w;
 * val y = Eval.eval x;
 *)
end
