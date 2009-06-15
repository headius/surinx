require 'juby/ast'
require 'bitescript'
require 'jruby'

BiteScript.bytecode_version = BiteScript::JAVA1_7

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

  def load(want_name)
    cls = nil
    @fb.generate do |name, cb|
      if name.split('.class')[0] == want_name.split('.jb')[0]
        cls = JRuby.runtime.jruby_class_loader.define_class(name.split('.class')[0], cb.generate.to_java_bytes)
        break
      end
    end
    cls
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

  def float(value)
    @mb.ldc_double(value)
    @mb.invokestatic java.lang.Double, 'valueOf', [java.lang.Double, Java::double]
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
