#==============================================================================
# Spawner de NPCs - Usa reserve_summon_event del juego
#==============================================================================
module SpawnerHacks
  extend self

  DIR_NPC_DATA = "Data/NPCdata"

  # Devuelve un array con todos los nombres de NPCs encontrados
  def self.obtener_nombres_npcs
    return @nombres if @nombres
    @nombres = []
    Dir.glob(File.join(DIR_NPC_DATA, "*.json")).each do |archivo|
      contenido = File.read(archivo) rescue next
      contenido.scan(/"name"\s*:\s*"([^"]+)"/).each do |match|
        @nombres << match[0]
      end
    end
    @nombres.uniq.sort
  end

  # Invoca un NPC usando el metodo nativo del juego
  def self.invocar_npc(nombre)
    x = $game_player.x
    y = $game_player.y

    # Intentamos usar reserve_summon_event (como se ve en la consola)
    if $game_map.respond_to?(:reserve_summon_event)
      # En la consola aparece: reserve_summon_event :Nombre x=44 y=24
      # Probablemente acepta un simbolo o string, y coordenadas
      $game_map.reserve_summon_event(nombre, x, y)
      $game_message.add("Invocando #{nombre}...")
      return true
    else
      $game_message.add("Metodo reserve_summon_event no encontrado.")
      $game_message.add("Busca en Game_Map: def reserve_summon_event")
      return false
    end
  end
end