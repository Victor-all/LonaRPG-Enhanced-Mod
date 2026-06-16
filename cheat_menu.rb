#==============================================================================
# Interfaz Grafica Adaptativa - Menu de Trucos Pro
# (Muestra cantidad de items por categoria)
#==============================================================================

# Asegurate de tener en LonaHacks::MAIN_MENU_OPTIONS:
#   LonaHacks::MAIN_MENU_OPTIONS[:invocations] = "Invocaciones"

class Window_CheatMainMenu < Window_Command
  def window_width; return 180; end
  def make_command_list
    idx = 1
    LonaHacks::MAIN_MENU_OPTIONS.each do |key, name|
      add_command("#{idx}. #{name}", key)
      idx += 1
    end
  end
  def call_update_help; update_help; end
  def update_help
    if @scene && @scene.respond_to?(:update_main_selection)
      @scene.update_main_selection(current_symbol)
    end
  end
  def scene=(scene); @scene = scene; end
end

class Window_CheatSubMenu < Window_Command
  def initialize(x, y, width, height)
    @mode = :empty
    @filtered_entries = nil
    @npcs = nil
    @fixed_width = width
    @fixed_height = height
    super(x, y)
    deactivate
    unselect
  end
  def window_width; return @fixed_width; end
  def window_height; return @fixed_height; end

  def setup_view(mode, filter = nil)
    if @mode == mode && @list.size > 0
      select(0)
      return
    end
    @mode = mode
    @filter = filter
    @filtered_entries = nil
    @npcs = nil
    @list.clear
    make_command_list
    create_contents
    refresh
    select(0) if @mode != :empty
  end

  def make_command_list
    case @mode
    when :stat_list
      LonaHacks::CATEGORIES.each do |key, data|
        data[:keys].each do |sym|
          add_command(LonaHacks.display_name(sym), sym)
        end
      end
    when :item_category
      # Calculamos las cantidades de cada tipo
      counts = {
        items:   ItemHacks.entries_by_type(:item).size,
        weapons: ItemHacks.entries_by_type(:weapon).size,
        armors:  ItemHacks.entries_by_type(:armor).size
      }
      add_command("Generales (#{counts[:items]})", :items)
      add_command("Armas (#{counts[:weapons]})",    :weapons)
      add_command("Armaduras (#{counts[:armors]})", :armors)
    when :item_list
      @filtered_entries = ItemHacks.entries_by_type(@filter)
      @filtered_entries.each_with_index do |entry, idx|
        add_command(entry[:name], :item_entry, true, idx)
      end
    when :invocation_list
      @npcs = SpawnerHacks.obtener_nombres_npcs
      @npcs.each do |nombre|
        add_command(nombre, :invocation_entry, true)
      end
    end
  end

  def draw_item(index)
    return if index < 0 || index >= @list.size
    rect = item_rect(index)
    change_color(normal_color, command_enabled?(index))
    case @mode
    when :item_list
      entry = @filtered_entries[index]
      return unless entry
      if entry[:icon] && entry[:icon] > 0
        draw_icon(entry[:icon], rect.x, rect.y, command_enabled?(index))
        text_x = rect.x + 24 + 2
        text_w = rect.width - 24 - 2
      else
        text_x = rect.x
        text_w = rect.width
      end
      draw_text(Rect.new(text_x, rect.y, text_w, rect.height), entry[:name], 0)
      draw_text(rect, ItemHacks.get_count(entry).to_s, 2)
    when :stat_list
      draw_text(rect, command_name(index), 0)
      sym = @list[index][:symbol]
      draw_text(rect, LonaHacks.get_status_text(sym.to_s), 2)
    else
      draw_text(rect, command_name(index), 0)
    end
  end

  def redraw_item(index)
    return if index < 0 || index >= @list.size
    contents.clear_rect(item_rect(index))
    draw_item(index)
  end

  def current_item_entry
    return nil unless @mode == :item_list && @filtered_entries
    @filtered_entries[index]
  end

  def current_npc_name
    return nil unless @mode == :invocation_list && @npcs
    @npcs[index]
  end

  def cursor_right(wrap = false)
    if @mode == :stat_list
      sym = current_symbol
      if sym && $cheat_values[sym.to_s].is_a?(Integer)
        paso = (sym == :gold ? 500 : 5)
        LonaHacks.adjust_value(sym.to_s, paso)
        Sound.play_cursor rescue nil
        redraw_item(index)
        return
      end
    elsif @mode == :item_list
      entry = current_item_entry
      if entry
        ItemHacks.adjust(entry, 1)
        Sound.play_cursor rescue nil
        redraw_item(index)
        return
      end
    end
    super
  end

  def cursor_left(wrap = false)
    if @mode == :stat_list
      sym = current_symbol
      if sym && $cheat_values[sym.to_s].is_a?(Integer)
        paso = (sym == :gold ? -500 : -5)
        LonaHacks.adjust_value(sym.to_s, paso)
        Sound.play_cursor rescue nil
        redraw_item(index)
        return
      end
    elsif @mode == :item_list
      entry = current_item_entry
      if entry
        ItemHacks.adjust(entry, -1)
        Sound.play_cursor rescue nil
        redraw_item(index)
        return
      end
    end
    super
  end
end

class Window_CheatHeader < Window_Base
  def initialize(x, y, w, h, text); super(x, y, w, h); @text = text; refresh; end
  def refresh; contents.clear; change_color(system_color); draw_text(0, 0, contents.width, contents.height, @text, 1); end
end

class Window_CheatMessage < Window_Base
  def initialize(x, y, w, h, text); super(x, y, w, h); @text = text; refresh; end
  def refresh; contents.clear; change_color(normal_color); draw_text(0, (contents.height - line_height)/2, contents.width, line_height, @text, 1); end
end

class Scene_CheatMenu < Scene_MenuBase
  def start
    super
    @is_ready = false
    padding = 8
    h_title = 48
    w_main = 180
    w_sub = Graphics.width - w_main - (padding * 3)
    h_content = Graphics.height - h_title - (padding * 3)
    x_left = padding
    x_right = x_left + w_main + padding
    y_top = padding
    y_content = y_top + h_title + padding

    @title_window = Window_CheatHeader.new(x_left, y_top, Graphics.width - (padding*2), h_title, "Menu de Trucos")
    @main_window = Window_CheatMainMenu.new(x_left, y_content)
    @main_window.height = h_content
    @main_window.scene = self
    @main_window.set_handler(:ok, method(:on_main_ok))
    @main_window.set_handler(:cancel, method(:return_scene))
    @sub_window = Window_CheatSubMenu.new(x_right, y_content, w_sub, h_content)
    @sub_window.set_handler(:ok, method(:on_sub_ok))
    @sub_window.set_handler(:cancel, method(:on_sub_cancel))
    @msg_window = Window_CheatMessage.new(x_right, y_content, w_sub, h_content, "Seleccione una categoria")

    @current_step = :main_menu
    @is_ready = true
    @main_window.activate
    @main_window.select(0)
  end

  def ready?; @is_ready && @sub_window && @msg_window; end

  def update_main_selection(symbol)
    return unless ready?
    case symbol
    when :stats
      @msg_window.hide; @sub_window.show; @sub_window.setup_view(:stat_list); @sub_window.unselect
    when :items
      @msg_window.hide; @sub_window.show; @sub_window.setup_view(:item_category); @sub_window.unselect
    when :invocations
      @msg_window.hide; @sub_window.show; @sub_window.setup_view(:invocation_list); @sub_window.unselect
    else
      @sub_window.hide; @msg_window.show
      @msg_window.contents.clear rescue nil
      if @msg_window.contents
        @msg_window.draw_text(0, (@msg_window.contents.height - 24)/2, @msg_window.contents.width, 24, "Seleccione una categoria", 1)
      end
    end
  end

  def on_main_ok
    case @main_window.current_symbol
    when :stats
      @main_window.deactivate; @sub_window.activate; @sub_window.select(0); @current_step = :stat_list
    when :items
      @main_window.deactivate; @sub_window.activate; @sub_window.select(0); @current_step = :item_category
    when :invocations
      @main_window.deactivate; @sub_window.activate; @sub_window.select(0); @current_step = :invocation_list
    when :cancel then return_scene
    end
  end

  def on_sub_ok
    case @current_step
    when :stat_list
      sym = @sub_window.current_symbol
      if sym
        LonaHacks.cycle_mode(sym.to_s)
        Sound.play_ok rescue nil
        @sub_window.redraw_item(@sub_window.index)
      end
      @sub_window.activate
    when :item_category
      filtro = case @sub_window.current_symbol
               when :items then :item; when :weapons then :weapon; when :armors then :armor
               end
      @sub_window.setup_view(:item_list, filtro)
      @sub_window.activate; @current_step = :item_list
    when :item_list
      entry = @sub_window.current_item_entry
      if entry
        ItemHacks.adjust(entry, 10)
        Sound.play_ok rescue nil
        @sub_window.redraw_item(@sub_window.index)
      end
      @sub_window.activate
    when :invocation_list
      nombre = @sub_window.current_npc_name
      if nombre
        if SpawnerHacks.invocar_npc(nombre)
          Sound.play_ok rescue nil
        else
          Sound.play_buzzer rescue nil
        end
        return_scene
      else
        @sub_window.activate
      end
    end
  end

  def on_sub_cancel
    case @current_step
    when :stat_list, :invocation_list
      @current_step = :main_menu; @sub_window.unselect; @main_window.activate
    when :item_list
      @current_step = :item_category; @sub_window.setup_view(:item_category); @sub_window.activate
    when :item_category
      @current_step = :main_menu; @sub_window.unselect; @main_window.activate
    end
  end

  def terminate
    super
    @title_window.dispose if @title_window
    @main_window.dispose if @main_window
    @sub_window.dispose if @sub_window
    @msg_window.dispose if @msg_window
  end
end

#==============================================================================
# Motor de Items - (se mantiene igual)
#==============================================================================
module ItemHacks

  def self.clean_name(raw_name)
    if raw_name =~ /:([^\/]+)/
      return $1
    else
      return raw_name
    end
  end

  def self.entries_by_type(type)
    all_entries.select { |e| e[:type] == type }
  end

  def self.all_entries
    return @all_entries if @all_entries
    entries = []

    $data_items.each do |obj|
      next if obj.nil? || obj.name.nil? || obj.name.empty?
      entries << { :type => :item, :id => obj.id, :name => clean_name(obj.name), :icon => obj.icon_index }
    end

    $data_weapons.each do |obj|
      next if obj.nil? || obj.name.nil? || obj.name.empty?
      entries << { :type => :weapon, :id => obj.id, :name => clean_name(obj.name), :icon => obj.icon_index }
    end

    $data_armors.each do |obj|
      next if obj.nil? || obj.name.nil? || obj.name.empty?
      entries << { :type => :armor, :id => obj.id, :name => clean_name(obj.name), :icon => obj.icon_index }
    end

    @all_entries = entries
  end

  def self.get_object(entry)
    case entry[:type]
    when :item   then $data_items[entry[:id]]
    when :weapon then $data_weapons[entry[:id]]
    when :armor  then $data_armors[entry[:id]]
    end
  end

  def self.get_count(entry)
    obj = get_object(entry)
    return 0 unless obj
    $game_party.item_number(obj)
  end

  def self.adjust(entry, amount)
    obj = get_object(entry)
    return unless obj
    $game_party.gain_item(obj, amount)
  end

  def self.give_all(amount = 1)
    all_entries.each { |entry| adjust(entry, amount) }
  end
end