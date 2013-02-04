version = `git describe --abbrev=0 --tags`[/\d(\.\d){,2}/]
File.open(".version", "w+") {|f| f.write "#{version}\n"}
Gem::Specification.new do |s|
    s.name          = 'dynmenu'
    s.version       = version
    s.date          = `git show -s --format="%ci"`.split(" ").first
    s.summary       = "Dynmenu"
    s.description   = 'A dmenu wrapper for subtle wm'
    s.authors       = ["Joakim Reinert"]
    s.email         = 'mail@jreinert.com'
    s.files         = Dir.glob("lib/*")
    s.executables   = ["dynmenu"]
    s.homepage      = 'https://github.com/supasnashbuhl/dynmenu'
    s.requirements  = ['dmenu']
end

