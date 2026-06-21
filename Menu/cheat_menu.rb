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
    @selected_index = nil       # para items
    @selected_stat_index = nil  # para estadisticas
    @invoke_counts = {}  # Almacena la cantidad por índice de NPC
    @invoke_selected_index = nil
    super(x, y)
    deactivate
    unselect
  end

  # Métodos para obtener y establecer cantidad
  def get_invoke_count(index)
    @invoke_counts[index] ||= 1
  end

  def set_invoke_count(index, value)
    @invoke_counts[index] = [[value, 1].max, 99].min
    redraw_item(index) if index >= 0 && index < @list.size
  end

  def is_invoke_selected?(index)
    @invoke_selected_index == index
  end

  def toggle_invoke_selection(index)
    if @invoke_selected_index == index
      @invoke_selected_index = nil
    else
      @invoke_selected_index = index
    end
    refresh
  end

  def window_width; return @fixed_width; end
  def window_height; return @fixed_height; end

  # --- Metodos de seleccion para items ---
  def select_item
    return unless @mode == :item_list && @filtered_entries
    @selected_index = index
    refresh
  end

  def deselect_item
    @selected_index = nil
    refresh
    select(index) if index >= 0 && index < @list.size
  end

  def selected_index
    @selected_index
  end

  # --- Metodos de seleccion para estadisticas (solo visual) ---
  def select_stat
    return unless @mode == :stat_list
    @selected_stat_index = index
    refresh
  end

  def deselect_stat
    @selected_stat_index = nil
    refresh
  end

  def selected_stat_index
    @selected_stat_index
  end

  # --- Configuracion de vista ---
  def setup_view(mode, filter = nil)
    @invoke_counts = {}
    @invoke_selected_index = nil
    @selected_index = nil
    @selected_stat_index = nil
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

  # --- Construccion de la lista de comandos ---
  def make_command_list
    case @mode
    when :stat_list
      LonaHacks::CATEGORIES.each do |key, data|
        # Titulo de categoria (no seleccionable)
        add_command(data[:name], :category_title, false)
        # Estadisticas de la categoria
        data[:keys].each do |sym|
          add_command(LonaHacks.display_name(sym), sym)
        end
      end
    when :item_category
      items_count = ItemHacks.entries_by_type(:item).size
      weapons_count = ItemHacks.entries_by_type(:weapon).size
      armors_count = ItemHacks.entries_by_type(:armor).size

      add_command("Generales", :items, true)
      add_command("Armas", :weapons, true)
      add_command("Armaduras", :armors, true)

      @category_counts = {
        :items => items_count,
        :weapons => weapons_count,
        :armors => armors_count
      }
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
    when :teleport_list
      @teleport_names = TeleportHack.names
      @teleport_names.each do |name|
        add_command(name, :teleport_entry, true)
      end
    end
  end

  # --- Dibujo de cada elemento ---
  def draw_item(index)
    return if index < 0 || index >= @list.size
    rect = item_rect(index)
    change_color(normal_color, command_enabled?(index))

    case @mode
    when :stat_list
      sym = @list[index][:symbol]
      if sym == :category_title
        # Titulo de categoria: color de sistema, centrado y separador
        change_color(system_color, command_enabled?(index))
        draw_text(rect, command_name(index), 1)
        # Linea separadora
        rect_line = rect.clone
        rect_line.y += rect.height - 2
        rect_line.height = 1
        contents.fill_rect(rect_line, Color.new(100, 100, 100, 128))
        change_color(normal_color, command_enabled?(index))
      else
        # Estadistica
        draw_text(rect, command_name(index), 0)
        estado = LonaHacks.get_status_text(sym.to_s)
        if $cheat_values[sym.to_s].is_a?(Integer)
          draw_text(rect, estado, 2)
          if estado =~ /(<\d+>)/
            numero = $1
            change_color(system_color, command_enabled?(index))
            draw_text(rect, numero, 2)
            change_color(normal_color, command_enabled?(index))
          end
        else
          draw_text(rect, estado, 2)
        end
      end

    when :item_category
      draw_text(rect, command_name(index), 0)
      sym = @list[index][:symbol]
      count = case sym
              when :items then @category_counts[:items] || 0
              when :weapons then @category_counts[:weapons] || 0
              when :armors then @category_counts[:armors] || 0
              else 0
              end
      change_color(system_color, command_enabled?(index))
      draw_text(rect, "#{count} objetos", 2)
      change_color(normal_color, command_enabled?(index))

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

      cantidad = ItemHacks.get_count(entry).to_s
      if @selected_index == index
        change_color(system_color, command_enabled?(index))
        draw_text(rect, "<#{cantidad}>", 2)
        change_color(normal_color, command_enabled?(index))
      else
        draw_text(rect, cantidad, 2)
      end

    when :teleport_list
      text = command_name(index)
      if text.start_with?("[T]")
        change_color(Color.new(100, 255, 100), command_enabled?(index))  # Verde para Tags
      elsif text.start_with?("[U]")
        change_color(Color.new(255, 255, 100), command_enabled?(index))  # Amarillo para Ubicaciones
      elsif text.start_with?("[F]")
        change_color(Color.new(255, 215, 0), command_enabled?(index))    # Dorado para Funciones
      else
        change_color(normal_color, command_enabled?(index))
      end
      draw_text(rect, text, 0)

    when :invocation_list
      text = command_name(index)
      count = get_invoke_count(index)

      # Color blanco siempre
      change_color(normal_color, command_enabled?(index))
      draw_text(rect, text, 0)
      # Mostrar cantidad a la derecha en blanco
      change_color(normal_color, command_enabled?(index))
      draw_text(rect, "x#{count}", 2)

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

  def current_teleport_index
    return nil unless @mode == :teleport_list
    index
  end

  # --- Navegacion con seleccion ---
  def cursor_up(wrap = false)
    return if @selected_index
    # En estadisticas, saltar titulos de categoria
    if @mode == :stat_list
      idx = index
      while idx > 0
        idx -= 1
        break if @list[idx][:symbol] != :category_title
      end
      if idx != index
        select(idx)
        return
      end
    end
    super
  end

  def cursor_down(wrap = false)
    return if @selected_index
    # En estadisticas, saltar titulos de categoria
    if @mode == :stat_list
      idx = index
      while idx < @list.size - 1
        idx += 1
        break if @list[idx][:symbol] != :category_title
      end
      if idx != index
        select(idx)
        return
      end
    end
    super
  end

  def cursor_right(wrap = false)
    if @mode == :invocation_list && @invoke_selected_index
      idx = @invoke_selected_index
      new_count = get_invoke_count(idx) + 1
      set_invoke_count(idx, new_count)
      Sound.play_cursor rescue nil
      return
    end

    if @selected_index && @mode == :item_list
      entry = @filtered_entries[@selected_index]
      if entry
        ItemHacks.adjust(entry, 1)
        Sound.play_cursor rescue nil
        redraw_item(@selected_index)
        return
      end
    end

    if @mode == :stat_list
      sym = current_symbol
      if sym && sym != :category_title && $cheat_values[sym.to_s].is_a?(Integer)
        paso = (sym == :gold ? 500 : 5)
        LonaHacks.adjust_value(sym.to_s, paso)
        Sound.play_cursor rescue nil
        redraw_item(index)
        return
      end
    end

    if @mode == :invocation_list
      idx = index
      if idx >= 0
        new_count = get_invoke_count(idx) + 1
        set_invoke_count(idx, new_count)
        Sound.play_cursor rescue nil
        return
      end
    end

    super
  end

  def cursor_left(wrap = false)
    if @mode == :invocation_list && @invoke_selected_index
      idx = @invoke_selected_index
      new_count = get_invoke_count(idx) - 1
      set_invoke_count(idx, new_count)
      Sound.play_cursor rescue nil
      return
    end

    if @selected_index && @mode == :item_list
      entry = @filtered_entries[@selected_index]
      if entry
        ItemHacks.adjust(entry, -1)
        Sound.play_cursor rescue nil
        redraw_item(@selected_index)
        return
      end
    end

    if @mode == :stat_list
      sym = current_symbol
      if sym && sym != :category_title && $cheat_values[sym.to_s].is_a?(Integer)
        paso = (sym == :gold ? -500 : -5)
        LonaHacks.adjust_value(sym.to_s, paso)
        Sound.play_cursor rescue nil
        redraw_item(index)
        return
      end
    end

    if @mode == :invocation_list
      idx = index
      if idx >= 0
        new_count = get_invoke_count(idx) - 1
        set_invoke_count(idx, new_count)
        Sound.play_cursor rescue nil
        return
      end
    end

    super
  end

  # --- Manejo de Enter y Ctrl+Enter ---
  def process_ok
    case @mode
    when :item_list
      if @selected_index.nil?
        select_item
      else
        deselect_item
      end
      return
    when :stat_list
      # Ignorar si es un titulo de categoria
      return if current_symbol == :category_title
      if Input.press?(:CTRL) && Input.trigger?(:ENTER)
        if @selected_stat_index.nil?
          select_stat
        else
          deselect_stat
        end
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

    @current_step = :main_menu
    @is_ready = true
    @main_window.activate
    @main_window.select(0)
  end

  def ready?; @is_ready && @sub_window; end

  def update_main_selection(symbol)
    return unless ready?
    case symbol
    when :stats
      @sub_window.show
      @sub_window.setup_view(:stat_list)
      @sub_window.unselect
    when :items
      @sub_window.show
      @sub_window.setup_view(:item_category)
      @sub_window.unselect
    when :invocations
      @sub_window.show
      @sub_window.setup_view(:invocation_list)
      @sub_window.unselect
    when :teleport
      @sub_window.show
      @sub_window.setup_view(:teleport_list)
      @sub_window.unselect
    else
      @sub_window.hide
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
    when :teleport
      @main_window.deactivate; @sub_window.activate; @sub_window.select(0); @current_step = :teleport_list
    when :cancel then return_scene
    end
  end

  def on_sub_ok
    case @current_step
    when :stat_list
      sym = @sub_window.current_symbol
      if sym && sym != :category_title
        if @sub_window.selected_stat_index
          @sub_window.deselect_stat
        end
        LonaHacks.cycle_mode(sym.to_s)
        Sound.play_ok rescue nil
        @sub_window.redraw_item(@sub_window.index)
      end
      @sub_window.activate
    when :item_category
      filtro = case @sub_window.current_symbol
               when :items then :item
               when :weapons then :weapon
               when :armors then :armor
               end
      @sub_window.setup_view(:item_list, filtro)
      @sub_window.activate
      @current_step = :item_list
    when :item_list
      @sub_window.activate
    when :invocation_list
      idx = @sub_window.index
      nombre = @sub_window.current_npc_name
      if nombre && idx >= 0
        cantidad = @sub_window.get_invoke_count(idx)
        if SpawnerHacks.invocar_npc(nombre, cantidad)
          Sound.play_ok rescue nil
        else
          Sound.play_buzzer rescue nil
        end
        return_scene
      else
        @sub_window.activate
      end
    when :teleport_list
      idx = @sub_window.current_teleport_index
      if idx
        TeleportHack.execute(idx)
        Sound.play_ok rescue nil
        return_scene
      else
        @sub_window.activate
      end
    end
  end

  def on_sub_cancel
    case @current_step
    when :stat_list
      if @sub_window.selected_stat_index
        @sub_window.deselect_stat
        @sub_window.activate
      else
        @current_step = :main_menu
        @sub_window.unselect
        @main_window.activate
      end
    when :invocation_list
      @current_step = :main_menu
      @sub_window.unselect
      @main_window.activate
    when :teleport_list
      @current_step = :main_menu
      @sub_window.unselect
      @main_window.activate
    when :item_list
      if @sub_window.selected_index
        @sub_window.deselect_item
        @sub_window.activate
      else
        @current_step = :item_category
        @sub_window.setup_view(:item_category)
        @sub_window.activate
      end
    when :item_category
      @current_step = :main_menu
      @sub_window.unselect
      @main_window.activate
    end
  end

  def terminate
    super
    @title_window.dispose if @title_window
    @main_window.dispose if @main_window
    @sub_window.dispose if @sub_window
  end
end
