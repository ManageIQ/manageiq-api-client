module ManageIQ::API::Client::QueryableMixin
  include QueryRelation::Queryable

  # find(#)      returns the object
  # find([#])    returns an array of the object
  # find(#, #, ...) or find([#, #, ...])   returns an array of the objects
  def find(*args)
    request_array = args.size == 1 && args[0].kind_of?(Array)
    args = args.flatten
    case args.size
    when 0
      raise "Couldn't find resource without an 'id'"
    when 1
      res = limit(1).where(:id => args[0]).to_a
      raise "Couldn't find resource with 'id' #{args}" if res.blank?
      request_array ? res : res.first
    else
      raise "Multiple resource find is not supported" unless respond_to?(:query)
      query(args.collect { |id| { "id" => id } })
    end
  end

  def find_by(args)
    limit(1).where(args).first
  end

  def pluck(*attrs)
    select(*attrs).to_a.pluck(*attrs)
  end

  def search(mode, options)
    options[:limit] = 1 if mode == :first
    result = get(parameters_from_query_relation(options))
    case mode
    when :first then result.first
    when :last  then result.last
    when :all   then result
    else raise "Invalid mode #{mode} specified for search"
    end
  end

  private

  def parameters_from_query_relation(options)
    api_params = {}
    [:offset, :limit].each { |opt| api_params[opt] = options[opt] if options[opt] }
    api_params[:attributes] = options[:select].join(",") if options[:select].present?
    if options[:where]
      api_params[:filter] ||= []
      api_params[:filter] += filters_from_query_relation("=", options[:where])
    end
    if options[:not]
      api_params[:filter] ||= []
      api_params[:filter] += filters_from_query_relation("!=", options[:not])
    end
    if options[:order]
      order_parameters_from_query_relation(options[:order]).each { |param, value| api_params[param] = value }
    end
    api_params
  end

  def filters_from_query_relation(condition, option)
    option.collect do |attr, values|
      Array(values).collect do |value|
        value = "'#{value}'" if value.kind_of?(String) && !value.match(/^(NULL|nil)$/i)
        "#{attr}#{condition}#{value}"
      end
    end.flatten
  end

  def order_parameters_from_query_relation(option)
    query_relation_option =
      if option.kind_of?(Array)
        option.each_with_object({}) { |name, hash| hash[name] = "asc" }
      else
        option
      end

    res_sort_by = []
    res_sort_order = []
    query_relation_option.each do |sort_attr, sort_order|
      res_sort_by << sort_attr
      sort_order =
        case sort_order
        when /^asc/i  then "asc"
        when /^desc/i then "desc"
        else raise "Invalid sort order #{sort_order} specified for attribute #{sort_attr}"
        end
      res_sort_order << sort_order
    end
    { :sort_by => res_sort_by.join(","), :sort_order => res_sort_order.join(",") }
  end
end
