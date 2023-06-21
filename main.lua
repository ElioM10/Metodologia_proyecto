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
  jugador.velocidad = 180
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
          love.graphics.setNewFont("fuentes/Pixelmania.TTF", 45)
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
        love.graphics.setNewFont("fuentes/Pixelmania.TTF", 45)
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