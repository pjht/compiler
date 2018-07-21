require_relative "parser.rb"
require_relative "interpreter.rb"
require_relative "copyprop.rb"
require_relative "deadopt.rb"
if ARGV[0]!=nil
  parser=Parser.new(File.read(ARGV[0]))
else
  parser=Parser.new(File.read("prg.lang"))
end
parser.parse
opt=CopyProp.new(parser.output)
opt=DeadOpt.new(opt.optimize)
out=opt.optimize
p out
interp=Interpreter.new(out)
interp.run
