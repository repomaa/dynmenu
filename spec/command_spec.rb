require 'spec_helper.rb'

describe Command do

    before :each do
        @command = Command.new '', ''
    end
    
    describe "#command=" do
        it "takes a string and processes it into a command" do
            @command = Command.new '', ''
            @command.command = 'foo'
            @command.should_not eql ''
        end
        it "turns a web search command into an uri" do
            @command.command = 'g test search'
            @command.command.should be_a URI
        end
        it "turns a web search command into an appropriate uri" do
            @command.command = 'g test search'
            @command.command.to_s.should eql "https://www.google.com/#q=test%20search"
        end
        it "turns a url string into an appropriate uri" do
            @command.command = 'http://www.google.com'
            @command.command.should be_a URI
            @command.command.to_s.should eql 'http://www.google.com'
        end
        it "parses subtle mode flags and stores command and arguments in @app" do
            $subtle = true
            @command.command = 'foo -bar +^*='
            @command.modes.should eql [:full, :float, :stick, :zaphod]
            @command.app.should eql 'foo -bar'
        end
        it "parses subtle tags" do
            @command.command = 'foo -bar #foo #bar'
            @command.tags.should eql ['foo', 'bar']
        end
        it "parses subtle views" do
            @command.command = 'foo -bar @foo @bar'
            @command.views.should eql ['foo', 'bar']
        end
        it "parses subtle mode flags, tags, views and stores command and args in @app" do
            @command.command = '+^*= foo -bar #tag1 @view1 #tag2 @view2'
            @command.modes.should eql [:full, :float, :stick, :zaphod]
            @command.tags.should eql ['tag1', 'tag2']
            @command.views.should eql ['view1', 'view2']
            @command.app.should eql 'foo -bar'
        end
    end

end
