require 'menu'

class Root_Menu < Menu

    attr_writer :run_menu
    attr_reader :history

    def initialize history_length = 1000, history_items = 5
        super "Dynmenu"
        self.run_menu = true
        @history = History.new history_length, history_items
        set_item Run_Menu.new self, @history
    end

    def run_menu?
        @run_menu
    end
    
    def filter_entries entries
        partitions = super.partition {|entry| @items[entry].is_a?(Run_Menu)}
        if run_menu?
            partitions[0] + partitions[1]
        else
            partitions[1]
        end
    end


    def encode_with coder
        super
        coder['run_menu'] = @run_menu
        coder['history'] = @history
    end

    def init_with coder
        super
        @run_menu = coder['run_menu']
        @history = coder['history']
        set_item Run_Menu.new self, @history if @run_menu
    end
end
