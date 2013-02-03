class History
    def initialize length, show_num_items = 5
        @items = {}
        set_length length
        set_show_num_items show_num_items
    end
    
    def length
        @length
    end

    def show_num_items
        @show_num_items
    end

    def set_length length
        @length = length
    end

    def set_show_num_items num
        @show_num_items = num
    end

    def update item
        @items.each {|itm,age| @items[itm] += 1}
        @items[item] = 0
        if @items.length > @length
            @items.delete((@items.max_by {|itm, age| age}).first)
        end
    end

    def items 
        ret = {
            :first => ((@items.sort_by {|item,age| age}).map {|pair| pair.first}).first(@show_num_items)
        }
        ret.store :rest, (@items.reject {|item, age| ret[:first].include? item}).keys
        ret
    end

    def clear
        @items = {}
    end
end
