#==============================================================================
# Orquestador Principal del Mod
#==============================================================================

module Kernel
  def msgbox(*args); end
  def msgbox_p(*args); end
end

DIRECTORIO_MOD = File.dirname(__FILE__)

load File.join(DIRECTORIO_MOD, "Mods", "stats_hacks.rb")
load File.join(DIRECTORIO_MOD, "Mods", "items_hacks.rb")
load File.join(DIRECTORIO_MOD, "Mods", "spawner_hacks.rb")  # <-- NUEVA LÍNEA

load File.join(DIRECTORIO_MOD, "Menu", "cheat_menu.rb")

class << Graphics
  alias_method :mod_menu_update, :update
  def update
    mod_menu_update
    LonaHacks.actualizar_bucle rescue nil
    
    if Input.trigger?(:F9) && SceneManager.scene_is?(Scene_Map)
      Sound.play_ok rescue nil
      SceneManager.call(Scene_CheatMenu)
    end
  end
end