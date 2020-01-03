class TableBuilder
  class Column
    attr_reader :attribute, :name, :block, :header_attributes, :body_attributes, :is_html_safe

    def initialize(attribute = nil, header_attributes=nil, body_attributes=nil, is_html_safe=false, &block)
      @attribute = attribute
      @header_attributes = header_attributes
      @body_attributes = body_attributes
      @name = attribute.kind_of?(String) ? attribute : attribute.to_s.titleize
      @is_html_safe = is_html_safe
      @block = block
    end

    def value(item, i, j)
      if block.present?
        block.call(item, i, j, self)
        nil
      elsif attribute.kind_of?(Symbol)
        item.send(attribute)
      else
        ""
      end
    end
  end

  attr_reader :columns, :table_attributes, :row_attributes, :items

  def initialize(items, table_attributes=nil, row_attributes=nil)
    @items = items
    @columns = []
    @table_attributes = table_attributes
    @row_attributes = row_attributes
    yield self if block_given?
  end

  def column(*options, &block)
    @columns << Column.new(*options, &block)
  end

  def all_row_attributes(item, i)
    if !item.id.nil?
      standard_attributes = { id: "#{item.model_name.singular.dasherize}-#{item.id}", "data-id": item.id }
    else
      standard_attributes = {}
    end
    if !row_attributes.nil?
      mapped_row_attributes = row_attributes.clone
      mapped_row_attributes.clone.each do |key, value|
        if value.kind_of?(Array)
          mapped_row_attributes[key] = value[0] % value.slice(1,value.length).map {|param| eval(param)}
        end
      end
    else
      mapped_row_attributes = {}
    end
    standard_attributes.merge(mapped_row_attributes)
  end
end
