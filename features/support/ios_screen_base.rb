require 'calabash-cucumber/ibase'

class IOSScreenBase < Calabash::IBase

  def self.element(element_name, &block)
    define_method(element_name.to_s, *block)
  end

  class << self
    alias_method :value, :element
    alias_method :action, :element
    alias_method :trait, :element
  end

  element(:loading_screen)            { 'In progress' }
  element(:loading_progress_bar)      { 'progress_bar' }
  element(:eletronic_password_access_buton)               { 'button_electronic_password_access' }

  # The progress bar of the application is a custom view
  def wait_for_progress
    sleep 2
    wait_for(timeout: 60) { element_does_not_exist "* marked:'#{loading_screen}'" }
  end

  element(:menu_icon)     { 'FLYOUT_MENU_ICON' }

  def used_credential
    @used_credential
  end

  # Perform a drag action from the left side to the right
  # to open the menu
  def open_menu
    touch_screen_element menu_icon
  end

  # Perform a drag action from the right to the left side
  # to close the menu
  def close_menu
    pending
    perform_action('drag', 20, 0, 10, 10, 10)
  end

  def has_text?(text)
    !query("* {text CONTAINS[c] '#{text}'}").empty? ||
      !query("* {accessibilityLabel CONTAINS[c] '#{text}'}").empty?
  end

  def drag_to(direction, element = nil)
    element = 'scrollView' if element.nil?
    direction = { x: 0, y: 100 } if direction == :up
    direction = { x: 0, y: -100 } if direction == :down
    direction = { x: 100, y: 0 } if direction == :left
    direction = { x: -100, y: 0 } if direction == :right

    flick(element, direction)
    sleep(1)
  end

  def wait_for_progress_bar
    sleep 2
    wait_for_element_does_not_exist("* id:'#{loading_progress_bar}'",
                                    timeout: 60)
  end

  # In the iOS, an element could be found from its text or its accessibilityLabel
  # so this function looks for these two properties on the screen. When the query
  # looks for just a part of the text (CONTAINS[c]) then we need to specify if
  # we will look in accessibilityLabel or in any other propertie (marked)
  def ios_element_exists?(query)
    second_query = nil

    if query.include? 'CONTAINS[c]'
      if query.include? 'marked'
        second_query = query.gsub('marked', 'accessibilityLabel')
      end
      if query.include? 'accessibilityLabel'
        second_query = query.gsub('accessibilityLabel', 'marked')
      end
    end

    if second_query.nil?
      return element_exists(query)
    else
      element_exists(query) || element_exists(second_query)
    end
  end

  def drag_until_element_is_visible_with_special_query(direction, element)
    drag_until_element_is_visible direction, element,
                                  "* {accessibilityLabel CONTAINS[c] '#{element}'}"
  end

  def drag_until_element_is_visible(direction, element, query = nil, timeout = 30,
    scrollElement = nil)
    query = "* marked:'#{element}'" if query.nil?

    wait_poll(until_exists: query, timeout: timeout,
      timeout_message: "Elemento '#{element}' não foi encontrado na tela!") do
      if scrollElement
        scroll(scrollElement, direction) if element_exists(scrollElement)
      else
        scroll('scrollView', direction) if element_exists('scrollView')
        scroll('tableView', direction) if element_exists('tableView')
      end
    end
  end

  def drag_for_specified_number_of_times(direction, times)
    times.times do
      drag_to direction
    end
  end

  def drag_carousel_card(direction, query)
    swipe direction, :query => query,
      :offset => {:x => 70, :y => 0}, :"swipe-delta" => {:horizontal => {:dx=> 200, :dy=> 0} }
    sleep(0.5)
  end

  # Negation indicates that we want a page that doesn't has
  # the message passed as parameter
  def is_on_page?(page_text, negation = '')
    fail 'Página inesperada. Entre com uma mensagem válida' if
        page_text.to_s == ''

    should_not_have_exception = false
    should_have_exception = false
    begin
      wait_for(timeout: 5) { has_text? page_text }
      # If negation is not nil, we should raise an error
      # if this message was found on the view
      should_not_have_exception = true unless negation == ''
    rescue
      # only raise exception if negation is nil,
      # otherwise this is the expected behaviour
      should_have_exception = true if negation == ''
    end

    fail "Página inesperada. A página não contém: '#{page_text}'" if
      should_not_have_exception

    fail "Página inesperada. Era esperado: '#{page_text}'" if
      should_have_exception

    true
  end

  def enter(text, element, query = nil)
    query = "* marked:'#{element}'" if query.nil?

    begin
      wait_for(timeout: 5) { element_exists query }
    rescue
      # Just a better exception message
      raise "Elemento '#{element}' não encontrado na tella!"
    end

    touch query
    # Waits up to 20 seconds for the keyboard to show up
    begin
      wait_for(timeout: 10) { element_exists("view:'UIKeyboardAutomatic'") }
    rescue
      # If the keyboard didn't show up, tries another time
      # before rainsing the error message
      touch query
      wait_for(timeout: 5) { element_exists("view:'UIKeyboardAutomatic'") }
    end

    keyboard_enter_text text
  end

  def enter_password(password)
    touch("* marked:'Abrir teclado virtual'")
    wait_for(timeout: 5, timeout_message: 'Teclado virtual não foi encontrado na tela') do
      element_exists("* {text CONTAINS[c] ' ou '}")
    end
    password.split('').each do |number|
      # No teclado virtual, o numero pode vir antes ou depois
      # do texto 'ou', ex.: '0 ou 1'
      if element_exists("* {text CONTAINS[c] 'ou #{number}'}")
        touch("* {text CONTAINS[c] 'ou #{number}'}")
      elsif element_exists("* {text CONTAINS[c] '#{number} ou'}")
        touch("* {text CONTAINS[c] '#{number} ou'}")
      else
        fail 'Número não encontrado na tela'
      end
    end
  end

  def touch_screen_element(element, query = nil, timeout = 5)
    query = "* marked:'#{element}'" if query.nil?
    begin
        wait_for_none_animating
        wait_for_element_exists query
        touch query
    rescue => e
      raise "Problema em tocar no elemento da tela: '#{element}'\nMensagem de erro: #{e.message}"
    end
  end

  def touch_element_by_text(text)
      wait_for(timeout: 5) { element_exists("* text:'#{text}'") }
      touch("* text:'#{text}'")
  end

  def touch_element_by_index(id, index)
    query = "* marked:'#{id}' index:#{index}"
    wait_for(timeout: 5) { element_exists(query) }
    touch(query)
  end

  def touch_element item
    drag_until_element_is_visible :down, item
    touch "* text:'#{item}'"
  end

  def clear_text_field(field)
    query = "textField marked:'#{field}'"
    touch(query)
    device_agent.clear_text
  end

  def select_date_on_date_picker(date, date_picker_field_id)
    # Touch the date picker element
    touch_screen_element date_picker_field_id
    # Waiting for the date picker to show up
    wait_for(timeout: 5) { element_exists("view:'UIDatePicker'") }

    # If date is today, then we have nothing to do
    if date.year != DateTime.now.year ||
       date.month != DateTime.now.month ||
       date.day != DateTime.now.day
      # Selecting 'date' on the date picker
      picker_set_date_time date
    end

    # Touch the OK button
    touch_screen_element 'ok'
  end

  def touch_picker_item_by_index(index)
    label = query('pickerView', :delegate,
                  [{ pickerView: nil }, { titleForRow: index },
                   { forComponent: 0 }])

    # Exception if element no found
    fail "Item do picker com index: #{index} não encontrado." if label.nil?
    # Label is an array of 1 element. Just picking the first.
    label = label.first

    # Touching the first item using it's text and Javascript function
    uia(%[uia.selectPickerValues('{0 "#{label}"}')])

    # Touching the OK button to close the Picker
    touch "* marked:'ok'"
  end

  # Method to close error labels
  element(:label_error)           { 'ic_FecharWhite' }

  def close_labels
    count = 0
    while count < 5 && element_exists("* id:'#{label_error}'")
      touch_screen_element label_error
      count += 1
      sleep 1
    end
    fail 'Muitas labels para fechar' unless count < 5
  end

  def voucher_dates
    dates = []
    query("* id:'#{date_field}'", :text).each do |date_string|
      #Comparison made to see if the dates within the array are valid formats ,
      # one label is dated in another standard
      if date_string.to_i == 0
        next
      end
      day, month, year = date_string.split('/')
      dates << Date.new(year.to_i, month.to_i, day.to_i)
    end
    dates
  end

  def dates_ordered?(dates, order)
    case order
      when :asc
        return dates.each_cons(2).all? { |i, j| i <= j }
      when :desc
        return dates.each_cons(2).all? { |i, j| i >= j }
    end
    false
  end

  def check_dates_order(order)
    fail 'Não existem comprovantes!' unless
        at_least_one_voucher?

    dates = voucher_dates
    dates_history = nil

    # Drags the screen down until the end
    # Dates and dates_history are used to know when the scroll is not changing
    # the values of dates
    while dates != dates_history
      fail "Datas não estão na ordem #{order}!" unless
          dates_ordered?(dates, order)
      drag_to :down

      dates_history = dates
      dates = voucher_dates
    end
  end

  def check_dates_period(period)
    fail 'Não existem comprovantes!' unless
        at_least_one_voucher?

    dates = voucher_dates
    dates_history = nil
    last_date = initial_date - period

    while dates != dates_history
      dates.each do |date|
        fail "Essas datas estão fora do periodo de #{period} dias" if
            date > initial_date || date < last_date
      end
      drag_to :down

      dates_history = dates
      dates = voucher_dates
    end
  end

  def error_message_visible?(message)
    return query("* marked:#{message}")
  end

  def message_visible?(message)
    wait_for_progress
    fail "A mensagem:'#{message}' não está visível" unless
      element_exists "* text:'#{message}'"
  end

   def closes_new_version_available_modal_box
    begin
      touch_screen_element 'New version available modal box',
              "* marked:'Ignore'", 3
    rescue
      begin
        query = "* marked:'Atualização disponível'"
        wait_for(timeout: 5) { element_exists(query) }
        touch "* marked:'Ignorar'"
      rescue
      end
    end
   end


  element(:keyboard_close_button) { "* marked:'ok'" }

  def close_keyboard
    contador = 0
    while element_exists keyboard_close_button
      touch_screen_element 'Keyboard OK button', keyboard_close_button
      sleep 1
      contador = contador + 1
      fail "Não foi possível fechar o teclado" if contador > 4
    end
    contador = 0
  end

  def close_alerts
    'not implemented yet'
  end

  def method_missing(method, *args)
    if method.to_s.start_with?('touch_')
      # If method name starts with touch_, executes the touch
      # screen element method using the element name which is the
      # method name without the first 'touch_' chars
      touch_screen_element public_send(method.to_s.sub('touch_', ''))
    elsif method.to_s.start_with?('enter_')
      # If method starts with enter_, execute the enter method using
      # the field name, which is the method name without the initial
      # 'enter_' chars and appended '_field' chars
      enter args[0], public_send("#{method.to_s.gsub('enter_', '')}_field")
    elsif method.to_s.end_with?('_visible?')
      # If method ends with _visible?, executes the visible? method
      # The field name is the method name without de ending
      # '_visible? chars
      visible? public_send(method.to_s.gsub('_visible?', ''))
    else
      super
    end
  end

  def visible?(id, query = nil)
    query = "* id:'#{id}'" if query.nil?
    begin
      wait_for(timeout: 3) { element_exists query }
    rescue
      return false
    end
    true
  end

  element(:token_aplicativo_button)         { 'TOKEN_APP_LABEL' }
  element(:token_sms_button)                { 'TOKEN_SMS_LABEL' }
  element(:token_chaveiro_button)           { 'TOKEN_CHAVEIRO_LABEL' }
  element(:token_field)                     { 'TOKEN_TEXT' }
  element(:token_ok_button)                 { 'TOKEN_CONFIRM_BUTTON' }

  def enter_token(type, value)
    touch_screen_element public_send("token_#{type}_button")
    enter value, token_field
    touch_screen_element token_ok_button
    wait_for_progress
  end

  def enter_token_sms(token)
    enter token, token_field
    touch_screen_element token_ok_button
    wait_for_progress
  end

  def check_if_exists_any_element
    wait_for do
      !query("*").empty?
    end
  end

  ####
  def touch_button(element_alias)
    element_id = get_element_id(element_alias)
    if element_alias == BACK_BUTTON
      close_visible_toast()
    end

    wait_for(timeout: 5, timeout_message: "Botão '#{element_alias}' não encontrado na tela") do
      if !element_id.nil?
        q = "* id:'#{element_id}'"
        drag_until_element_is_visible(:down, nil, q)
        touch q
        return true
      else
        q = "* text:'#{element_alias}'"
        drag_until_element_is_visible(:down, nil, q)
        touch q
        return true
      end

      return false
    end
  end

  TYPE_SUFIX = "_type"

  def self.element_with_alias(element_alias, element_name, type = TYPE[:Field], &block)
    element(element_name) { block.call }

    a = element_alias.to_s.gsub(/[^0-9A-Za-z]/, "_")
    define_method(a) { block.call }
    define_method(a + TYPE_SUFIX) { type }
  end

  def get_element_id(element_alias)
    method = element_alias.to_s.gsub(/[^0-9A-Za-z]/, "_")
    if respond_to? method
      send(method)
    else
      return nil
    end
  end

  def get_element_type(element_alias)
    a = element_alias.to_s.gsub(/[^0-9A-Za-z]/, "_") + TYPE_SUFIX
    send(a)
  end

  def enter_by_keyboard text, element, query = nil
    if query.nil?
        touch_screen_element(element)
    else
        touch_screen_element(nil, query)
    end

    keyboard_enter_text(text)

    #sleep(1)
  end

  def drag_until_element_is_visible_by_description(direction, description, element, query = nil, timeout = 30)
    query = "* marked:'#{element}'" if query.nil?

    begin

      test = lambda do
        if (element_exists(query))
          found = query(query).select {|item| item["description"] == description }
          found.any?
        else
          false
        end
      end

      wait_poll(until: test, timeout: timeout) do
        drag_to direction
      end
    rescue
      raise "Elemento com a descrição '#{description}' não encontrado na tela!"
    end
  end

  def get_element_by_description(q, description)
    elements =  query(q)

    if (element.any?)
      if elements.size == 1 && elements.first["description"] == description
        elements.first
      else
        element = nil

        elements.each do |item|
          if item ["description"] == description
            element = item
            break
          end
        end

        fail "Elemento com a descrição '#{description}' não encontrado na tela!" if element.nil?

        element
      end
    else
      fail "Elemento com a descrição '#{description}' não encontrado na tela!"
    end
  end

  def get_all_elements(q)
    scroll_query = q + " parent android.widget.ScrollView index:0"

    if element_exists(scroll_query)
      scroll_element = query(scroll_query).first

      last_description = ""
      description = ""
      all_elements = []

      begin
        last_description = description
        drag_to :up
        description = query(q + "descendant *").last["description"]
      end while last_description != description

      last_description = ""
      description = ""

      begin
        last_description = description
        drag_to :down
        all_elements.concat(query(q))
        description = query(q + "descendant *").last["description"]
      end while last_description != description

      all_elements.uniq{|e| e["description"]}
    else
      query(q)
    end
  end

  def end_editing
    query('view index:0', :endEditing => true)
    sleep 1
  end

  def clear_text_by_keyboard(element, query = nil)
    query = "* marked:'#{element}'" if query.nil?
    clear_text query
    touch query

    #develop
    begin
      uia("target.frontMostApp().keyboard().elements()['Delete'].tap()")
      # keyboard_enter_text "0"
      uia("target.frontMostApp().keyboard().elements()['Delete'].tap()")
    rescue
      uia("target.frontMostApp().keyboard().elements()['delete'].tap()")
      keyboard_enter_text "a"
      uia("target.frontMostApp().keyboard().elements()['delete'].tap()")
    end

    end_editing
  end

  def set_field(element_alias, text, index = -1)
    #begin
      idx = index

      if idx >= 0
        wait_for_element_exists("* id:'#{get_element_id(element_alias)}'")

        all_elements = get_all_elements("all * id:'#{get_element_id(element_alias)}'")

        description = all_elements[idx]["description"];

        begin
          drag_until_element_is_visible_by_description(:up, description, get_element_id(element_alias))
        rescue
          drag_until_element_is_visible_by_description(:down, description, get_element_id(element_alias))
        end

        elements = query("* id:'#{get_element_id(element_alias)}'")
        elements.each_with_index do |item, i|
          if item["description"] == description
            idx = i
            break
          end
        end
      else
        begin
          drag_until_element_is_visible(:up, get_element_id(element_alias), nil, 30 , 'scrollView')
        rescue
          drag_until_element_is_visible(:down, get_element_id(element_alias), nil, 30 , 'scrollView')
        end

        idx = 0
      end

      q = "* id:'#{get_element_id(element_alias)}' index:#{idx}"

      @used_credential = Hash.new if @used_credential.nil?

      case get_element_type(element_alias)
      when TYPE[:Field]
        touch(q)
        device_agent.clear_text
        enter_by_keyboard text, nil, q

        @used_credential[element_alias] = text

      when TYPE[:Selector]
        touch q

        sleep 1

        i = 0
        while i > -1  do
          if query('pickerView', :delegate,[{ pickerView: nil }, { titleForRow: i},{ forComponent: 0 }]).first == text
            query("pickerTableView index:0", [{:selectRow => i},{:animated => 1},{:notify => 1}])
            break
          end
          i +=1
        end

        end_editing
      else
        raise "Campo '#{element_alias}' possui um tipo desconhecido"
      end
    #rescue
    #  raise "Field '#{element_alias}' not found on the view"
    #end
  end

  def set_field_recursive(field, value, index = -1)
    unless value.is_a?(Array)
      set_field(field, value, index)
    else
      value.each_with_index { |val, i|
        if val.is_a?(Hash)
          val.each { |f, v| set_field_recursive(f, v, i)}
        else
          fail "datapool inválido' #{field}"
        end
       }
    end
  end

  def datapool_set_field(datapool, key, field = nil)
      if field.nil?
        $datapool[datapool][key].each { |f, v| set_field_recursive(f, v) }
      else
        set_field_recursive(field, Datapool.get_datapool_value(datapool, key, field))
      end
  end

  def check_element_is_enabled(element_alias, expected_enabled)
    begin

      element = get_element_id(element_alias) || element_alias

      drag_until_element_is_visible(:down, element, nil, 30, 'scrollView')
      actual_enabled = query("* marked:'#{element}'").first["enabled"]
    rescue
      raise "Elemento #{element_alias} não foi encontrado"
    end
    raise "Elemento habilitado está '#{actual_enabled}', mas era para estar '#{expected_enabled}'" unless (expected_enabled == actual_enabled)
  end

   def check_element_is_on_page(element, query=nil)
    begin
      query = "* id:'#{element}'" if query.nil?
      check_element_exists(query)
    rescue
      raise "Elemento #{element} não encontrado na tela"
    end
   end

  def touch_item(item)
    drag_until_element_is_visible(:down, item)
    touch "* marked:'#{item}'"
  end

  def checkbox_is_checked(element_alias, expected_enabled)
      begin
        element = get_element_id(element_alias)
      rescue
        element = element_alias
      end
      drag_until_element_is_visible(:down, element)

      if query("* marked:'#{element}'")[0]["selected"] != expected_enabled
        fail("Checkbox não está #{expected_enabled}")
      end
  end

  def by_pass_dialog_message()
    step "toco no botão \"ok\""
  end

  def close_visible_toast()
    queryCloseIcon = "* id:'ic_fechar_erro'"
    if element_exists queryCloseIcon
      touch queryCloseIcon
    end
  end
end
