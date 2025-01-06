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
 * val u = Scan.scan "App(Lam(Vx, Vx), Vy)";
 * val w = Parse.parse u;
 * val x = Eval.unlet w;
 * val y = Eval.eval x;
 * val u = Scan.scan "App(App(Lam(Vx, Vx), Lam(Vx, Add(Vx, 7))), 5)";
 * val w = Parse.parse u;
 * val x = Eval.unlet w;
 * val y = Eval.eval x;
 * val u = Scan.scan "App(App(Lam(Vx, Lam(Vy, Sub(Vx, Vy))), 5), 3)";
 * val w = Parse.parse u;
 * val x = Eval.unlet w;
 * val y = Eval.eval x;
 * val u = Scan.scan "App(Lam(Vx, Mul(R3.75, Vx)), App(Lam(Vy, Head(Vy)), [R1.3, R3.75]))";
 * val w = Parse.parse u;
 * val x = Eval.unlet w;
 * val y = Eval.eval x;
 * val u = Scan.scan "App(Lam(Vx, If(Vx, 3, 12)), And(True, False))";
 * val w = Parse.parse u;
 * val x = Eval.unlet w;
 * val y = Eval.eval x;
 * val u = Scan.scan "App(Lam(Vx, App(Lam(Vy, Div(Vx, Vy)), 3)), 15)";
 * val w = Parse.parse u;
 * val x = Eval.unlet w;
 * val y = Eval.eval x;
 * val u = Scan.scan "Let(Vx, Add(Sub(6, 4), 8), App(Lam(Vx, Div(Vx, 5)), Vx))";
 * val w = Parse.parse u;
 * val x = Eval.unlet w;
 * val y = Eval.eval x;
 * val u = Scan.scan "Let(Vx, 6, Let(Vy, True, Let(Vz, And(True, True), If(Vz, Vx, Vy))))";
 * val w = Parse.parse u;
 * val z = TypeCheck.check_term w;
 * val x = Eval.unlet w;
 * val y = Eval.eval x;
 * val u = Scan.scan "App(Lam(Vx, Nt, Add(Vx, 7)), 8)"
 * val w = Parse.parse u;
 * val x = Eval.unlet w;
 * val y = Eval.eval x;
 * val u = Scan.scan "Add(2,3)";
 * val w = Parse.parse u;
 * val x = Eval.unlet w;
 *)
end
