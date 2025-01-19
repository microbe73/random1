structure Board = struct
  datatype geo
  = Land
  | Water
  | Coast

  datatype player =
  Plr of {sc : int, name : string}

  datatype piece
  = Pce of {ownr : player, army : bool }
 
  datatype province =
  Prov of {name: string, terrain : geo, adj : province list, occ : piece }
  datatype board = province
  
end
