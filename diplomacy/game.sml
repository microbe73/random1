structure Game = struct
  structure B = Board
  datatype phase
  = Spring
  | Fall
  | Build
  | Retreat

  datatype game =
  Gme of {players : B.player list, board : B.province list, year : int, curr_phase :
  phase }
end
