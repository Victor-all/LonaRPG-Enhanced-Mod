#==============================================================================
# Motor de Inyeccion de Stats Pro - Version Final (Valores Manuales Congelados)
#==============================================================================
module LonaHacks

  MAIN_MENU_OPTIONS = {
    :stats => "Estadisticas",
    :items => "Items",
    :invocations => "Invocaciones",
    :cancel => "Cerrar Menu"
  }

  CATEGORIES = {
    :vitales => {
      :name => "Vitales / General",
      :keys => [:health, :sta, :sat, :mood, :will, :weak, :sexy, :dirt,
                :move_speed, :gold]
    },
    :combate => {
      :name => "Combate",
      :keys => [:atk, :def, :atk_plus, :def_plus, :dodge_frame]
    },
    :habilidades => {
      :name => "Habilidades Base",
      :keys => [:constitution, :survival, :wisdom, :combat, :scoutcraft]
    },
    :habilidades_plus => {
      :name => "Habilidades (Bonus +)",
      :keys => [:constitution_plus, :survival_plus, :wisdom_plus,
                :combat_plus, :scoutcraft_plus]
    },
    :habilidades_trait => {
      :name => "Habilidades (Rasgos)",
      :keys => [:constitution_trait, :survival_trait, :wisdom_trait,
                :combat_trait, :scoutcraft_trait]
    },
    :sexual => {
      :name => "Estadisticas Sexuales",
      :keys => [:sex_vag_atk, :sex_anal_atk, :sex_mouth_atk, :sex_limbs_atk,
                :arousal, :melaninNipple, :melaninVag, :melaninAnal]
    },
    :corporal => {
      :name => "Necesidades / Dano Corporal",
      :keys => [:pee_request, :poo_request, :urinary_level, :defecate_level,
                :lactation_level, :itch_level, :puke_value_normal,
                :vag_damage, :urinary_damage, :anal_damage]
    },
    :adicciones => {
      :name => "Adicciones",
      :keys => [:drug_addiction_level, :ograsm_addiction_level, :semen_addiction_level,
                :drug_addiction_damage, :ograsm_addiction_damage, :semen_addiction_damage]
    },
    :reproduccion => {
      :name => "Reproduccion / Moralidad",
      :keys => [:state_preg_rate, :baby_health, :morality, :morality_plus, :morality_lona]
    },
    :identidad => {
      :name => "Identidad",
      :keys => [:sex, :persona, :race]
    }
  }

  NUMERIC_KEYS = CATEGORIES.values.flat_map { |c| c[:keys] } - [:sex, :persona, :race]
  IDENTITY_KEYS = [:sex, :persona, :race]

  DISPLAY_NAMES = {
    :health               => "Vida",
    :sta                  => "Estamina",
    :sat                  => "Saciedad",
    :mood                 => "Humor",
    :move_speed           => "Velocidad",
    :will                 => "Voluntad",
    :weak                 => "Debilidad",
    :sexy                 => "Sensualidad",
    :dirt                 => "Suciedad",
    :gold                 => "Oro",

    :atk                  => "Ataque",
    :def                  => "Defensa",
    :atk_plus             => "Ataque +",
    :def_plus             => "Defensa +",
    :dodge_frame          => "Esquive (frames)",

    :constitution         => "Constitucion",
    :survival             => "Supervivencia",
    :wisdom               => "Sabiduria",
    :combat               => "Combate",
    :scoutcraft           => "Sigilo",

    :constitution_plus    => "Constitucion +",
    :survival_plus        => "Supervivencia +",
    :wisdom_plus          => "Sabiduria +",
    :combat_plus          => "Combate +",
    :scoutcraft_plus      => "Sigilo +",

    :constitution_trait   => "Rasgo Constitucion",
    :survival_trait       => "Rasgo Supervivencia",
    :wisdom_trait         => "Rasgo Sabiduria",
    :combat_trait         => "Rasgo Combate",
    :scoutcraft_trait     => "Rasgo Sigilo",

    :sex_vag_atk          => "Ataque Vaginal",
    :sex_anal_atk         => "Ataque Anal",
    :sex_mouth_atk        => "Ataque Oral",
    :sex_limbs_atk        => "Ataque Manual",
    :arousal              => "Excitacion",
    :melaninNipple        => "Pigment. Pezones",
    :melaninVag           => "Pigment. Vagina",
    :melaninAnal          => "Pigment. Anal",

    :pee_request          => "Necesidad Orinar",
    :poo_request          => "Necesidad Defecar",
    :urinary_level        => "Nivel Vesical",
    :defecate_level       => "Nivel Intestinal",
    :lactation_level      => "Nivel Lactancia",
    :itch_level           => "Nivel Picazon",
    :puke_value_normal    => "Valor Vomito",
    :vag_damage           => "Dano Vaginal",
    :urinary_damage       => "Dano Urinario",
    :anal_damage          => "Dano Anal",

    :drug_addiction_level    => "Adic. Drogas (Nivel)",
    :ograsm_addiction_level  => "Adic. Orgasmo (Nivel)",
    :semen_addiction_level   => "Adic. Semen (Nivel)",
    :drug_addiction_damage   => "Adic. Drogas (Dano)",
    :ograsm_addiction_damage => "Adic. Orgasmo (Dano)",
    :semen_addiction_damage  => "Adic. Semen (Dano)",

    :state_preg_rate      => "Tasa Embarazo",
    :baby_health          => "Vida del Bebe",
    :morality             => "Moralidad",
    :morality_plus        => "Moralidad +",
    :morality_lona        => "Moralidad Lona",

    :sex                  => "Sexo",
    :persona              => "Personalidad",
    :race                 => "Raza"
  }

  MAX_VALUES = {
    :gold                     => 999999,
    :melaninNipple            => 255,
    :melaninVag               => 255,
    :melaninAnal              => 255,
    :arousal                  => 100,
    :dodge_frame              => 60,
    :vag_damage               => 100,
    :urinary_damage           => 100,
    :anal_damage              => 100,
    :urinary_level            => 100,
    :defecate_level           => 100,
    :lactation_level          => 100,
    :itch_level               => 100,
    :puke_value_normal        => 100,
    :pee_request              => 1,
    :poo_request              => 1,
    :state_preg_rate          => 100,
    :drug_addiction_level     => 100,
    :ograsm_addiction_level   => 100,
    :semen_addiction_level    => 100,
    :drug_addiction_damage    => 100,
    :ograsm_addiction_damage  => 100,
    :semen_addiction_damage   => 100
  }

  MIN_VALUES = {
    :morality      => -999,
    :morality_plus => -999,
    :morality_lona => -999,
    :atk_plus      => -999,
    :def_plus      => -999
  }

  CUSTOM_START = {
    :gold => 5000
  }

  IDENTITY_OPTIONS = {
    :sex     => [:sin_cambios, :male, :female, :futanari],
    :persona => [:sin_cambios, :normal, :submissive, :dominant, :corrupted],
    :race    => [:sin_cambios, :human, :elf, :beast, :monster]
  }

  $cheat_values ||= {}
  NUMERIC_KEYS.each { |sym| $cheat_values[sym.to_s] ||= :normal }
  IDENTITY_KEYS.each { |sym| $cheat_values[sym.to_s] ||= :sin_cambios }

  def self.display_name(sym)
    DISPLAY_NAMES[sym] || sym.to_s
  end

  def self.cycle_mode(stat_key)
    sym = stat_key.to_sym
    if IDENTITY_KEYS.include?(sym)
      cycle_identity(stat_key)
      return
    end
    case $cheat_values[stat_key]
    when :normal   then $cheat_values[stat_key] = :infinito
    when :infinito then $cheat_values[stat_key] = CUSTOM_START[sym] || 100
    else                $cheat_values[stat_key] = :normal
    end
  end

  def self.cycle_identity(stat_key)
    sym = stat_key.to_sym
    options = IDENTITY_OPTIONS[sym] || [:sin_cambios]
    current = $cheat_values[stat_key]
    idx = options.index(current) || 0
    next_idx = (idx + 1) % options.size
    $cheat_values[stat_key] = options[next_idx]
  end

  def self.adjust_value(stat_key, amount)
    return unless $cheat_values[stat_key].is_a?(Integer)
    sym = stat_key.to_sym
    $cheat_values[stat_key] += amount
    max_v = MAX_VALUES[sym] || 999
    min_v = MIN_VALUES[sym] || 0
    $cheat_values[stat_key] = [[$cheat_values[stat_key], max_v].min, min_v].max
  end

  #----------------------------------------------------------------------
  # TEXTO MOSTRADO (con valor real en modo Normal)
  #----------------------------------------------------------------------
  def self.get_status_text(stat_key)
    sym = stat_key.to_sym
    state = $cheat_values[stat_key]

    if IDENTITY_KEYS.include?(sym)
      if state == :sin_cambios
        actual = get_actual_value(sym)
        return "Normal (#{actual})" if actual
        return "Normal"
      else
        return state.to_s
      end
    end

    if state == :normal
      actual = get_actual_value(sym)
      return "Normal (#{actual})" if actual
      return "Normal"
    elsif state == :infinito
      return "Infinito"
    else
      return state.to_s
    end
  end

  #----------------------------------------------------------------------
  # OBTENER VALOR REAL (formateado)
  #----------------------------------------------------------------------
  def self.get_actual_value(sym)
    if sym == :gold
      return $game_party ? $game_party.gold.to_s : nil
    end

    return nil unless $game_actors && $game_actors[1]
    lona = $game_actors[1]

    if IDENTITY_KEYS.include?(sym)
      return get_identity_value(lona, sym)
    elsif NUMERIC_KEYS.include?(sym)
      return get_numeric_stat(lona, sym)
    end
    nil
  end

  def self.get_numeric_stat(lona, sym)
    return nil unless lona.instance_variable_defined?(:@actStat)
    stat_obj = lona.instance_variable_get(:@actStat)
    return nil unless stat_obj.instance_variable_defined?(:@stat)
    h = stat_obj.instance_variable_get(:@stat)
    key = sym.to_s
    return nil unless h[key]
    val = h[key]
    if val.is_a?(Array) && val.size >= 3
      "#{val[0].to_i}/#{val[2].to_i}"
    elsif val.is_a?(Array)
      val[0].to_i.to_s
    else
      val.to_i.to_s
    end
  rescue
    nil
  end

  def self.get_identity_value(lona, sym)
    case sym
    when :sex
      return lona.sex.to_s if lona.respond_to?(:sex)
    when :persona
      return lona.persona.to_s if lona.respond_to?(:persona)
    when :race
      return lona.race.to_s if lona.respond_to?(:race)
    end
    nil
  end

  #----------------------------------------------------------------------
  # BUCLE DE APLICACION (VALORES MANUALES CONGELADOS)
  #----------------------------------------------------------------------
  def self.actualizar_bucle
    # Pausa mientras el menu de trucos esta abierto (para usar flechas)
    return if SceneManager.scene_is?(Scene_CheatMenu)

    # --- Oro -----------------------------------------------------------
    if $cheat_values["gold"] == :infinito
      $game_party.gain_gold(999999 - $game_party.gold) rescue nil
    elsif $cheat_values["gold"].is_a?(Integer)
      # Forzar el oro al valor manual cada frame (congelado)
      $game_party.gain_gold($cheat_values["gold"] - $game_party.gold) rescue nil
      # No se restablece a normal, se mantiene fijo
    end

    return unless $game_actors && $game_actors[1]
    lona = $game_actors[1]
    return unless lona.instance_variable_defined?(:@actStat)

    stat_obj = lona.instance_variable_get(:@actStat)
    return unless stat_obj.instance_variable_defined?(:@stat)
    h = stat_obj.instance_variable_get(:@stat)

    (NUMERIC_KEYS - [:gold]).each do |sym|
      stat  = sym.to_s
      state = $cheat_values[stat]
      next if state == :normal
      next unless h[stat]

      if state == :infinito
        if h[stat].is_a?(Array)
          max_real = h[stat][2] || MAX_VALUES[sym] || 999.0
          h[stat][0] = max_real
        else
          h[stat] = (MAX_VALUES[sym] || 999.0).to_f
        end
      elsif state.is_a?(Integer)
        # Congelar en el valor manual, incluso ajustando el maximo si es mayor
        if h[stat].is_a?(Array) && h[stat].size >= 3
          h[stat][0] = state.to_f
          h[stat][2] = state.to_f if state.to_f > h[stat][2]
        else
          h[stat] = state.to_f
        end
        # No restablecemos a normal
      end
    end
  end
end