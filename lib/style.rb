class Style
    @@re_color = Regexp.new(/^#[0-9a-fA-F]{6}$/)
    def initialize
        @colors = {
            :bg     => "#202020",
            :fg     => "#757575",
            :bg_hi  => "#303030",
            :fg_hi  => "#FECF35"
        }
    end

    def set_color color, value
        unless @colors.keys.include? color
            raise ArgumentError, "Invalid key!"
        end
        unless @@re_color.match value
            raise ArgumentError, "Invalid color string!"
        end
        @colors[color] = value
    end

    def color color
        unless @colors.keys.include? color
            raise ArgumentError, "Invalid key!"
        end
        @colors[color]
    end

    def set_font font
        @font = font
    end
    def to_s
        string = ""
        string = @font unless @font.nil?
        string += " #{@colors}"
    end

    def font
        @font
    end
end
