require 'item'
require 'uri'


class Command
    @@RE_COMMAND = Regexp.new(/^[+\^\*]*.+(\s[+\^\*])*(\s[@#][A-Za-z0-9_-]+)*$/)
    @@RE_MODES   = Regexp.new(/^[+\^\*=]+$/)
    @@RE_METHOD  = Regexp.new(/^:\s*(.*)/)
    @@RE_BROWSER = Regexp.new(/(chrom[e|ium]|iron|navigator|firefox|opera)/i) 
    @@RE_SEARCH  = Regexp.new(/^[gs]\s+(.*)/)
    @@RE_URI = Regexp.new(/^((w\s+((https?|ftp):\/\/)?)|(https?|ftp):\/\/)(?:[A-Z0-9-]+.)+[A-Z]{2,6}([\/?].+)?$/i)
    @@RE_PROTO = Regexp.new(/^(http|https):\/\/.*/)

    include Item

    attr_reader :tags, :views, :app, :modes, :command

    def initialize name, command = nil
        @name = name
        clear_subtle_vars
        self.command = command
    end

    def clear_subtle_vars
        @tags = []
        @views = []
        @app = ""
        @modes = []
    end

    def encode_with coder
        coder['name'] = @name
        coder['command'] = @command
        coder['tags'] = @tags
        coder['views'] = @views
        coder['app'] = @app
        coder['modes'] = @modes
    end

    def init_with coder
        @name = coder['name']
        @command = coder['command']
        @tags = coder['tags']
        @views = coder['views']
        @app = coder['app']
        @modes = coder['modes']
    end

    def command= command
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
                    clear_subtle_vars

                    command.split.each do |arg|
                        case arg[0]
                        when '#' then @tags << arg[1..-1]
                        when '@' then @views << arg[1..-1]
                        when '+', '^', '*','='
                            mode_s = @@RE_MODES.match(arg).to_s
                            @modes += mode_s.split(//).map! do |c|
                                case c
                                when '+' then :full
                                when '^' then :float
                                when '*' then :stick
                                when '=' then :zaphod
                                end
                            end
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
                command = "#{@command} &>/dev/null"
                puts command if $debug
                system command 
            end
        when URI
            command = "xdg-open '#{@command.to_s}' &>/dev/null"
            puts command if $debug
            system command
            if $subtle
                browser = find_browser
                browser.focus unless browser.nil?
            end 
        end
        true
    end

    def subtle_execute
        if $debug
            puts "App: #{@app}"
            puts "Tags: #{@tags.to_s}"
            puts "Views: #{@views.to_s}"
            puts "Modes: #{@modes.to_s}"
        end
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
            client.flags = @modes unless @modes.empty?
        end
        true
    end
end
