class History

    attr_accessor :length, :show_num_items

    def initialize length, show_num_items = 5
        @items = {}
        self.length = length
        self.show_num_items = show_num_items
    end

    def update item
        @items.each {|itm,age| @items[itm] += 1}
        @items[item] = 0
        if @items.length > @length
            @items.delete((@items.max_by {|itm, age| age}).first)
        end
    end

    def items 
        sorted_items = (@items.sort_by {|item,age| age}).map {|pair| pair.first}
        sorted_items.partition {|item| sorted_items.index(item) < (@show_num_items)}
    end

    def clear
        @items = {}
    end
end
