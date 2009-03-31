module DataGrid
  # extend the class that include this with the methods in ClassMethods
  def self.included(base)
    super
    base.extend(ClassMethods)
  end
  
  def data_table(options = {}, &block)    
    raise(ArgumentError, "No data given")  unless options.has_key?(:columns)

    block ||= Proc.new {|d| nil}

    defaults = {
      :table_class => 'data_grid',
      :caption => 'Data Listing',
      :add_text => 'Add New',
      :filter => true,
      :display_edit => true,
    	:display_delete => true,
    	:display_add => true
    }
    options = defaults.merge options
    
    # if the user dosen't want to display both the edit and delete links then don't show the admin col.
    options[:display_edit_col] = options[:display_edit] || options[:display_delete]
    
    if options[:display_edit_col]
      options[:num_cols] = options[:columns].length + 1 # add one for the edit/delete col.
    else
      options[:num_cols] = options[:columns].length
    end
      
    # save the options for use by the alternate views (text, pdf...)    
    session[:options] = options  
    
    # Check to see if we're using a filter and display the appropiate text. 
    show_hide = (@filter && params[:filter]) ? "Hide" : "Show" # the text for the show hide link.
    pages = eval("@#{@model_name}_pages")  
    
    # begin building the html output
    table =  %(<table class="#{options[:table_class]}" border="0" cellspacing="0" cellpadding="0">\n)
    table << %(\t<caption>#{options[:caption]} (#{pages.current_page.first_item}-#{pages.current_page.last_item} of #{pages.item_count}))
    table << %( <a href="#" id="filter_link" onclick="new Element.toggle('filter_row'); ToggleContent('filter_link', 'Show Filter', 'Hide Filter'); return false;">#{show_hide} Filter</a>) if options[:filter]
    table << %(</caption>\n)
    table << %(\n\t<thead>\n\t<tr><th colspan="#{options[:num_cols]}">#{options[:display_add] ? link_to(options[:add_text], :action => 'new') : "&nbsp;" }</th></tr>\n) 
    table << build_header_row(options) 
    table << build_filter_row(options) if options[:filter]
    table << %(\t</thead><tbody>\n)
    table << build_data_rows(options, eval("@#{@model_name}_data")) # the second param is the data generated in the controller
    table << build_footer_row(options, pages)
    table << %(\n</tbody></table>)
    
    #table << "action = #{params[:action]}"
    #table << "#{debug request}"
    #table << "#{debug options} \n" # remove this when done.
    #table << "display col = #{options[:display_edit_col]}"
    #table << "#{debug params} \n" # remove this when done.
    #table << "col = #{@sort_col} , sort = #{@sort_dir} \n" 
  end

  def build_header_row(options)
    row = "\t\t<tr>"

    for col in options[:columns]
      raise(ArgumentError, "No db_column given.")  unless col.has_key?(:db_column)

      # use the database column name for sort unless otherwise specified
      sort_by = col[:sort_column] || col[:db_column]

      # set the correct sort order and css style for the header link.
      if sort_by == @orig_col_name
        sort_dir = (@sort_dir == "asc" ? "_desc" : "_asc")
        css_class = (@sort_dir == "asc" ? " class=\"sort_asc\"" : " class=\"sort_desc\"")
      else
        sort_dir = "_asc"
        css_class = ""
      end
      
      # use the supplied title or the name of the db column for the column header text.
      col[:title] = col[:title] ? col[:title] : col[:db_column].titleize

      row << %(<th#{css_class}>#{link_to col[:title], build_url_params.merge!({:action => params[:action], :sort => sort_by + sort_dir }) }</th>)
    end

    # add an extra col if the user is allowed to edit.
    row << %(<th>&nbsp;</th>) if options[:display_edit_col]
    row << %(</tr>\n)
  
  end

  def build_filter_row(options)
    display = (@filter && params[:filter]) ? "" : "style=\"display: none;\""
    
    row = %(\t\t<tr id="filter_row" #{display} >)
    row << %(<form id="filter_options_form" action="#{ url_for(:action => params[:action]) }" method="get"> #{hash_to_hidden_form_fields( build_url_params(false) )})
    for col in options[:columns]
        name = col[:db_column]
        
        if @filter && params[:filter]
          value = params[:filter][name] ? params[:filter][name] : ""
        else
          value = ""  
        end
        
        row << %(<th>)
        row << %(<input name="filter[#{name}]" value=\"#{value}\" type="text" size="10"/> ) unless col[:filter] == false
        row << %(<div id="filter_form_submit_btns"><input type="submit" value="Apply Filter"/><input type="submit" name="clear" value="Clear"/></div>) if (col == options[:columns].last) && !options[:display_edit_col]
        row << %(</th>)     
    end
    row << %(<th><div id="filter_form_submit_btns"><input type="submit" value="Apply Filter"/><input type="submit" name="clear" value="Clear"/></div></th>) if options[:display_edit_col]
    row << %(</form></tr>\n)
  end

  def build_data_rows(options, data)
    rows = %(\n)    
    count = 0
    for row in data
      rows << %(\t\t<tr#{' class="alt"' if count % 2 != 0}>)
      for col in options[:columns]
        val =  eval("row.#{col[:db_column]}") rescue "unknown column"
        case col[:format]
        when :money : val = number_to_currency(val)
        when :image : val = ""
        when :percent : val = ""
        when :date : val = val.to_s(:short) unless val == nil
        when :show  : val = link_to( col[:link_name] || val, :action => 'show', :id => row) 
        when :mail  : val = mail_to( col[:link_name] || val)
        when :link  : val = link_to( col[:link_name] || val , val)
        when :custom : val = eval("#{col[:call_back]}(row)")
        end
        rows << %(<td>#{val}</td>)
      end
      
      if options[:display_edit_col]
        rows << %(<td>)
        rows << %(#{link_to 'Edit', :action => 'edit', :id => row } ) if options[:display_edit]
        if options[:display_delete]
          if @act_restful
            rows << %(#{link_to 'Delete', eval(@model_name + '_path(row)'  ), :confirm => 'Are you sure?', :method => :delete })
          else
            rows << %(#{link_to 'Delete', {:action => 'delete', :id => row}, :confirm => 'Are you sure?' })
          end
        end
        rows << %(</td>)
      end
      
      rows << %(</tr>\n)
      count += 1 # used to set the css for alternating styles.
    end
    
    rows << %(<tr><td id="no_results" colspan="#{options[:num_cols]}"> No Records Found</td></tr>) if count == 0
    
    rows
  end

  def build_footer_row(options, pages)
    row = %(\t\t<tr class="footer_row">)
    row << %(<td class="display_form" colspan="#{options[:num_cols] - 1}">#{build_display_form}</td>)
    row << %(<td class="pager"><div id="paging">#{link_to 'Previous', build_url_params.merge!({:page => pages.current.previous}) if pages.current.previous } #{pagination_links(pages, :params => build_url_params )} #{link_to 'Next', build_url_params.merge!({:page => pages.current.next})  if pages.current.next}</div></td>)
    row << %(</tr>\n)
    
    # build the correct links to alternate views (text, csv, excel, pdf...)
    if @act_restful
      row << %(\t\t<tr class="footer_row"><td class="alternate_views" colspan="#{options[:num_cols]}">#{link_to "Text",  :format => :txt} | #{link_to "CSV", :format => :csv} </td></tr>)
    else
      row << %(\t\t<tr class="footer_row"><td class="alternate_views" colspan="#{options[:num_cols]}">Download as: #{link_to "Text",  :action => :list_text} | #{link_to "CSV", :action => :list_csv} </td></tr>)
    end
  end
  
  
  def build_display_form
    paging_sizes = [1, 3, 5, 10, 25, 50, 100]
    
    form = %(<form id="display_options_form" action="#{ url_for(:action => params[:action]) }" method="get">)
    form << %(#{hash_to_hidden_form_fields( build_url_params, [:display, :page] )} Display <select name="display" onchange="$('display_options_form').submit()">)
    paging_sizes.each do |size|
      form << %(<option #{'selected=\"selected\"' if params[:display].to_s == size.to_s}>#{size}</option>)
    end
    # always include the 'all' option.
    form << %(<option #{'selected=\"selected\"' if params[:display].to_s == '1000000'}>All</option></select> )
    form << %(items at a time</form>)    
  end
  

  def build_url_params(include_filter = true)
    filter = {}
    
    # setup a default value for the filter params.
    filter_params = params[:filter] ? params[:filter] : {}
    
    for item in filter_params
      filter.merge!  "filter[#{item[0]}]" => "#{item[1]}"
    end if include_filter
    
    {:display => params[:display], :sort => params[:sort], :page => params[:page]}.merge filter
  end

  def hash_to_hidden_form_fields(hash, skip = [])
    fields = ""
    hash.each do |k, v|
      fields << "<input type=\"hidden\" name=\"#{k}\" value=\"#{v}\"/>" unless skip.include? k
    end

    fields    
  end

  def data_text(make_csv = true)    
    seperator = make_csv ? ', ' : ' '
    options = session[:options]
    data = eval("@#{@model_name}_data")
    rows = ""

    for col in options[:columns]
      rows << col[:title].sub(',', ';')
      rows << seperator unless (col == options[:columns].last)
    end

    rows << "\n"
    
    for row in data
      for col in options[:columns]
        rows << row[col[:db_column]].to_s.sub(',', ';')
        rows << seperator unless (col == options[:columns].last)
      end
      rows << "\n"
    end

    rows
  end

  def extract_model_and_col_name(col, plural_model_name)
    col_arr = col.split('.')
    col_model_name = col_arr[col_arr.length() - 2]

    # If the col name is the same as the model name we pulled then we're dealing with the default model,
    # otherwise we're dealing with a foreign model.
    if col != col_model_name    
      class_name = col_model_name.camelize
      plural_model_name = eval("#{class_name}.table_name").downcase
      col = col_arr.last
    end

    return plural_model_name, col    
   end

  def sanitize_sort(sort = nil, default_sort_col = nil, plural_model_name = nil)
    # logger.debug "sort = #{sort}, default_sort_col = #{default_sort_col}, plural_model_name = #{plural_model_name}"
        
    # because we are using generated code we may end up with an empty string, that really means nil.
    default_sort_col = nil if default_sort_col == ''
    
    # use the default sort order unless a specific sort order was passed in.
    sort = sort ? sort : default_sort_col
    
    # if the sort is still nil we can return i.e. sort the results in the order they were entered into the database.
    return nil unless sort
    
    # make sure the sort conatains a direction (so parsing works later).
    sort = sort + "_asc" unless sort =~ /(_asc|_desc)$/    

    # extract the full col and the sort directions 
    sort =~ /^(.*)_(asc|desc)$/     
    sort_col, sort_dir = $1, $2

    # save the full col name, for later use (by the views)     
    orig_col_name = sort_col

    plural_model_name, sort_col = extract_model_and_col_name(sort_col, plural_model_name)

    return sort_col, sort_dir, plural_model_name, orig_col_name
  end

  def sanitize_display(display)
    display = '1000000' if display.to_s.downcase == 'all'
    display = '25' if display.to_i <= 0 # this catches negative numbers AND strings.

    display
  end
 
  def sanitize_filter(filter)
    return nil unless filter
    
    sort = ""
    conditions = []
    
    # filter is an array of the form fields where each element 
    # contains a sub array (criteria) where 0 is the 'raw column name' 
    # and 1 is the value the user entered.  In order for the filter
    # to work properly (for both 'normal' and 'conditions' selects)
    # we need to add the plural model name to the column name. i.e. name becomes users.name
    for criteria in filter
      next if criteria[1] == nil
      col_name = criteria[0]
      col_value = criteria[1]
      
      model_name, col_name = extract_model_and_col_name(col_name, @plural_model_name)
      col_name = "#{model_name}.#{col_name}"
      
      sort << "#{col_name} like ? and "
      conditions << "%#{col_value}%"
    end
    
    sort.slice!(/ and $/) # remove the last 'and' if there is one.
    
    return nil if sort == ""
    
    conditions.insert(0, sort)
  end  

  
  module ClassMethods
    
    def data_grid_scaffold(model_id, options = {})
       singular_name   = model_id.to_s
       class_name      = options[:class_name] || singular_name.camelize
       plural_name     = eval("#{class_name}.table_name") || singular_name.pluralize
       
       options[:method_only] = false unless options[:method_only]
       options[:act_restful] = false unless options[:act_restful]
       
       base_conditions = options[:conditions] ? options[:conditions] : ""
       
       # build the list of models to include in the search.
       include_models  = "[]"
       if options[:include]
         include_models = "["
         options[:include].each {|m| include_models << ":#{m}, "} 
         include_models.slice!(/, $/)
         include_models << "]"
       end
       
       method_name = 'list'
       method_name = 'index' if options[:act_restful]
       method_name = "#{singular_name}_data_grid" if options[:method_only]
       
       restfull_response = <<END_RESTFULL
         respond_to do |format|
           format.html  # index.rhtml
           format.xml   { render :xml => @#{singular_name}_data.to_xml }
           format.text  { render :text => data_text(false) }
           format.csv   { render :text => data_text }
         end
END_RESTFULL
        
       restfull_response = "" unless options[:act_restful] # || (options[:method_only] == false)

       module_eval <<-"end_module_eval", __FILE__, __LINE__
         def #{method_name}
           
           # set the default value for the clear button           
           params[:clear] = "" unless params[:clear]
           
           # save the model names for use by the views (filter & sort)
           @plural_model_name = '#{plural_name.downcase}'
           @model_name = '#{singular_name}'
           @act_restful = #{options[:act_restful]}
               
           # sanatize the display param.
           params[:display] = sanitize_display(params[:display])

           # sanatize the sort params
           @sort_col, @sort_dir, model_name, @orig_col_name = sanitize_sort(params[:sort], '#{options[:default_sort_col]}', @plural_model_name)
           
           # sanatize the filter params
           params[:filter] = nil if params[:clear].downcase == "clear" # if the user clicked on the 'clear' toss the filter params to the bit bucket.           
           @filter = sanitize_filter(params[:filter])
           
           # create the params for the find method
           find_params = {:per_page => params[:display].to_i}
           
           # we need to remove the single quotes so the order works with included tables.
           # because rails alises all of the columns to generated names i.e. t0_r0, t0_r1
           find_params.merge!({:order => ActiveRecord::Base.send(:sanitize_sql, [" \#\{model_name\}.? \#\{@sort_dir\}", @sort_col]).delete("'")}) if @sort_col
           #if @filter && #{base_conditions != nil}
          #   find_params.merge!({:conditions => '#{base_conditions} and ' + @filter.to_s}) # if @filter
           #elsif @filter
             find_params.merge!({:conditions => @filter}) if @filter
           #elsif #{base_conditions != nil}
          #   find_params.merge!({:conditions => '#{base_conditions}'})
           #end
           find_params.merge!({:include => #{include_models} })
           
           logger.info "\n\nfind - \#\{find_params\}\n\n"

           # do the search
           @#{singular_name}_pages, @#{singular_name}_data = paginate :#{plural_name}, find_params
           
           # take care of rendeing if the user wants us to.
           #{restfull_response}
                       
         end

         def list_text    
           headers['Content-Type'] = "text/plain"
           render :text => data_text(false)
         end

         def list_csv
           headers['Content-Type'] = "application/vnd.ms-excel" 
           headers['Content-Disposition'] = 'attachment; filename="data_listing.csv"'
           headers['Cache-Control'] = nil
           render :text => data_text
         end
         
       end_module_eval

     end

  end
  
end
