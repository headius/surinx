require 'rubygems'
require 'bitescript'
require 'jruby'

BiteScript.bytecode_version = BiteScript::JAVA1_7

class org::jruby::ast::ArrayNode
  def compile(compiler)
    if lightweight?
      child_nodes.each {|node| compiler.compile(node)}
    else
      raise "non-lightweight array not supported"
    end
  end
end

class org::jruby::ast::BlockNode
  def compile(compiler)
    child_nodes.each {|node| compiler.compile(node)}
  end
end

class org::jruby::ast::CallNode
  def compile(compiler)
    compiler.compile(receiver_node)
    compiler.compile(args_node)
    compiler.call name, args_node.size + 1
  end
end
      
class org::jruby::ast::FCallNode
  def compile(compiler)
    if name == "puts"
      compiler.compile(args_node)
      compiler.puts
    else
      compiler.this
      compiler.compile(args_node)
      compiler.call name, args_node.size
    end
  end
end
      
class org::jruby::ast::FixnumNode
  def compile(compiler)
    compiler.fixnum value
  end
end

class org::jruby::ast::LocalAsgnNode
  def compile(compiler)
    compiler.compile(value_node)
    compiler.assign_local(name)
  end
end

class org::jruby::ast::LocalVarNode
  def compile(compiler)
    compiler.retrieve_local(name)
  end
end

class org::jruby::ast::NewlineNode
  def compile(compiler)
    compiler.line(next_node)
  end
end

class org::jruby::ast::RootNode
  def compile(compiler)
    compiler.root(self)
  end
end

class org::jruby::ast::WhileNode
  def compile(compiler)
    compiler.loop(condition_node, body_node)
  end
end


class Compiler
  def initialize(filename)
    @filename = filename
    @fb = BiteScript::FileBuilder.new(filename)
  end

  def write
    @fb.generate do |name, cb|
      File.open(name, 'w') {|f| f.write cb.generate}
    end
  end

  def compile(node)
    node.compile(self)
  end

  def line(node)
    @mb.line node.position.start_line
    compile(node)
    @mb.pop
  end

  def root(node)
    @cb = @fb.public_class(@filename.split('.jb')[0])
    class << @cb
      attr_accessor :bootstrapped
      alias :bootstrapped? :bootstrapped
    end

    @mb = @cb.public_static_method 'main', Java::void, java.lang.String[]
    @mb.start
    node.child_nodes.each {|n| compile(n)}
    @mb.returnvoid
    @mb.stop
  end
    
  def newline(node)
    compile(node.next_node)
  end

  def fixnum(value)
    @mb.ldc_long(value)
    @mb.invokestatic java.lang.Long, 'valueOf', [java.lang.Long, Java::long]
  end

  def puts
    @mb.aprintln
    @mb.aconst_null
  end

  def call(name, size)
    # install bootstrap if this is the first dynamic call
    bootstrap unless @cb.bootstrapped?
    @mb.invokedynamic java.lang.Object, name, [java.lang.Object, *([java.lang.Object] * size)]
  end

  def this
    if @mb.static?
      @mb.aconst_null
    else
      @mb.aload 0
    end
  end

  def assign_local(name)
    @mb.dup
    @mb.astore(@mb.local name)
  end

  def retrieve_local(name)
    @mb.aload(@mb.local name);
  end

  def loop(condition, body)
    top = @mb.label
    bottom = @mb.label
    top.set!
    compile(condition)
    @mb.getstatic java.lang.Boolean, "FALSE", java.lang.Boolean
    @mb.if_acmpeq bottom
    compile(body)
    @mb.goto top
    bottom.set!
    @mb.aconst_null
  end

  def bootstrap
    @cb.static_init do
      ldc this.name
      invokestatic java.lang.Class, "forName", [java.lang.Class, string]
      invokestatic com.headius.juby.SimpleJavaBootstrap, "registerBootstrap", [void, java.lang.Class]
      returnvoid
    end
    @cb.bootstrapped = true
  end
end

if $0 == __FILE__
  if ARGV[0] == '-e'
    src = ARGV[1]
    name = "dash_e"
  else
    src = File.read(ARGV[0])
    name = ARGV[0]
  end

  node = JRuby.parse(src)
  c = Compiler.new(name)
  c.compile(node)
  c.write
end
