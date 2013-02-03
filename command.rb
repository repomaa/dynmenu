require_relative 'item'

class Command
    if $subtle
        @@RE_COMMAND = Regexp.new(/^[+\^\*]*.+(\s[+\^\*])*(\s[@#][A-Za-z0-9_-]+)*$/)
        @@RE_MODES   = Regexp.new(/^[+\^\*]+$/)
        @@RE_SEARCH  = Regexp.new(/^[gs]\s+(.*)/)
        @@RE_METHOD  = Regexp.new(/^:\s*(.*)/)
        @@RE_BROWSER = Regexp.new(/(chrom[e|ium]|iron|navigator|firefox|opera)/i) 
    end
    @@RE_URI = Regexp.new(/^((w\s+((https?|ftp):\/\/)?)|(https?|ftp):\/\/)(?:[A-Z0-9-]+.)+[A-Z]{2,6}([\/?].+)?$/i)
    @@RE_PROTO = Regexp.new(/^(http|https):\/\/.*/)

    include Item

    def initialize name, command = nil
        @name = name
        if $subtle
            @tags = []
            @views = []
            @app = ""
            @modes = ""
        end

        set_command command
    end

    def encode_with coder
        coder['name'] = @name
        coder['command'] = @command
        if $subtle
            coder['tags'] = @tags
            coder['views'] = @views
            coder['app'] = @app
            coder['modes'] = @modes
        end
    end

    def init_with coder
        @name = coder['name']
        @command = coder['command']
        if $subtle
            @tags = coder['tags'] || []
            @views = coder['views'] || []
            @app = coder['app'] || ""
            @modes = coder['modes'] || ""
        end
    end

    def command
        @command
    end

    def set_command command
        unless command.nil? || command.empty?
            if @@RE_URI.match command
                split = Regexp.last_match(0).split(/\s+/)
                command = split[split.length - 1]
                command.prepend("http://") unless @@RE_PROTO.match command
                command = URI.parse command
            elsif @@RE_SEARCH.match command
                command = web_search Regexp.last_match(1) 
            elsif $subtle
                if @@RE_METHOD.match(command)
                    command = Regexp.last_match(0).to_sym      
                elsif @@RE_COMMAND.match command
                    @tags = []
                    @views = []
                    @app = ""
                    @modes = ""

                    command.split.each do |arg|
                        case arg[0]
                        when '#' then @tags << arg[1..-1]
                        when '@' then @views << arg[1..-1]
                        when '+', '^', '*'
                            @modes += @@RE_MODES.match(arg).to_s
                        else
                            if @app.nil? || @app.empty?
                                @app = arg
                            else
                                @app += ' ' + arg
                            end
                        end
                    end
                    if @views.any? and not @app.empty? and @tags.empty?
                        @tags << "tag_#{rand(1337)}"
                    end
                else
                    @app = command
                end
            end
        end
        @command = command
    end

    def web_search search_string, engine = :google
        escaped_string = URI.escape search_string
        case engine
        when :duckduckgo then escaped_string.prepend "https://duckduckgo.com/?q="
        else escaped_string.prepend "https://www.google.com/#q="
        end
        URI.parse escaped_string
    end

    def find_browser
        begin
            if @browser.nil?
                Subtlext::Client.all.each do |c|
                    if c.klass.match(@@RE_BROWSER)
                        @browser = c
                        @view = c.views.first
                        return
                    end
                end
            end
        rescue
            @browser = nil
            @view = nil
        end
    end

    def execute
        case @command
        when String
            if $subtle
                subtle_execute
            else
                system "#{@command} &>/dev/null"
            end
        when URI
            puts @command.to_s
            system "xdg-open '%s' &>/dev/null &" % [ @command.to_s ]
            if $subtle
                find_browser
                @browser.focus unless @browser.nil?
            end 
        end
        true
    end

    def subtle_execute
        tags = @tags.map do |t|
            tag = Subtlext::Tag.first(t) || Subtlext::Tag.new(t)
            tag.save
            tag
        end
        @views.each do |v|
            view = Subtlext::View.first(v) || Subtlext::View.new(v)
            view.save
            view.tag(tags) unless view.nil? or tags.empty?
        end
        unless (client = Subtlext::Client.spawn(@app)).nil?
            client.tags = tags unless tags.empty?
            unless @modes.empty?
                flags = []

                @modes.each_char do |c|
                    case c
                    when '+' then flags << :full
                    when '^' then flags << :float
                    when '*' then flags << :stick
                    when '=' then flags << :zaphod
                    end
                end
                client.flags = flags
            end
        end
    end

    def to_s
        "#{@name} => #{command}"
    end
end
