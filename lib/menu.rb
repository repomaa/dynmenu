require 'item'


class Menu

    include Item

    attr_accessor :style
    attr_writer :name

    def initialize name
        self.name = name
        @items = Hash.new
        self.style = Style.new
        set_item(Editor.new self) unless self.is_a? Dynamic
    end

    def encode_with coder
        coder['name'] = @name
        coder['items'] = items
        coder['style'] = style
    end

    def init_with coder
        self.name = coder['name']
        @items = coder['items']
        self.style = coder['style']
        set_item(Editor.new self)
    end

    def set_item item
        @items[item.name] = item unless @items[item.name].is_a? Dynamic
    end

    def items
        @items.reject { |name,item| item.is_a?(Dynamic) }
    end

    def remove_item item
        @items.delete item.name unless item.is_a? Dynamic
    end

    def name
        "> #{super}"
    end

    def to_s
        string = "#{name}\n"
        string += (@items.keys.sort.map {|name| name.prepend("  ")}).join("\n")
    end

    def execute
        show = true
        while show
            selection = show_menu @items.keys.sort, @name
            item = @items[selection]
            if item.nil?
                show = false
            else
                show = !item.execute unless item.nil?
            end
        end
        !item.nil?
    end
    def filter_entries entries
        if @items.nil?
            entries
        else
            entries.reject {|entry| @items[entry].is_a?(Editor)}
        end
    end
    def show_menu entries, name, show_edit_menu = true
        entries = filter_entries entries
        unless $read_only || self.is_a?(Dynamic)
            entries << "> #{Editor.name}"
        end
        command = "echo \"#{entries.join "\n"}\" | dmenu -i -b -l #{$lines} #{get_font_string} -nf \"#{@style.color :fg}\" -nb \"#{@style.color :bg}\" -sf \"#{@style.color :fg_hi}\" -sb \"#{@style.color :bg_hi}\" -p \"#{name}\""
        (`#{command}`).strip
    end

    def get_font_string
        font = ""
        unless self.style.font.nil?
            font = "-fn \"#{self.style.font}\""
        end
        font
    end

end
