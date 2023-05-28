--Generador de laberinto: Backtracking
--Para generar un laberinto: 
--    -> en love.load():
--        llamar a la funcion iniciarLaberinto(altura, base) pasando como argumentos las dimensiones, deben ser numeros impares. Esta devuelve una tabla
--        llamar luego a la funcion generarAlgoritmo(grilla) pasando como argumento la tabla devuelta por la funcion anterior 
--    -> en love.draw(): 
--        llamar a la funcion dibujarLaberinto(grilla, 10) pasando como argumento la tabla devuelta en iniciarLaberinto y el tamaño en el que se dibujaran las casillas

require("mapas/Casilla")  --requiere la clase Casilla contenida en el archivo Casilla.lua
imgPared = love.graphics.newImage('sprites/pared.jpg')
  imgCamino = love.graphics.newImage('sprites/camino.png')

function iniciarLaberinto(altura, base) --esta función inicializa la tabla grilla que será donde se 
  --almacenen los valores numericos que representen las paredes y caminos del laberinto
  
  math.randomseed(os.time())  --llamado a la función randomseed de math, la cual sirve para que cada vez que se ejecute
  --un random salga un nro diferente
  
  grilla = {} --tabla o vector que guarda el laberinto
  pila = {} --tabla o vector que guardara las casillas ya visitadas que tienen vecinas sin visitar
  
  --llena la grilla con casillas de tipo camino, cada una está rodeada por casillas de tipo pared
  for i=1,altura do
    table.insert(grilla,i,{}) --crea una fila en la grilla
    for j=1,base do --recorre cada "columna"
      casilla1 = Casilla(i,j) --crea un objeto de tipo casilla
      
      --asigna un tipo(pared o camino) a cada casilla segun su posicion
      if i%2==0 then  
        casilla1.tipo=1
        casilla1.visitada = true
      else
        if j%2==0 then
          casilla1.tipo=1
          casilla1.visitada = true
        else
          casilla1.tipo=0
        end
      end
      grilla[i][j] = casilla1 --agrega el objeto casilla a la posicion actual de la grilla
    end
  end
  
  --guarda los datos: altura y base dentro de grilla para usos futuros
  grilla.altura = altura  
  grilla.base = base

  return grilla --devuelve la grilla iniciada
end

function generarLaberinto(grilla) --funcion que modifica la tabla grilla formando el laberinto, recibe la grilla, y una posicion de la misma desde la cual empezar a generar caminos
  
  --establece la casilla actual como la primera
  iActual = 1 
  jActual = 1  
  grilla[iActual][jActual].visitada = true  --marca la casilla actual como visitada
  
  while hayCasillas() do  --mientras hayan casillas no visitadas
    elegida = mirarVecinas(grilla, grilla[iActual][jActual])  --llama a la funcion mirarVecinas y almacena la vecina devuelta en la variable elegida
    
    if elegida.f~=0 then  --si la casilla elegida existe
      insertar(grilla[iActual][jActual])  --la inserta en la pila
      sacarPared(grilla, elegida, grilla[iActual][jActual]) --saca la pared entre la actual y la elegida
      --establece como actual a la casilla elegida
      iActual = elegida.f 
      jActual = elegida.c
      grilla[iActual][jActual].visitada = true --la marca como visitada
      
    elseif tamanioPila()-1 ~= 0 then  --si la casilla elegida no existe, es decir que la casilla actual se quedo sin vecinas para visitar, y hay casillas en la pila
      casillaX = extraer()  --extrae la ultima casilla ingresada en la pila
      --establece como actual la casilla extraida
      iActual = casillaX.f  
      jActual = casillaX.c
      
    end
  end
end

function mirarVecinas(grilla, casilla)  --funcion que revisa las casillas que rodean a la casilla recibida por
  --parametros y devuelve una que no ha sido visitada de forma aleatoria o, si todas han sido visitadas, una casilla
  --con valores c y f iguales a 0
  
  noVisitadas = {}  --arreglo que guardara aquellas casillas vecinas que no han sido visitadas
  vecina = Casilla(0,0) --casilla que guardara a la vecina elegida para devolver
  contador = 0  --variable numerica para guardar la cantidad de vecinas no visitadas
  
  --a continuacion se revisan las casillas de los alrededores segun la posicion de la casilla recibida por parametros
  if casilla.f==1 and casilla.c==1 then --si es la esquina superior izquierda se revisan...
    
    derecha = mirarDerecha(grilla, casilla) --casilla derecha
    if derecha[1] ~= 0  then  --si el numero devuelto por la función en la posicion 1 es distinto a cero, significa 
      --que la casilla no ha sido visitada aún
      contador = contador + derecha[1]  --agrega 1 al contador
      table.insert(noVisitadas,contador,derecha[2]) --agrega la casilla al arreglo noVisitadas
    end 
    
    abajo = mirarAbajo(grilla, casilla) --casilla de abajo
    if abajo[1] ~= 0 then
      contador = contador + abajo[1]
      table.insert(noVisitadas,contador,abajo[2])
    end
    

  elseif casilla.f==1 and casilla.c==grilla.base then--si es la esquina superior derecha...
    
    abajo = mirarAbajo(grilla, casilla) --casilla de abajo
    if abajo[1] ~=0 then
      contador = contador + abajo[1]
      table.insert(noVisitadas,contador,abajo[2])
    end
    
    izquierda = mirarIzquierda(grilla, casilla) --casilla izquierda
    if izquierda[1] ~=0 then
      contador = contador + izquierda[1]
      table.insert(noVisitadas,contador,izquierda[2])
    end
    
  elseif casilla.f==grilla.altura and casilla.c==1 then--si es la esquina inferior izquierda...
    
    derecha = mirarDerecha(grilla, casilla) --casilla derecha
    if derecha[1] ~=0 then
      contador = contador + derecha[1]
      table.insert(noVisitadas,contador,derecha[2])
    end  
    
    arriba = mirarArriba(grilla, casilla) --casilla de arriba
    if arriba[1] ~=0 then
      contador = contador + arriba[1]
      table.insert(noVisitadas,contador,arriba[2])
    end
    
  elseif casilla.f==grilla.altura and casilla.c==grilla.base then --si es la esquina inferior derecha...
    
    izquierda = mirarIzquierda(grilla, casilla) --casilla izquierda
    if izquierda[1]~=0 then
      contador = contador + izquierda[1]
      table.insert(noVisitadas,contador,izquierda[2])
    end 
    
    arriba = mirarArriba(grilla, casilla) --casilla de arriba
    if arriba[1] ~=0 then
      contador = contador + arriba[1]
      table.insert(noVisitadas,contador,arriba[2])
    end
    
  elseif casilla.f==1 then --si es una de la fila superior...
    derecha = mirarDerecha(grilla, casilla) --casilla derecha
    if derecha[1]~=0 then
      contador = contador + derecha[1]
      table.insert(noVisitadas,contador,derecha[2])
    end
    
    abajo = mirarAbajo(grilla, casilla) --casilla de abajo
    if abajo[1]~=0 then
      contador = contador + abajo[1]
      table.insert(noVisitadas,contador,abajo[2])
    end
    
    izquierda = mirarIzquierda(grilla, casilla) --casilla izquierda
    if izquierda[1]~=0 then
      contador = contador + izquierda[1]
      table.insert(noVisitadas,contador,izquierda[2])
    end
      
  elseif casilla.f==grilla.altura then --si es una de la fila inferior...
    
    derecha = mirarDerecha(grilla, casilla) --casilla derecha
    if derecha[1]~=0 then
      contador = contador + derecha[1]
      table.insert(noVisitadas,contador,derecha[2])
    end
    
    izquierda = mirarIzquierda(grilla, casilla) --casilla izquierda
    if izquierda[1] ~=0 then
      contador = contador + izquierda[1]
      table.insert(noVisitadas,contador,izquierda[2])
    end
    
    arriba = mirarArriba(grilla, casilla) --casilla de arriba
    if arriba[1]~=0 then
      contador = contador + arriba[1]
      table.insert(noVisitadas,contador,arriba[2])
    end
    
  elseif casilla.c==1 then --si es una de la columna izquierda...
    
    derecha = mirarDerecha(grilla, casilla) --casilla derecha
    if derecha[1]~=0 then
      contador = contador + derecha[1]
      table.insert(noVisitadas,contador,derecha[2])
    end
    
    abajo = mirarAbajo(grilla, casilla) --casilla de abajo
    if abajo[1]~=0 then
      contador = contador + abajo[1]
      table.insert(noVisitadas,contador,abajo[2])
    end
    
    arriba = mirarArriba(grilla, casilla) --casilla de arriba
    if arriba[1]~=0 then
      contador = contador + arriba[1]
      table.insert(noVisitadas,contador,arriba[2])
    end
    
  elseif casilla.c==grilla.base then --si es una de la columna derecha...
    
    abajo = mirarAbajo(grilla, casilla) --casilla de abajo
    if abajo[1]~=0 then 
      contador = contador + abajo[1]
      table.insert(noVisitadas,contador,abajo[2])
    end
    
    izquierda = mirarIzquierda(grilla, casilla) --casilla izquierda
    if izquierda[1]~=0 then
      contador = contador + izquierda[1]
      table.insert(noVisitadas,contador,izquierda[2])
    end
    
    arriba = mirarArriba(grilla, casilla) --casilla de arriba
    if arriba[1]~=0 then
      contador = contador + arriba[1]
      table.insert(noVisitadas,contador,arriba[2])
    end
    
  else --si es una del centro...
    
    derecha = mirarDerecha(grilla, casilla) --casilla derecha
    if derecha[1]~=0 then
      contador = contador + derecha[1]
      table.insert(noVisitadas,contador,derecha[2])
    end
    
    abajo = mirarAbajo(grilla, casilla) --casilla de abajo
    if abajo[1]~=0 then
      contador = contador + abajo[1]
      table.insert(noVisitadas,contador,abajo[2])
    end
    
    izquierda = mirarIzquierda(grilla, casilla) --casilla izquierda
    if izquierda[1]~=0 then
      contador = contador + izquierda[1]
      table.insert(noVisitadas,contador,izquierda[2])
    end
    
    arriba = mirarArriba(grilla, casilla) --casilla de arriba
    if arriba[1]~=0 then
      contador = contador + arriba[1]
      table.insert(noVisitadas,contador,arriba[2])
    end
    
  end
  
  if contador~=0 then --si hay casillas no visitadas    
    numAleatorio = math.random(1,contador)  --elige una al azar entre las disponibles
    vecina = noVisitadas[numAleatorio] --le asigna a la casilla Vecina, la casilla elegida
  end
  
  return vecina --devuelve la casilla vecina no visitada elegida
end

function mirarArriba(grilla, casilla) --funcion que revisa la casilla superior de una casilla dada, si ha sido visitada, la devuelve
  if grilla[casilla.f-2][casilla.c].visitada==false then  
    indice = {f=casilla.f-2, c=casilla.c}
    c = 1
  else 
    indice = nil
    c = 0
  end
  return {c, indice}
end
function mirarDerecha(grilla, casilla)  --funcion que revisa la casilla a la derecha de una casilla dada, si ha sido visitada, la devuelve
  if grilla[casilla.f][casilla.c+2].visitada==false then
    indice = {f=casilla.f, c=casilla.c+2}
    c = 1
  else 
    indice = nil
    c = 0
  end
  return {c, indice}
end
function mirarAbajo(grilla, casilla)  --funcion que revisa la casilla inferior de una casilla dada, si ha sido visitada, la devuelve
  if grilla[casilla.f+2][casilla.c].visitada==false then
    indice = {f=casilla.f+2, c=casilla.c}
    c = 1
  else 
    indice = nil
    c = 0
  end
  return {c, indice}
end
function mirarIzquierda(grilla, casilla)  --funcion que revisa la casilla a la izquierda de una casilla dada, si ha sido visitada, la devuelve
  if grilla[casilla.f][casilla.c-2].visitada==false then
    indice = {f=casilla.f, c=casilla.c-2}
    c = 1
  else 
    indice = nil
    c = 0
  end
  return {c, indice}
end

function sacarPared(grilla, proxima, actual)  --funcion que convierte la pared entre dos casillas en camino, cambiando su atributo tipo.
  if(proxima.f == actual.f) then  --si estan en la misma fila 
    if(proxima.c > actual.c) then
      grilla[actual.f][proxima.c-1].tipo = 0
      grilla[actual.f][proxima.c-1].visitada = true
    elseif(proxima.c < actual.c) then 
      grilla[actual.f][proxima.c+1].tipo = 0
      grilla[actual.f][proxima.c+1].visitada = true
    end
  elseif(proxima.c == actual.c) then  --si estan en la misma columna
    if(proxima.f > actual.f) then
      grilla[proxima.f-1][actual.c].tipo = 0
      grilla[proxima.f-1][actual.c].visitada = true
    elseif(proxima.f < actual.f) then
      grilla[proxima.f+1][actual.c].tipo = 0
      grilla[proxima.f+1][actual.c].visitada = true
    end
  end
end

function insertar(cas)  --funcion para insertar una casilla de la pila
  p = tamanioPila()
  table.insert(pila,p,cas)
end

function extraer() --funcion para extraer una casilla de la pila
  ult = tamanioPila()-1
  c = pila[ult]
  table.remove(pila,ult)
  return c
end

function tamanioPila() --funcion que devuelve la cantidad de casillas disponibles en la pila
  pos = 1
  for i, valor in ipairs(pila) do
    pos = pos + 1
  end
  --print(pos)
  return pos
end

function hayCasillas() --funcion que revisa si hay casillas que aun no han sido visitadas
  for i=1,grilla.altura,1 do
    for j=1,grilla.base,1 do
      if grilla[i][j].visitada==false then
        return true
      end
    end
  end
  return false
end

function dibujarLaberinto(grilla,dimCasilla)

  for i=1,grilla.altura do  
    for j=1,grilla.base do
      if grilla[i][j].tipo == 1 then 
        love.graphics.draw(imgPared, (j+0.3) * dimCasilla, (i-0.4) * dimCasilla, 0)
      end
      if grilla[i][j].visitada and grilla[i][j].tipo == 0  then
        love.graphics.draw(imgCamino, (j+0.3) * dimCasilla, (i-0.4) * dimCasilla, 0)
      end
    end
  end  
end