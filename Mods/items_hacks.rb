#==============================================================================
# Motor de Items - Permite ver y dar cualquier item, arma o armadura
#==============================================================================
module ItemHacks

  #----------------------------------------------------------------------
  # Limpia nombres como "Dataltem:Apple/item_name" o similares.
  # Extrae la parte central (lo que va despues de ':' y antes de '/').
  # Si no encuentra ese patron, devuelve el nombre original.
  #----------------------------------------------------------------------
  def self.clean_name(raw_name)
    if raw_name =~ /:([^\/]+)/
      return $1
    else
      return raw_name
    end
  end

  #----------------------------------------------------------------------
  # Devuelve todas las entradas de un tipo concreto (:item, :weapon, :armor)
  #----------------------------------------------------------------------
  def self.entries_by_type(type)
    all_entries.select { |e| e[:type] == type }
  end

  #----------------------------------------------------------------------
  # Construye (una sola vez) la lista completa de items, armas y armaduras.
  #----------------------------------------------------------------------
  def self.all_entries
    return @all_entries if @all_entries

    entries = []

    $data_items.each do |obj|
      next if obj.nil?
      next if obj.name.nil? || obj.name.empty?
      entries << {
        :type => :item,
        :id   => obj.id,
        :name => clean_name(obj.name),
        :icon => obj.icon_index
      }
    end

    $data_weapons.each do |obj|
      next if obj.nil?
      next if obj.name.nil? || obj.name.empty?
      entries << {
        :type => :weapon,
        :id   => obj.id,
        :name => clean_name(obj.name),
        :icon => obj.icon_index
      }
    end

    $data_armors.each do |obj|
      next if obj.nil?
      next if obj.name.nil? || obj.name.empty?
      entries << {
        :type => :armor,
        :id   => obj.id,
        :name => clean_name(obj.name),
        :icon => obj.icon_index
      }
    end

    @all_entries = entries
  end

  #----------------------------------------------------------------------
  # Devuelve el objeto real (RPG::Item / RPG::Weapon / RPG::Armor)
  #----------------------------------------------------------------------
  def self.get_object(entry)
    case entry[:type]
    when :item   then $data_items[entry[:id]]
    when :weapon then $data_weapons[entry[:id]]
    when :armor  then $data_armors[entry[:id]]
    end
  end

  #----------------------------------------------------------------------
  # Cuantas unidades tiene el grupo de esa entrada
  #----------------------------------------------------------------------
  def self.get_count(entry)
    obj = get_object(entry)
    return 0 unless obj
    $game_party.item_number(obj)
  end

  #----------------------------------------------------------------------
  # Suma o resta unidades (no baja de 0)
  #----------------------------------------------------------------------
  def self.adjust(entry, amount)
    obj = get_object(entry)
    return unless obj
    $game_party.gain_item(obj, amount)
  end

  #----------------------------------------------------------------------
  # Da "amount" unidades de absolutamente todo (por si se necesita)
  #----------------------------------------------------------------------
  def self.give_all(amount = 1)
    all_entries.each do |entry|
      adjust(entry, amount)
    end
  end
end
