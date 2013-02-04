Gem::Specification.new do |s|
    s.name          = 'dynmenu'
    s.version       = '0.1'
    s.date          = '2013-02-03'
    s.summary       = "Dynmenu"
    s.description   = 'A dmenu wrapper for subtle wm'
    s.authors       = ["Joakim Reinert"]
    s.email         = 'mail@jreinert.com'
    s.files         = Dir.glob("lib/*")
    s.executables   = ["dynmenu"]
    s.homepage      = 'https://github.com/supasnashbuhl/dynmenu'
    s.requirements  = ['dmenu']
end

