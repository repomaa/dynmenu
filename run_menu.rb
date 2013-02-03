require_relative 'menu'
require_relative 'dynamic'
class Run_Menu < Menu

    include Dynamic

    @@RE_HIDDEN = Regexp.new /\/{,1}\.[^\/]*$/ 
        def initialize parent, history = History.new(1, 5), name = "Run"
            @name = name 
            @parent = parent
            @history = history
            set_style parent.style
        end

    def name
        ">#{super}"
    end

    def execute
        command = show_menu
        Command.new("", command).execute
        @history.update command unless command.empty?
        !command.empty?        
    end

    def show_menu
        get_files
        history_items = @history.items
        items = history_items[:first] + @files + history_items[:rest] 
        super items, @name
    end

    def get_files dirs = (`echo $PATH`).split(':')
        @files = []
        dirs.each do |dir|
            get_files_rec dir
        end
    end
    def get_files_rec file
        return if file.match @@RE_HIDDEN
        if File.directory? file
            Dir.foreach file do |cur_file|
                get_files_rec cur_file
            end
        else
            @files << file
        end
    end

end
