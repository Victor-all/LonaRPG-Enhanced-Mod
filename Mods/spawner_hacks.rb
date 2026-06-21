#==============================================================================
# Spawner de NPCs - Usa reserve_summon_event del juego
#==============================================================================
module SpawnerHacks
  extend self

  DIR_NPC_DATA = "Data/NPCdata"

  # -------------------------------------------------------------------------
  # Devuelve un array con todos los nombres de NPCs (unicos y ordenados)
  # -------------------------------------------------------------------------
  def self.obtener_nombres_npcs
    return @nombres if @nombres

    @nombres = []
    Dir.glob(File.join(DIR_NPC_DATA, "*.json")).each do |archivo|
      begin
        contenido = File.read(archivo)
        contenido.scan(/"name"\s*:\s*"([^"]+)"/).each do |match|
          @nombres << match[0]
        end
      rescue
        # Si falla la lectura de un archivo, lo ignoramos
      end
    end

    @nombres.uniq.sort
  end

  # -------------------------------------------------------------------------
  # Invoca un NPC varias veces (con manejo de errores)
  # -------------------------------------------------------------------------
  def self.invocar_npc(nombre, cantidad = 1)
    return false if cantidad <= 0

    if $game_map.respond_to?(:reserve_summon_event)
      x = $game_player.x
      y = $game_player.y

      begin
        cantidad.times do |i|
          $game_map.reserve_summon_event(nombre, x + rand(3) - 1, y + rand(3) - 1)
        end
        $game_message.add("Invocando #{cantidad} #{nombre}...")
        return true
      rescue => e
        $game_message.add("Error al invocar: #{e.message}")
        return false
      end
    else
      $game_message.add("Metodo reserve_summon_event no encontrado.")
      return false
    end
  end
end
