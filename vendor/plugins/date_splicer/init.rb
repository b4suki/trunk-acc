## As  of Rails 2.1:
## Simply use <%= javascript_include_tag :date_splicer %> to insert all javascript files
if ActionView::Helpers::AssetTagHelper.respond_to?('register_javascript_expansion')
  ActionView::Helpers::AssetTagHelper.register_javascript_expansion :date_splicer => ["calendar/calendar.js",
                                                                                      "calendar/lang/calendar-parser-en.js",
                                                                                      "calendar/lang/calendar-en.js",
                                                                                      "calendar/calendar-parser.js",
                                                                                      "calendar/calendar-setup.js"]                                                                                      
end


## Add date_splicer as a specific kind of helper: FormHelper 
module ActionView::Helpers::FormHelper  
  
  def date_splicer(object_name, method_name, default_to_now = false)
    object = self.instance_variable_get("@#{object_name}")    
    if object.nil? || !object.respond_to?(method_name)
      raise "Could not find instance variable for #{object_name} or object did not respond to #{method_name}"
    end

    current_data = object.send(method_name)
    init_date = Time.now

    if current_data
      set_current_data_date = "date   :    new Date(#{current_data.strftime("%Y")},(#{current_data.strftime("%m")}-1),#{current_data.strftime("%d")})"
    else
      set_init_date = "date           :    new Date(#{$year},(#{$month}-1),#{init_date.day})"
    end
    
    js_date = (current_data) ? set_current_data_date : set_init_date
    content = "     
      <input id='#{object_name}_#{method_name}' name='#{object_name}_#{method_name}' value='' size='10' readonly/>&nbsp;<img src='/images/calendar.png' width='18px' height='18px;' id='#{object_name}_#{method_name}_trigger' style='cursor: pointer; border: 0px solid red; margin-bottom: -5px;' title='Pilih Tanggal' />
      <div class='validator' id='#{object_name}_#{method_name}_msg'></div>
      <input type='hidden' id='#{object_name}_#{method_name}_1i' name='#{object_name}[#{method_name}(1i)]' value='#{(current_data) ? current_data.strftime("%Y") : $year}'/>
      <input type='hidden' id='#{object_name}_#{method_name}_2i' name='#{object_name}[#{method_name}(2i)]' value='#{(current_data) ? current_data.strftime("%m") : $month}'/>
      <input type='hidden' id='#{object_name}_#{method_name}_3i' name='#{object_name}[#{method_name}(3i)]' value='#{(current_data) ? current_data.strftime("%d") : init_date.day}'/>        
      <script type='text/javascript'>
        if (typeof Calendar == 'undefined') {
          alert('Calendar is undefined. Are javascript files calendar.js, lang/calendar-en.js, lang/calendar-parser-en.js, calendar-parser.js and calendar-setup.js loaded?');
        }
        Calendar.setup({
            inputField     :    '#{object_name}_#{method_name}',     // id of the input field
            ifFormat       :    '%d-%m-%Y',      // date format of the input field
            button         :    '#{object_name}_#{method_name}_trigger',  // trigger for the calendar (button ID)
            align          :    'Bl',           // alignment (defaults to 'Bl => Tl')
            singleClick    :    true,
            #{js_date}    
        });            
      </script>"      
  end  

  def multiple_date_splicer(object_name, method_name, default_to_now = false, options = {})
    object = self.instance_variable_get("@#{object_name}")    
    if object.nil? || !object.respond_to?(method_name)
      raise "Could not find instance variable for #{object_name} or object did not respond to #{method_name}"
    end

    current_data = object.send(method_name)
    init_date = Time.now

    if current_data
      set_current_data_date = "date   :    new Date(#{current_data.strftime("%Y")},(#{current_data.strftime("%m")}-1),#{current_data.strftime("%d")})"
    else
      set_init_date = "date           :    new Date(#{$year},(#{$month}-1),#{init_date.day})"
    end
    
    js_date = (current_data) ? set_current_data_date : set_init_date
    content = "     
      <input id='#{object_name}_#{method_name}_#{options[:index]}' name='#{object_name}_#{method_name}_#{options[:index]}' value='' readonly/>&nbsp;<img src='/images/calendar.png' width='18px' height='18px;' id='#{object_name}_#{method_name}_trigger_#{options[:index]}' style='cursor: pointer; border: 0px solid red; margin-bottom: -5px;' title='Pilih Tanggal' />
      <div class='validator' id='#{object_name}_#{method_name}_#{options[:index]}_msg'></div>
      <input type='hidden' id='#{object_name}_#{method_name}_#{options[:index]}_1i' name='#{object_name}_#{method_name}(1i)_#{options[:index]}' value='#{(current_data) ? current_data.strftime("%Y") : $year}'/>
      <input type='hidden' id='#{object_name}_#{method_name}_#{options[:index]}_2i' name='#{object_name}_#{method_name}(2i)_#{options[:index]}' value='#{(current_data) ? current_data.strftime("%m") : $month}'/>
      <input type='hidden' id='#{object_name}_#{method_name}_#{options[:index]}_3i' name='#{object_name}_#{method_name}(3i)_#{options[:index]}' value='#{(current_data) ? current_data.strftime("%d") : init_date.day}'/>        
      <script type='text/javascript'>
        if (typeof Calendar == 'undefined') {
          alert('Calendar is undefined. Are javascript files calendar.js, lang/calendar-en.js, lang/calendar-parser-en.js, calendar-parser.js and calendar-setup.js loaded?');
        }
        Calendar.setup({
            inputField     :    '#{object_name}_#{method_name}_#{options[:index]}',     // id of the input field
            ifFormat       :    '%d-%m-%Y',      // date format of the input field
            button         :    '#{object_name}_#{method_name}_trigger_#{options[:index]}',  // trigger for the calendar (button ID)
            align          :    'Bl',           // alignment (defaults to 'Bl => Tl')
            singleClick    :    true,
            #{js_date}    
        });            
      </script>"      
  end  
end


## Wrap date_splicer helper in FormBuilder method.
## This allows use in form_for context: <% form_for(@account) do |f| %><%= f.date_splicer :start_date %>
class ActionView::Helpers::FormBuilder
  
  def date_splicer(method_name, default_to_now = false)
    @template.date_splicer(@object_name, method_name, default_to_now = false)
  end   

end
                                                                                    
