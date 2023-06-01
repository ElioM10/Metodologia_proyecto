--Objetos a recoger para ganar
math.randomseed(os.time())
cantidadCasillasCamino = 0
casillaCaminoI = {}
casillaCaminoJ = {}
  
function contarCaminos(laberinto) 
  for i=1,laberinto.altura,1 do  
    for j=1,laberinto.base,1 do
      if not (laberinto[i][j].tipo==1) then
        cantidadCasillasCamino = cantidadCasillasCamino + 1
        casillaCaminoI[cantidadCasillasCamino] = i
        casillaCaminoJ[cantidadCasillasCamino] = j
      end
    end
  end 
end

function crearPuntos()
  local puntos = {}
    for i=1,3,1 do
      local punto = {}
      punto.x = 0
      punto.y = 0
      punto.muerto = false
      
      --cantidadCasillasCamino -> opciones sobre las que aparecer
      --casillaCaminoX -> posicion j - COLUMNA
      --casillaCaminoY -> posicion i - FILA 
      
      local centro = 190  --centro de la casilla

      --1ro: Elegir una casilla de camino al azar
      local casillaAleatoria = math.random(1, cantidadCasillasCamino)
      --print("Aleatoria: ", casillaAleatoria)
      
      --2do: Obtener la posicion X e Y de dicha casilla
      local posicionY = ( casillaCaminoI[casillaAleatoria] - 0.4 ) * 380
      local posicionX = ( casillaCaminoJ[casillaAleatoria] + 0.3 ) * 380
      --print("X ",posicionX," - Y:",posicionY)
      
      --3ero: Posicionar el Punto en el centro de esa casilla
      punto.x = posicionX + 190
      punto.y = posicionY + 190
      --print("Punto X: ",punto.x," Y:",punto.y)
      
      table.insert(puntos,punto)
    end
    
    --4to añadirlos a la tabla de objetivos
    return puntos
end

function dibujarPuntos(puntos)
  for i,obj in ipairs(puntos) do
    love.graphics.circle("fill",obj.x,obj.y,25)
  end
end