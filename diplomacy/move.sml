structure Move = struct
  structure B = Board
  datatype move
  = Mve of (B.province * B.province)
  | Hold
  | Supp of move
  | Conv of move

end
