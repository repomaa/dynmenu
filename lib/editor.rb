require 'menu'
require 'dynamic'

class Editor < Menu
    
    include Dynamic

    @@name = "Edit menu"

    def self.name
        @@name
    end

    def name
        "> #{@@name}"
    end

    def initialize parent
        @parent = parent
        set_style parent.style
    end

    def to_s
        "Edit menu"
    end

    def execute
        entries = []
        selection = nil
        while selection != "" && (entries.index selection) != entries.length - 1
            entries = ["Name (#{@parent.name})"]
            entries << "Style"
            entries << "Entries"
            entries << "Run menu"
            entries << "Done"
            selection = show_menu entries, @@name
            case entries.index selection
            when 0 then @parent.set_name show_menu([@parent.name], "Edit Name")
            when 1 then @parent.set_style show_style_menu
            when 2 then show_entries_menu
            when 3 then show_run_menu_menu
            end
        end
        @parent.execute
    end

    def show_run_menu_menu
        entries = []
        selection = nil
        while selection != "" && (entries.index selection) != entries.length - 1
            if @parent.run_menu?
                entries = ["Disable run menu"]
            else
                entries = ["Enable run menu"]
            end
            entries << "History"
            entries << "Done"
            selection = show_menu entries, "Run menu"
            case entries.index selection
            when 0 then @parent.set_run_menu !@parent.run_menu?
            when 1 then show_history_menu
            end
        end
    end

    def show_history_menu
        entries = []
        selection = nil
        clear = false
        while selection != "" && (entries.index selection) != entries.length - 1
            entries = ["History length (#{@parent.history.length})"]
            entries << "Items shown in run menu (#{@parent.history.show_num_items})"
            if clear
                entries << "Undo"
            else
                entries << "Clear history"
            end
            entries << "Done"

            selection = show_menu entries, "History"
            case entries.index.selection
            when 0
                selection = (show_menu [], "Enter a number")
                number = selection.to_i
                @parent.history.set_length number unless number < 1 || number.to_s != selection
            when 1
                selection = (show_menu [], "Enter a number")
                number = (show_menu [], "Enter a number").to_i
                @parent.history.set_show_num_items number unless number.to_s != selection
            when 2 then clear = !clear
            when (entries.length - 1) then @parent.history.clear if clear
            end
        end
    end

    def show_style_menu
        style = @parent.style
        entries = []
        selection = nil
        while selection != "" && (entries.index selection) != entries.length - 1
            entries = ["Background:          (#{style.color :bg})"]
            entries << "Foreground:          (#{style.color :fg})"
            entries << "Selected Background: (#{style.color :bg_hi})"
            entries << "Selected Foreground: (#{style.color :fg_hi})"
            if style.font.nil?
                entries << "Font:                (default)"
            else
                entries << "Font:                (#{style.font})"
            end
            entries << "Done"
            selection = show_menu entries, "Edit style"
            colors = [:bg, :fg, :bg_hi, :fg_hi]
            unless (entries.index selection).nil?
                if (entries.index selection) < 4
                    style.set_color colors[entries.index selection], show_menu([style.color(colors[entries.index selection])], "Enter a color")
                elsif (entries.index selection) < 5
                    if style.font.nil?
                        selection = show_menu(["default"], "Set font")
                    else
                        selection = show_menu([style.font], "Set font")
                    end
                    unless selection.nil? || selection == "default"
                        style.set_font selection
                    end
                end
            end
        end
        style
    end

    def show_menu entries, name, show_edit_menue = false
        super
    end

    def show_entries_menu
        entries = ["Edit/Remove entries"]
        entries << "Add entries"
        entries << "Done"
        selection = nil
        while selection != "" && (entries.index selection) != 2
            selection = show_menu entries, "Edit entries"
            case entries.index selection
            when 0 then show_edit_menu
            when 1 then show_add_menu
            end
        end
    end

    def show_edit_menu
        selection = nil
        while selection != "" && @parent.items[selection].nil?
            selection = show_menu @parent.items.keys.sort, "Select item to edit"
            item = @parent.items[selection]
            unless item.nil?
                if item.is_a? Command
                    show_edit_cmd_menu item
                else
                    show_edit_menu_menu item
                end
            end
        end
    end

    def show_add_menu
        entries = []
        entries = ["Command"]
        entries << "Menu"
        entries << "Done"
        selection = nil
        while selection != "" && (entries.index selection) != entries.length - 1
            selection = show_menu entries, "Add items"
            case entries.index selection
            when 0 then show_edit_cmd_menu
            when 1 then show_edit_menu_menu 
            end
        end
    end

    def show_edit_cmd_menu command = Command.new("New command", "")
        new = false
        if (@parent.remove_item command).nil?
            new = true
        end
        entries = []
        selection = nil
        delete = false
        while selection != "" && (entries.index selection) != entries.length - 1
            entries = ["Name (#{command.name})"]
            entries << "Command (#{command.command})"
            if new
                string = "Add command"
            else
                string = "Edit command"
                if delete
                    entries << "Undo"
                else
                    entries << "Delete"
                end
            end
            entries << "Done"
            selection = show_menu entries, "Add Command"
            case entries.index selection
            when 0 
                new_name = show_menu([command.name], "Enter a name")
                command.set_name new_name unless new_name.empty?
            when 1 
                history = History.new 1, 1
                history.update command.command unless command.command.nil? or command.command.empty?
                new_command = Run_Menu.new(self, history, "Enter a command").show_menu
                command.set_command new_command unless new_command.empty?
            when 2 then delete = !delete unless new
            end
        end
        delete = true if selection == "" && new
        @parent.set_item command unless delete
    end

    def show_edit_menu_menu menu = nil
        new = menu.nil?
        if new
            menu = Menu.new "New menu"
            menu.set_style @parent.style
        end
        @parent.remove_item menu
        entries = []
        selection = nil
        delete = false
        while selection != "" && (entries.index selection) != entries.length - 1
            entries = ["Name (#{menu.name})"]
            if new
                string = "Add menu"
            else
                string = "Edit menu"
                if delete
                    entries << "Undo"
                else
                    entries << "Remove"
                end
            end
            entries << "Done"
            selection = show_menu entries, string
            if (entries.index selection) == 0
                new_name = show_menu [], "Enter a name"
                menu.set_name new_name unless new_name.empty?
            end
            delete = !delete if (entries.index selection) == 1 && !new
        end
        delete = true if selection == "" && new
        @parent.set_item menu unless delete
    end
end
