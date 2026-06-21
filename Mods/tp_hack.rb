# =============================================================================
# tp_hack.rb - Modulo de Teletransporte para LonaRPG
# =============================================================================

module TeleportHack
  # Almacen de ubicaciones personalizadas
  def self.custom_locations
    $tp_custom_locations ||= []
  end

  # -------------------------------------------------------------------------
  # Funcion principal de teletransporte (estable, sin congelar)
  # -------------------------------------------------------------------------
  def self.teleport_to(map_id, x, y)
    $game_map.setup(map_id)
    $game_player.moveto(x, y)
    $game_map.refresh if $game_map.respond_to?(:refresh)
    $game_player.refresh
    print "Teletransportado a mapa #{map_id} (#{x}, #{y})"
    true
  rescue => e
    print "Error: #{e.message}"
    false
  end

  # -------------------------------------------------------------------------
  # Teletransporte a un tag (usando $data_tag_maps)
  # -------------------------------------------------------------------------
  def self.teleport_to_tag(tag)
    map_ids = $data_tag_maps[tag]
    return false unless map_ids && map_ids.is_a?(Array) && map_ids.any?

    map_id = map_ids.first
    x = 0
    y = 0
    begin
      temp_map = load_data(sprintf("Data/Map%03d.rvdata2", map_id))
      if temp_map
        x = temp_map.start_x || 0
        y = temp_map.start_y || 0
      end
    rescue
      x = 0
      y = 0
    end
    teleport_to(map_id, x, y)
    print "Teletransportado a tag: #{tag}"
    true
  rescue => e
    print "Error al teletransportar a tag: #{e.message}"
    false
  end

  # -------------------------------------------------------------------------
  # Guardar y volver a ubicacion temporal
  # -------------------------------------------------------------------------
  def self.save_location
    $tp_origin_map = $game_map.map_id
    $tp_origin_x    = $game_player.x
    $tp_origin_y    = $game_player.y
    print "Ubicacion temporal guardada."
  end

  def self.return_to_saved_location
    if $tp_origin_map
      teleport_to($tp_origin_map, $tp_origin_x, $tp_origin_y)
      $tp_origin_map = nil
    else
      print "No hay ubicacion temporal guardada."
    end
  end

  # -------------------------------------------------------------------------
  # Gestion de ubicaciones personalizadas
  # -------------------------------------------------------------------------
  def self.add_current_location(name)
    loc = {
      name: name,
      map_id: $game_map.map_id,
      x: $game_player.x,
      y: $game_player.y
    }
    custom_locations << loc
    print "Ubicacion '#{name}' guardada."
  end

  def self.delete_location(index)
    if index >= 0 && index < custom_locations.size
      removed = custom_locations.delete_at(index)
      print "Ubicacion '#{removed[:name]}' eliminada."
    else
      print "Indice invalido."
    end
  end

  # -------------------------------------------------------------------------
  # Interfaz para el menu de trucos (con prefijos visuales)
  # -------------------------------------------------------------------------
  def self.names
    tag_names = []
    if defined?($data_tag_maps) && $data_tag_maps.is_a?(Hash)
      tag_names = $data_tag_maps.keys.select { |k| $data_tag_maps[k].is_a?(Array) && $data_tag_maps[k].any? }
    end

    custom_names = custom_locations.map { |loc| loc[:name] }
    fixed = ["[F] Guardar ubicacion temporal", "[F] Volver a guardada", "[F] Agregar ubicacion actual"]

    tag_names.map { |tag| "[T] #{tag}" } + custom_names.map { |name| "[U] #{name}" } + fixed
  end

  def self.execute(index)
    tag_names = []
    if defined?($data_tag_maps) && $data_tag_maps.is_a?(Hash)
      tag_names = $data_tag_maps.keys.select { |k| $data_tag_maps[k].is_a?(Array) && $data_tag_maps[k].any? }
    end

    total_tags = tag_names.size
    total_custom = custom_locations.size
    total_fixed = 3

    if index < total_tags
      teleport_to_tag(tag_names[index])
    elsif index < total_tags + total_custom
      loc_index = index - total_tags
      loc = custom_locations[loc_index]
      teleport_to(loc[:map_id], loc[:x], loc[:y])
    elsif index < total_tags + total_custom + total_fixed
      fixed_index = index - (total_tags + total_custom)
      case fixed_index
      when 0 then save_location
      when 1 then return_to_saved_location
      when 2
        new_index = custom_locations.size + 1
        name = "Ubicacion #{new_index}"
        add_current_location(name)
      end
    else
      print "Opcion invalida"
    end
  end

  # -------------------------------------------------------------------------
  # Registro en el menu principal (lo coloca al inicio, SIN simbolos raros)
  # -------------------------------------------------------------------------
  def self.register
    # Mover la opcion :teleport al principio
    if LonaHacks::MAIN_MENU_OPTIONS[:teleport]
      LonaHacks::MAIN_MENU_OPTIONS.delete(:teleport)
    end
    new_options = {}
    new_options[:teleport] = "Teletransporte"   # <-- sin ">"
    LonaHacks::MAIN_MENU_OPTIONS.each do |k, v|
      new_options[k] = v if k != :teleport
    end
    LonaHacks::MAIN_MENU_OPTIONS.replace(new_options)

    print "Modulo de Teletransporte cargado."
  end
end

# Auto-registro al cargar el archivo
TeleportHack.register
