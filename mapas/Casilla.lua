--Objeto Casilla

Object = require("librerias/classic/classic")

Casilla = Object:extend() --Crea la clase Casilla que hereda de la clase Object, obtenida mediante la librería classic

function Casilla:new(f,c)  --constructor 
  self.f = f  --posición respecto a las filas, usualmente representado con i
  self.c = c  --posición respecto a las columnas, usualmente representado con j
  self.tipo = 0 --valor númerico que representa si será pared(1) o camino(0)
  self.visitada = false --valor boleano que guarda si la casilla ya ha sido visitada durante la generación del laberinto
end
