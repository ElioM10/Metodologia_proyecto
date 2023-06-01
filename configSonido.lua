
return {
	new = function()
		return {
      --Tabla de los botones del menu
			items = {},
			seleccionado = 1,
			animacFuera = 0,
      
      --Añade los items a la tabla
			anadirItem = function(self, item)
				table.insert(self.items, item)
			end,
      
      --Actualiza si el jugador ha decidido seleccionar otro item
			actualizar = function(self, dt)
				self.animacFuera = self.animacFuera / (1 + dt*10)
			end,
      --Dibuja el item en las coordenadas pasadas
			dibujar = function(self, x, y)
				local altura = 100
				local ancho = 480
				
        --Pone el color de los items
				love.graphics.setColor(0.4, 0.4, 0.4, 0.3)
        --Crea los rectangulos
				love.graphics.rectangle('fill', x-60, y + altura*(self.seleccionado-1) + (self.animacFuera * altura), ancho, altura)
				
        --Cambia los colores si el item es seleccionado
				for i, item in ipairs(self.items) do
					if self.seleccionado == i then
						love.graphics.setColor(1, 1, 1)
					else
						love.graphics.setColor(1, 1, 1)
					end
          --Dibuja el texto que debe ir en el item
					love.graphics.printf(item.nombre, x - 30, y + altura*(i-1) + 5, 600, "center", 0, .7, .7)
				end
			end,
      --Funcion si se ha apretado una tecla
			keypressed = function(self, key)
        --Si se apreta la felcha para arriba 
				if key == 'up' then
					if self.seleccionado > 1 then
            --Depende si el item seleccionado es el primero o no
						self.seleccionado = self.seleccionado - 1
						self.animacFuera = self.animacFuera + 1
					else
						self.seleccionado = #self.items
						self.animacFuera = self.animacFuera - (#self.items-1)
					end
          
          --Si la tecla presionada es la flecha hacia abajo
				elseif key == 'down' then
          --Depende si el item es el ultimo de la fila o no
					if self.seleccionado < #self.items then
						self.seleccionado = self.seleccionado + 1
						self.animacFuera = self.animacFuera - 1
					else
						self.seleccionado = 1
						self.animacFuera = self.animacFuera + (#self.items-1)
					end
				elseif key == 'return' then
					if self.items[self.seleccionado].accion then
						self.items[self.seleccionado]:accion()
					end
				elseif key == 'left' then
					if self.items[self.seleccionado].bajarVolumen then
						self.items[self.seleccionado]:bajarVolumen()
					end
				elseif key == 'right' then
					if self.items[self.seleccionado].subirVolumen then
						self.items[self.seleccionado]:subirVolumen()
					end
				end
			end
		}
	end
}