zombie = require "zombie"
Menu = require "menu"
config = require "configuracion"
Pausa = require "pause"
require("goals")
ConfigSonido = require "configSonido"
corazon = require "corazon"


function love.load()
  math.randomseed(os.time())
  
  --Pantalla completa segun la resolucion del monitor actual
  ventana = love.window.setMode(0, 0)

  --Importar la camara de la libreria
  camara = require 'librerias/camera'
  cam = camara()
  
  --Importar generador de laberinto
  require("mapas/generador-de-laberinto")
  
  --Variables para determinar el tamaño del laberinto
  labX = 21
  labY = 21
  
  --Variable para asignar el tamaño de cada casilla del laberinto
  tamCasillas = 380
  
  --Crea grilla para laberinto
  mapa1 = iniciarLaberinto(labY, labX)
  
  --Crea una tabla con todos los dibujos de los corazones
  dibujos = {}
  
  table.insert(dibujos, love.graphics.newImage("sprites/heart3.png"))
  table.insert(dibujos, love.graphics.newImage("sprites/heart2.png"))
  table.insert(dibujos, love.graphics.newImage("sprites/heart1.png"))
    
  --Crea una tabla con los dibujos de la energia
  dibujosEnergia  = {}

  table.insert(dibujosEnergia, love.graphics.newImage("sprites/energia1.png"))
  table.insert(dibujosEnergia, love.graphics.newImage("sprites/energia2.png"))
  table.insert(dibujosEnergia, love.graphics.newImage("sprites/energia3.png"))
  table.insert(dibujosEnergia, love.graphics.newImage("sprites/energia4.png"))
  table.insert(dibujosEnergia, love.graphics.newImage("sprites/energia5.png"))
  table.insert(dibujosEnergia, love.graphics.newImage("sprites/energia6.png"))
	
	--Cargar los assets a utilizar
  sprites = {}

  sprites.fondoMenu = love.graphics.newImage('sprites/fondoMenu.png')
  sprites.fondoPausa = love.graphics.newImage('sprites/fondoPausa1.png')
  sprites.bala = love.graphics.newImage('sprites/bala.png')
  sprites.jugador = love.graphics.newImage('sprites/jugador_1.png')
  sprites.zombie = love.graphics.newImage('sprites/zombie.png')
  sprites.cursor = love.graphics.newImage('sprites/cursor.png')
  sprites.sombra = love.graphics.newImage('sprites/sombra.png')
  sprites.corazon = love.graphics.newImage('sprites/corazon.png')
	
	--Obtener los atributos del jugador
  jugador = {}
  jugador.x = (love.graphics.getWidth() / 2)  
  jugador.y = love.graphics.getHeight() / 2
  jugador.xF = (love.graphics.getWidth() / 2)  
  jugador.yF = love.graphics.getHeight() / 2
  jugador.velocidad = 200
  jugador.puntos = 0
  
  --Campo para detectar las colisiones del jugador
  cuerpoJug = {}
  cuerpoJug.x = (love.graphics.getWidth() / 2)-50
  cuerpoJug.y = (love.graphics.getHeight() / 2)-50
  cuerpoJug.alto = 100
  cuerpoJug.ancho = 100
  
  musicaReproduciendose = true 
  musicaOnOff = 'On'
    
  --Contador para los corazones que aparecen en el mapa
  contador = 10
  adidorTiempo = 1

  if musicaReproduciendose == false then
    musicaOnOff = 'Off'
  end
    
  --Posicion de mouse y pone invisible el mouse por defecto
  cx, cy = love.mouse.getPosition
  love.mouse.setVisible(false)
    
	--Obtener la fuente en la que van a estar las letras que aparezcan en pantalla
  love.graphics.setNewFont("fuentes/04B_30__.TTF", 80)
   
  --Craga la musica y los efectos de sonido 
  musicaIntro = love.audio.newSource("musica/musicaIntro.mp3", "stream")
  musicaJuego = love.audio.newSource("musica/musicaInGame.mp3", "stream")
  sonidoPerder = love.audio.newSource("musica/gameOverEffect.wav", "static")
  sonidoEfectoDisparo = love.audio.newSource("musica/firingEffect.wav", "static")
  sonidoGanar = love.audio.newSource("musica/shinyglittersoundeffect.wav", "static")
    
    musicaJuego:setVolume(0.1)
	
	--Cargar tables de zombies, de las balas y de corazones
    zombies = {}
    balas = {}
    corazonest = {}
	
	--Cargar tablas de zombies, de las balas y de los objetivos
  zombies = {}    
  balas = {}
  objetivos = {}

	--Otras variables necesarias
  estadoDelJuego = 1
  puntaje = 0
  tiempoMax = 2
  temporizador = tiempoMax
  nivelActual = 1
  estadoPausa = false
  estadoConfiguracionSonido = false
  volumenMusica = 1
  volumenEfectos = 1

    enfriamientoDesplazamiento = 0
    tiempoDesplazandoce = 0
    seDesplaza = false

    pausa = Pausa.new()
    pausa:anadirItem{
    nombre = 'Reanudar',
    accion = function()
      estadoPausa = false
    end
  }
  --Boton para parar o reproducir la musica
  pausa:anadirItem{
    nombre = 'Sonido',--Configuracion de sonido
    accion = function()
      estadoConfiguracionSonido = true
    end
  }
  pausa:anadirItem{
    nombre = 'Salir',
    accion = function()
      love.event.quit(0)
    end
  }
  
  configSonido = ConfigSonido.new()
  configSonido:anadirItem{
    nombre = '<musica:     >',
    bajarVolumen = function()
      if volumenMusica > .1 then
        volumenMusica = volumenMusica - .2
        musicaJuego:setVolume(volumenMusica)
      end
    end,
    subirVolumen = function()
      if volumenMusica < 1 then
        volumenMusica = volumenMusica + .2
        musicaJuego:setVolume(volumenMusica)
      end
    end
  }
  configSonido:anadirItem{
    nombre = '<efectos:     >',
    bajarVolumen = function()
      if volumenEfectos > .1 then
        volumenEfectos = volumenEfectos - .2
        sonidoEfectoDisparo:setVolume(volumenEfectos)
        sonidoPerder:setVolume(volumenEfectos)
        love.audio.stop(sonidoEfectoDisparo)
        love.audio.play(sonidoEfectoDisparo)
      end
    end,
    subirVolumen = function()
      if volumenEfectos < 1 then
        volumenEfectos = volumenEfectos + .2
        sonidoEfectoDisparo:setVolume(volumenEfectos)
        sonidoPerder:setVolume(volumenEfectos)
        love.audio.stop(sonidoEfectoDisparo)
        love.audio.play( sonidoEfectoDisparo)     
      end
    end
  }
  configSonido:anadirItem{
    nombre = 'volver',
    accion = function()
      estadoConfiguracionSonido = false
    end
  }


  if estadoDelJuego == 1 then
    menu = Menu.new()
    menu:anadirItem{
    nombre = 'Jugar',
    accion = function()
      estadoDelJuego = 2
      tiempoMax = 2
      temporizador = tiempoMax
      puntaje = 0
      
      --Generar laberinto
      generarLaberinto(mapa1)
        
      contarCaminos(mapa1)
      
      --Crear objetivos
      objetivos = crearPuntos()
      
       --Variable de vidas del jugador
      corazones = 3
    end
  }
  menu:anadirItem{
    nombre = 'Salir',
    accion = function()
      love.event.quit(0)
    end
  }

  --Boton para parar o reproducir la musica
  menu:anadirItem{
    nombre = 'Musica',--.. musicaOnOff,
    accion = function()
      if musicaReproduciendose == true then
        musicaReproduciendose = false
      else
        musicaReproduciendose = true
      end
    end
  }
  end

  function love.update(dt)
  
	--Tomar el input del usuario sobre la direccion 
	--SOLO si el juego YA HA COMENZADO

  if estadoPausa == false then --ESTADO 2 SOLO FUNCIONA SI NO ESTA EN PAUSA
    if estadoDelJuego == 2 then
        if (love.keyboard.isDown("d") or love.keyboard.isDown("right")) and math.floor(jugador.x+50) < ((tamCasillas * labX)+(1.3*tamCasillas)-5) then
          if revisarColisionesDerecha(cuerpoJug) then
            jugador.x = jugador.x + jugador.velocidad*dt
          end
        end
      if (love.keyboard.isDown("a") or love.keyboard.isDown("left")) and math.floor(jugador.x-50) > (1.3*tamCasillas)+5 then
          if  revisarColisionesIzquierda(cuerpoJug) then
            jugador.x = jugador.x - jugador.velocidad*dt
          end
        end
        if (love.keyboard.isDown("w") or love.keyboard.isDown("up")) and math.floor(jugador.y-50) > (0.6*tamCasillas)+5 then
          if revisarColisionesArriba(cuerpoJug) then
            jugador.y = jugador.y - jugador.velocidad*dt
          end
        end
        if (love.keyboard.isDown("s") or love.keyboard.isDown("down")) and math.floor(jugador.y+50) < ((tamCasillas * labY)+(0.6*tamCasillas)-5) then
          if revisarColisionesAbajo(cuerpoJug) then
            jugador.y = jugador.y + jugador.velocidad*dt
          end
        end
        
        --Desplazamiento rapido
        if (love.keyboard.isDown("d") or love.keyboard.isDown("right")) and (love.keyboard.isDown("space")) and enfriamientoDesplazamiento <= 0  and  math.floor(jugador.x+50) < ((tamCasillas * labX)+(1.3*tamCasillas)-5) then
          if revisarColisionesDerecha(cuerpoJug) then
            jugador.x = jugador.x + jugador.velocidad *dt
            seDesplaza = true
          end
        end

        if (love.keyboard.isDown("a") or love.keyboard.isDown("left")) and (love.keyboard.isDown("space")) and enfriamientoDesplazamiento <= 0 and math.floor(jugador.x-50) > (1.3*tamCasillas)+5 then
          if revisarColisionesIzquierda(cuerpoJug) then
            jugador.x = jugador.x - jugador.velocidad *dt
            seDesplaza = true    
          end
        end

        if (love.keyboard.isDown("w") or love.keyboard.isDown("up")) and (love.keyboard.isDown("space")) and enfriamientoDesplazamiento <= 0 and math.floor(jugador.y-50) > (0.6*tamCasillas)+5 then
          if revisarColisionesArriba(cuerpoJug) then
            jugador.y = jugador.y - jugador.velocidad *dt
            seDesplaza = true
          end
        end

        if (love.keyboard.isDown("s") or love.keyboard.isDown("down")) and (love.keyboard.isDown("space")) and enfriamientoDesplazamiento <= 0 and math.floor(jugador.y+50) < ((tamCasillas * labY)+(0.6*tamCasillas)-5) then
          if revisarColisionesAbajo(cuerpoJug) then
            jugador.y = jugador.y + jugador.velocidad *dt
            seDesplaza = true 
          end
        end
        
        cuerpoJug.x=jugador.x-50
        cuerpoJug.y=jugador.y-50
        
        -------------------
        
          --itera sobre la tabla de corazones del mapa
          for e,p in ipairs(corazonest) do
                
          --Si el jugador toca uno de los corazones
              if distanciaEntre(p.x, p.y, jugador.x, jugador.y) < 20 then
                
                --Si los corazones son mas de uno
                if corazones < 3 then
                  --Se añade uno
                  corazones = corazones + 1
                end 
                   
              --Elimina el corazon para que no se sigan aumentando vidas
              p.agarrado = true
            end
        end

        --Activa la pausa
        if(love.keyboard.isDown("escape")) then
          estadoPausa = true
        end
        
        if musicaReproduciendose == false then
          love.audio.stop(musicaIntro)
        elseif not musicaIntro:isPlaying() and musicaReproduciendose == true then
          --funciona bien 
        end
      
       --Temporizador de enfriamiento para el desplazamiento 
        if seDesplaza then
          tiempoDesplazandoce = tiempoDesplazandoce+(dt/2)
          if tiempoDesplazandoce > 0.5 then
            tiempoDesplazandoce = 0;
            seDesplaza = false
            enfriamientoDesplazamiento = 5
          end
        end
        if math.ceil(enfriamientoDesplazamiento)~= 0 then
          enfriamientoDesplazamiento = enfriamientoDesplazamiento-dt
        end 
        -------


      elseif estadoDelJuego == 1 then
        if musicaReproduciendose == false then
          love.audio.stop(musicaIntro)
          
        elseif not musicaIntro:isPlaying() and musicaReproduciendose == true then
          --funciona bien 
        end
        menu:actualizar(dt)
        configSonido:actualizar(dt)
      end
    

	
	--itera sobre la tabla de zombies y el movimiento que deben hacer respecto a la posicion del jugador
    for i,z in ipairs(zombies) do
        z.x = z.x + (math.cos( zombieJugadorAngulo(z) ) * z.velocidad * dt)
        z.y = z.y + (math.sin( zombieJugadorAngulo(z) ) * z.velocidad * dt)
        
		--Reinicia el juego si un zombie toca al jugador
        if distanciaEntre(z.x, z.y, jugador.x, jugador.y) < 40 then
          
          --Si los corazones son mas de uno
          if corazones > 1 then
            --Se elimina uno
            corazones = corazones - 1
            
            --Elimina al enemigo para que no se sigan sacando vidas
            z.muerto = true
          else
            --parar la musica del juego
            if musicaJuego:isPlaying() then
              love.audio.stop(musicaJuego)
            end
            --Pone sonido de perder
            love.audio.play( sonidoPerder )
            
            --Dormir al programa por 1 seg mientras suena el efecto
            love.timer.sleep(1)
            contador = 10
            adidorTiempo = 1
            estadoDelJuego = 1
            
            
            --Destruye todos los objetos zombie
            for i,z in ipairs(zombies) do
                  zombies[i] = nil

            end
            
            for e, p in ipairs(corazonest) do
              corazonest[e] = nil
            end
            --Coloca al jugador de nuevo al centro
                  jugador.x = love.graphics.getWidth()/2
                  jugador.y = love.graphics.getHeight()/2
                  estadoDelJuego = 1
                  love.graphics.setBackgroundColor(0,0,0,50)
                  mapa1 = iniciarLaberinto(labY, labX)
        end
      
    end
  end
	
    --Itera sobre la tabla de objetivos para ver si los ha recolectado
    for i,obj in ipairs(objetivos) do
      --Si se acerca a un objetivo...
      if distanciaEntre(obj.x, obj.y, jugador.x, jugador.y) < 25 then
        --Añade el objetivo a los puntos del jugador
        if obj.muerto==false then
          jugador.puntos = jugador.puntos + 1
          obj.muerto = true
        end
        --Si junto los tres objetivos...
        if jugador.puntos==3 then --gana el juego
          --parar la musica
          if musicaJuego:isPlaying() then
            love.audio.stop(musicaJuego)
          end
          --Poner sonido de ganar
          love.audio.play(sonidoGanar)
          
          --Dormir al programa por 1 seg mientras suena el efecto
          love.timer.sleep(2)
          estadoDelJuego = 1
          
          --Destruye todos los objetos zombie
          for i,z in ipairs(zombies) do
            zombies[i] = nil
          end
          
          --Coloca al jugador de nuevo al centro
          jugador.x = love.graphics.getWidth()/2
          jugador.y = love.graphics.getHeight()/2
          
          --Destruye los objetos objetivos 
          for i,o in ipairs(objetivos) do
            objetivos[i]=nil
          end
          
          love.graphics.setBackgroundColor(0,0,0,50)
          mapa1 = iniciarLaberinto(labY, labX)
        end
      end
      
    end
  
  --Obtiene la posicion del mouse para el cambio de sprite del mismo
  cx, cy = love.mouse.getPosition()

	--Itera sobre todos los elementos en la tabla de balas y
	--saca su direccion y movimiento
    for i,b in ipairs(balas) do
        b.x = b.x + (math.cos( b.direccion ) * b.velocidad * dt)
        b.y = b.y + (math.sin( b.direccion ) * b.velocidad * dt)
    end
	
	--Remueve las balas que han salido de la pantalla
    for i=#balas, 1, -1 do
        local b = balas[i]
        if b.x < 0 or b.y < 0 or b.x > ((tamCasillas * labX)+(1.3*tamCasillas)) or b.y > ((tamCasillas * labY)+(0.6*tamCasillas)) or (i>40) then
            table.remove(balas, i)
        end
    end
    
    --Itera sobre los objetivos para borrar aquellos recogidos
    for i,obj in ipairs(objetivos) do
      if obj.muerto==true then
        table.remove(objetivos,i)
      end
    end
    
	--Itera sobre los zombies buscando si alguna bala ha colisionado con ellos
	--Si es asi, los elimina de la tabla y aumenta el puntaje
    for i,z in ipairs(zombies) do
        for j,b in ipairs(balas) do
            if distanciaEntre(z.x, z.y, b.x, b.y) < 30 then
                z.muerto = true
                b.muerto = true
                puntaje = puntaje + 1
            end
        end
    end

    for i=#zombies,1,-1 do
        local z = zombies[i]
        if z.muerto == true then
          table.remove(zombies, i)
        end
    end
    
    --Remueve los corazones que han sido agarrados por el jugador
    for i=#corazonest,1,-1 do
        local c = corazonest[i]
        if c.agarrado == true then
            table.remove(corazonest, i)
        end
    end

	--Remueve las balas que han colisionado con los enemigos
    for i=#balas,1,-1 do
        local b = balas[i]
        if b.muerto == true then
          table.remove(balas, i)
        end
    end
  
    
	--Crea enemigos nuevos cada tantos segundos
    if estadoDelJuego == 2 then
        temporizador = temporizador - dt
        if temporizador <= 0 then
            crearZombie()
            contador = contador - 1
            tiempoMax = 0.95 * tiempoMax
            temporizador = tiempoMax
            
            --Cada 10 enemigos, generar un corazon en un lado random del mapa
            if contador == 0 then
              crearCorazon()
              adidorTiempo = adidorTiempo * 10
              contador = 10 + adidorTiempo
              

            end
            
        end
    end
    
    --Tomar la dimension de la pantalla
    w = (love.graphics.getWidth() / 2)  
    h = love.graphics.getHeight() / 2
    
    if estadoDelJuego == 2 then   
      --Hacer que la camara siga al jugador
      cam:lookAt(jugador.x, jugador.y)
      
      --Hacer que no llegue a los bordes, que la camara pare de seguirlo si se acerca al limite
      if cam.x < w/2 then
        cam.x = w/2
      end
      if cam.y < h/2 then
        cam.y = h/2
      end
        
        --Para los bordes de abajo:
        --Cuanto tengamos un tile map funcionar habra que añadir:
        
      local mapaTileW = tamCasillas * (labX+1.3)
      local mapaTileH = tamCasillas * (labY+0.6)
        
        --Solo si estamos trabajando con tiles, si estamos trabajando
        --con un fondo normal, no se haria el calculo y solo se pondria 
        --el ancho/alto del fondo :D
        
      if cam.x > (mapaTileW - w/2) then
        cam.x = mapaTileW - w/2
      end 
      if cam.y > (mapaTileH - h/2) then
        cam.y = mapaTileH - h/2
      end
        
        
    else
      --Si estamos en el menu, que la camara este fija en el medio
      cam:lookAt(w, h)

  end
  
  --SI LA PAUSA ESTA ACTIVA
  else
    pausa:actualizar(dt)
    configSonido:actualizar(dt)

  end
end


  function love.draw()
    
    --Sacar el tamaño de la ventana
    local anchoVentana = love.graphics.getWidth()
    local altoVentana = love.graphics.getHeight()
    
    cam:attach()
    --Si el juego aun no comenzo
    if estadoDelJuego == 1 then
        love.graphics.draw(sprites.fondoMenu, 0, 0)
        love.graphics.setNewFont("fuentes/04B_30__.TTF", 70)
          menu:dibujar(anchoVentana/2 - 175, altoVentana/2 - 50)
          
          --love.graphics.setNewFont("llpixel/LLPIXEL3.TTF", 90)
          love.graphics.setNewFont("fuentes/Pixelmania.ttf", 45)
          love.graphics.printf("ESCAPE FROM THE MAZE", 0, love.graphics.getHeight()-(love.graphics.getHeight()/4)*3, love.graphics.getWidth(), "center")
          
          if musicaJuego:isPlaying() then
            love.audio.stop(musicaJuego)
          end
      
          --Musica para el menu principal
          love.audio.play(musicaIntro)
          if not musicaIntro:isPlaying() then
            love.audio.play(musicaIntro)
          end
    elseif estadoDelJuego == 3 then
        
        --Mensaje de ganador
        love.graphics.setNewFont("fuentes/Pixelmania.ttf", 45)
        love.graphics.printf("¡Ganaste!", 0, love.graphics.getHeight()-(love.graphics.getHeight()/4)*3, love.graphics.getWidth(), "center")
        estadoDelJuego=1
        
    elseif estadoDelJuego == 2 then
        --RGB (62,94,109)
        local rojo = 62/255
        local verde = 94/255
        local azul = 109/255
        local alfa = 50/100
        love.graphics.setBackgroundColor(rojo,verde,azul,alfa)
      
        --Dibuja el laberinto
        dibujarLaberinto(mapa1, tamCasillas)
   
        --Dibujar los objetivos
        dibujarPuntos(objetivos)

        --Dibuja los corazones
        for e,p in ipairs(corazonest) do
          love.graphics.draw(sprites.corazon, p.x, p.x, nil, 0.75, nil, sprites.corazon:getWidth()/2, sprites.corazon:getHeight()/2)
        end
    
       --Dibuja al jugador en la pantalla
        love.graphics.draw(sprites.jugador, jugador.x, jugador.y, jugadorAnguloMouse(), nil, nil, sprites.jugador:getWidth()/2, sprites.jugador:getHeight()/2)
        
        --Dibuja a los zombies 
        for i,z in ipairs(zombies) do
          love.graphics.draw(sprites.zombie, z.x, z.y, zombieJugadorAngulo(z), nil, nil, sprites.zombie:getWidth()/2, sprites.zombie:getHeight()/2)
        end
    
        --Dibuja las balas
        for i,b in ipairs(balas) do
          love.graphics.draw(sprites.bala, b.x, b.y, nil, 0.5, nil, sprites.bala:getWidth()/2, sprites.bala:getHeight()/2)
        end
      
        if musicaReproduciendose == true then
          --Para la musica de la introduccion si esta sonando
          if musicaIntro:isPlaying() then
            love.audio.stop(musicaIntro)
          end
        
          --Musica dentro del juego
          love.audio.play(musicaJuego)
            if not musicaJuego:isPlaying( ) then
              love.audio.play(musicaJuego)
            end
        end
    end
    cam:detach()
    
    if estadoDelJuego == 2  then

      --Dibuja la sombra
      love.graphics.draw(sprites.sombra, -150, -50, 0, 1, 1)

      --Dibuja los corazones en la pantalla dependiendo de cuantos le queden al jugador
      if corazones ~=0 then
        love.graphics.draw(dibujos[math.floor(corazones)], love.graphics.getHeight()-(love.graphics.getHeight()/6)*5.7, 15)
      end
      
      --Dibuja el medidor de energia
      if enfriamientoDesplazamiento >= 0 then
        love.graphics.draw(dibujosEnergia[math.floor(enfriamientoDesplazamiento+1)],love.graphics.getHeight()-(love.graphics.getHeight()/6)*5.7 , 90)
      elseif enfriamientoDesplazamiento < 0 then
        love.graphics.draw(dibujosEnergia[math.floor(1)],love.graphics.getHeight()-(love.graphics.getHeight()/6)*5.7 , 90)
      end

      --Dibuja el puntaje en pantalla
      love.graphics.setNewFont("fuentes/04B_30__.TTF", 35)
      love.graphics.printf("puntaje: " .. puntaje, 0, love.graphics.getHeight()-love.graphics.getHeight()/6, love.graphics.getWidth()-500, "center")
      
      --Dibuja los objetivos en pantalla
      love.graphics.setNewFont("fuentes/04B_30__.TTF", 35)
      love.graphics.printf("objetivos: " .. jugador.puntos .. "/3", 0, love.graphics.getHeight()-love.graphics.getHeight()/6, love.graphics.getWidth()+500, "center")
      
      --Dibuja el cursor con el sprite
      love.graphics.draw(sprites.cursor, cx-15, cy-15, 0, 0.07)
    end
    
     --Dibuja pantalla de pausa
     if estadoPausa then
      love.graphics.draw(sprites.fondoPausa, 10, -10, 0, 1.1, 1.1) --Fondo

      if estadoConfiguracionSonido == false then    
        love.graphics.printf("PAUSA", 0, love.graphics.getHeight()-530, love.graphics.getWidth()-200, "center", 0, 1, 1, -100, 0) --Titulo Pausa
        pausa:dibujar(love.graphics.getWidth()/2 - 175, love.graphics.getHeight()/2 - 50)
      end
      if estadoConfiguracionSonido then
        love.graphics.printf("configuracion de sonido", 0, love.graphics.getHeight()-530, love.graphics.getWidth()-200, "center", 0, 1, 1, -100, 0)
        configSonido:dibujar(love.graphics.getWidth()/2 - 175, love.graphics.getHeight()/2 - 50)
       
        if volumenMusica == 1 then love.graphics.printf("*****", 0, love.graphics.getHeight()-340, love.graphics.getWidth(), "left", 0, 1, 1, -427, 0) end
        if volumenMusica >= 0.8 then love.graphics.printf("**** ", 0, love.graphics.getHeight()-340, love.graphics.getWidth(), "left", 0, 1, 1, -427, 0) end
        if volumenMusica >= 0.6 then love.graphics.printf("***  ", 0, love.graphics.getHeight()-340, love.graphics.getWidth(), "left", 0, 1, 1, -427, 0) end
        if volumenMusica >= 0.4 then love.graphics.printf("**   ", 0, love.graphics.getHeight()-340, love.graphics.getWidth(), "left", 0, 1, 1, -427, 0) end
        if volumenMusica >= 0.2 then love.graphics.printf("*    ", 0, love.graphics.getHeight()-340, love.graphics.getWidth(), "left", 0, 1, 1, -427, 0) end

        if volumenEfectos == 1 then love.graphics.printf("*****", 0, love.graphics.getHeight()-240, love.graphics.getWidth(), "left", 0, 1, 1, -450, 0) end
        if volumenEfectos >= 0.8 then love.graphics.printf("**** ", 0, love.graphics.getHeight()-240, love.graphics.getWidth(), "left", 0, 1, 1, -450, 0) end
        if volumenEfectos >= 0.6 then love.graphics.printf("***  ", 0, love.graphics.getHeight()-240, love.graphics.getWidth(), "left", 0, 1, 1, -450, 0) end
        if volumenEfectos >= 0.4 then love.graphics.printf("**   ", 0, love.graphics.getHeight()-240, love.graphics.getWidth(), "left", 0, 1, 1, -450, 0) end
        if volumenEfectos >= 0.2 then love.graphics.printf("*    ", 0, love.graphics.getHeight()-240, love.graphics.getWidth(), "left", 0, 1, 1, -450, 0) end
      end 

      --love.graphics.draw(dibujos[math.floor(corazones)], 725, 485, 0, -.6, .6) --Dibuja corazones en menu
      --love.graphics.printf("puntaje: " .. puntaje, 0, love.graphics.getHeight()-70, love.graphics.getWidth()+670, "right", 0, .5, .5) --Puntaje en menu
      love.graphics.setNewFont("fuentes/04B_30__.TTF", 50)
      
      --Dibuja el cursor con el sprite
      love.graphics.draw(sprites.cursor, cx-15, cy-15, 0, 0.07)

    end

  --Dibuja el cursor con el sprite
  love.graphics.draw(sprites.cursor, cx-15, cy-15, 0, 0.07)

  
end

end
--Funcion para crear zombies una vez se comience el juego apretando el espacio
function love.keypressed( tecla )
  if tecla == "space" then
      crearZombie()
  end
end

--Funcion para disparar si ya ha comenzado
function love.mousepressed( x, y, boton )
  if boton == 1 and estadoDelJuego == 2 and estadoPausa == false then
      crearBala()
      love.audio.play( sonidoEfectoDisparo )
  
  end
end

function love.keypressed(key)
if estadoDelJuego == 1 then
  
  menu:keypressed(key)
else if estadoDelJuego == 2 and estadoPausa == true then
  if estadoConfiguracionSonido then
    configSonido:keypressed(key)
  else
  pausa:keypressed(key)
  end
end
end
end

--Funcion para crear una bala
function crearBala()
  local bala = {}
  bala.x = jugador.x
  bala.y = jugador.y
  bala.velocidad = 500
  bala.muerto = false
  bala.direccion = jugadorAnguloMouse()
  table.insert(balas, bala)
end

--Funcion para calcular la distancia entre dos coordenadas en la pantalla
function distanciaEntre(x1, y1, x2, y2)
  return math.sqrt( (x2 - x1)^2 + (y2 - y1)^2 )
end

--Funciones para revisar las colisiones de un cuerpo respecto a las casillas del laberinto
function revisarColisionesDerecha(cuerpoRecibido)
local iArr = math.floor( (cuerpoRecibido.y/tamCasillas) + 0.4 )
local jDer = math.floor( ( (cuerpoRecibido.x+cuerpoRecibido.ancho) /tamCasillas)-0.3 )
local iAbaj = math.floor( ( (cuerpoRecibido.y+cuerpoRecibido.alto) /tamCasillas) +0.4  )
local jIzq = math.floor( (cuerpoRecibido.x/tamCasillas)-0.3 )
local n = 10

if jDer==(labX+1) then 
  return false
  
elseif (mapa1[iArr][jDer].tipo == 1 and mapa1[iAbaj][jDer].tipo == 1) then
  return false
  
elseif (mapa1[iArr][jDer].tipo == 1 and mapa1[iArr][jIzq].tipo == 0 and mapa1[iAbaj][jIzq].tipo == 0) or (mapa1[math.floor(iAbaj)][math.floor(jDer)].tipo == 1 and mapa1[iArr][jIzq].tipo == 0 and mapa1[iAbaj][jIzq].tipo == 0) then
  
  local i1 = math.floor( ( ( cuerpoRecibido.y + n )/ tamCasillas ) + 0.4 )
  local i2 = math.floor( ( ( cuerpoRecibido.y - n + cuerpoRecibido.ancho) /tamCasillas ) + 0.4 )
  if mapa1[i1][jDer].tipo == 0 and mapa1[i2][jDer].tipo == 0 then
    return true
  else 
    return false
  end
  
else 
  return true
end
end

function revisarColisionesIzquierda(cuerpoRecibido)
local iArr = math.floor( (cuerpoRecibido.y/tamCasillas) + 0.4 )
local jDer = math.floor( ( (cuerpoRecibido.x+cuerpoRecibido.ancho) /tamCasillas)-0.3 )
local iAbaj = math.floor( ( (cuerpoRecibido.y+cuerpoRecibido.alto) /tamCasillas) +0.4  )
local jIzq = math.floor( (cuerpoRecibido.x/tamCasillas)-0.3 )
local n = 10

if jIzq==0 then 
  return false
  
elseif (mapa1[iArr][jIzq].tipo == 1 and mapa1[iAbaj][jIzq].tipo == 1) then
  return false
  
elseif (mapa1[iArr][jIzq].tipo == 1 and mapa1[iArr][jDer].tipo == 0 and mapa1[iAbaj][jDer].tipo == 0) or (mapa1[iAbaj][jIzq].tipo == 1 and mapa1[iArr][jDer].tipo == 0 and mapa1[iAbaj][jDer].tipo == 0) then
  
  local i1 = math.floor( ( ( cuerpoRecibido.y + n )/ tamCasillas ) + 0.4 )
  local i2 = math.floor( ( ( cuerpoRecibido.y - n + cuerpoRecibido.ancho) /tamCasillas ) + 0.4 )
  if mapa1[i1][jIzq].tipo == 0 and mapa1[i2][jIzq].tipo == 0 then
    return true
  else 
    return false
  end
  
else 
  return true
end
end

function revisarColisionesArriba(cuerpoRecibido)
local iArr = math.floor( (cuerpoRecibido.y/tamCasillas) + 0.4 )
local jDer = math.floor( ( (cuerpoRecibido.x+cuerpoRecibido.ancho) /tamCasillas)-0.3 )
local iAbaj = math.floor( ( (cuerpoRecibido.y+cuerpoRecibido.alto) /tamCasillas) +0.4  )
local jIzq = math.floor( (cuerpoRecibido.x/tamCasillas)-0.3 )
local n =  10

if iArr==0 then 
  return false
  
elseif (mapa1[iArr][jDer].tipo == 1 and mapa1[iArr][jIzq].tipo == 1)  then
  return false
  
elseif (mapa1[iArr][jDer].tipo == 1 and mapa1[iAbaj][jDer].tipo == 0 and mapa1[iAbaj][jIzq].tipo == 0 ) or (mapa1[iArr][jIzq].tipo == 1 and mapa1[iAbaj][jDer].tipo == 0 and mapa1[iAbaj][jIzq].tipo == 0 ) then
  
  local j1 = math.floor( ( ( cuerpoRecibido.x + n )/ tamCasillas ) - 0.3 )
  local j2 = math.floor( ( ( cuerpoRecibido.x-n+cuerpoRecibido.ancho) /tamCasillas ) - 0.3 )
  if mapa1[iArr][j1].tipo == 0 and mapa1[iArr][j2].tipo == 0 then
    return true
  else 
    return false
  end

else 
  return true
end
end

function revisarColisionesAbajo(cuerpoRecibido)
local iArr = math.floor( (cuerpoRecibido.y/tamCasillas) + 0.4 )
local jDer = math.floor( ( (cuerpoRecibido.x+cuerpoRecibido.ancho) /tamCasillas)-0.3 )
local iAbaj = math.floor( ( (cuerpoRecibido.y+cuerpoRecibido.alto) /tamCasillas) +0.4  )
local jIzq = math.floor( (cuerpoRecibido.x/tamCasillas)-0.3 )
local n = 10

if iAbaj==(labY+1) then 
  return false
  
elseif (mapa1[iAbaj][jDer].tipo == 1 and mapa1[iAbaj][jIzq].tipo == 1) then
  return false
  
elseif (mapa1[iAbaj][jDer].tipo == 1 and mapa1[iArr][jDer].tipo == 0 and mapa1[iArr][jIzq].tipo == 0) or (mapa1[iAbaj][jIzq].tipo == 1 and mapa1[iArr][jDer].tipo == 0 and mapa1[iArr][jIzq].tipo == 0)  then
  
  local j1 = math.floor( ( ( cuerpoRecibido.x + n )/ tamCasillas ) - 0.3 )
  local j2 = math.floor( ( ( cuerpoRecibido.x-n+cuerpoRecibido.ancho) /tamCasillas ) - 0.3 )
  if mapa1[iAbaj][j1].tipo == 0 and mapa1[iAbaj][j2].tipo == 0 then
    return true
  else 
    return false
  end
  
else
  return true
end
end