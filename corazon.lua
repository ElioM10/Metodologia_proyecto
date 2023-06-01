math.randomseed(os.time())


--Funcion para crear un corazon
function crearCorazon()
  

  --Obtener los atributos para el corazon
    corazon = {}
    
    --para generar un corazon en un lugar random del mapa
    corazon.x = math.random(250, love.graphics.getWidth()-250)
    corazon.y = math.random(250, love.graphics.getHeight()-250)

    corazon.agarrado = false
  
    table.insert(corazonest, corazon)
end


