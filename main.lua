zombie = require "zombie"
Menu = require "menu"
config = require "config"
Pausa = require "pausa"
require("objetivos")
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
  musicaIntro = love.audio.newSource("musica/Origami Repetika - Quare Frolic.mp3", "stream")
  musicaJuego = love.audio.newSource("musica/Rolemusic - Pokimonkey.mp3", "stream")
  sonidoPerder = love.audio.newSource("musica/gameOverEffect.wav", "static")
  sonidoEfectoDisparo = love.audio.newSource("musica/firingEffect.wav", "static")
  sonidoGanar = love.audio.newSource("musica/shinyglittersoundeffect.wav", "static")
    
    musicaJuego:setVolume(0.2)
	
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
end