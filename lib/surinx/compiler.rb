require 'surinx/ast'
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
      if name.split('.class')[0] == want_name.split('.sx')[0]
        cls = JRuby.runtime.jruby_class_loader.define_class(name.split('.class')[0], cb.generate.to_java_bytes)
        break
      end
    end
    cls
  end

  def body(nodes)
    compile(nodes[0])
    a = 1
    while a < nodes.length
      @mb.pop
      compile(nodes[a])
      a += 1
    end
  end

  def defn(name, args, body)
    args ||= []
    arg_count = args.length

    old_mb, @mb = @mb, @cb.public_static_method(name, java.lang.Object, *([java.lang.Object] * arg_count))
    @mb.start
    args.each {|arg| @mb.local arg.name}
    compile(body)
    @mb.areturn
    @mb.stop
    @mb = old_mb
    @mb.aconst_null
  end

  def compile(node)
    node.compile(self)
  end

  def line(node)
    @mb.line node.position.start_line
    compile(node)
  end

  def root(node)
    @cb = @fb.public_class(@filename.split('.sx')[0])
    class << @cb
      attr_accessor :bootstrapped
      alias :bootstrapped? :bootstrapped
    end

    @mb = @cb.public_static_method 'main', Java::void, java.lang.String[]
    @mb.start
    body(node.child_nodes)
    @mb.pop
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
  
  def string(value)
    @mb.ldc(value)
  end

  def puts
    @mb.aprintln
    @mb.aconst_null
  end
  
  def print
    @mb.getstatic java.lang.System, "out", java.io.PrintStream
    @mb.swap
    @mb.invokevirtual java.io.PrintStream, "print", [Java::void, java.lang.Object]
    @mb.aconst_null
  end

  NAME_TRANSLATED = Hash.new {|hash, key| key}
  NAME_TRANSLATED["<"] = "__lt__"
  NAME_TRANSLATED[">"] = "__gt__"
  NAME_TRANSLATED["<="] = "__le__"
  NAME_TRANSLATED[">="] = "__ge__"

  def call(name, size)
    # install bootstrap if this is the first dynamic call
    bootstrap unless @cb.bootstrapped?
    name = NAME_TRANSLATED[name]
    @mb.invokedynamic java.lang.Object, name, [java.lang.Object, *([java.lang.Object] * size)]
  end
  
  def set_constant(name, body)
    instance_variable_set "@#{name}", body
  end
  
  def get_constant(name)
    compile(instance_variable_get "@#{name}")
  end

  def branch(condition, then_body, else_body)
    els = @mb.label
    done = @mb.label
    compile(condition)
    @mb.getstatic java.lang.Boolean, "FALSE", java.lang.Boolean
    if then_body
      @mb.if_acmpeq els
      compile(then_body)
    else
      @mb.aconst_null
    end
    @mb.goto done
    els.set!
    if else_body
      compile(else_body)
    else
      @mb.aconst_null
    end
    done.set!
  end

  def this
    if @mb.static
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
    @mb.pop
    @mb.goto top
    bottom.set!
    @mb.aconst_null
  end
  
  def for_range(start, finish, exclusive, variable, body)
    @mb.ldc_int(start)
    @mb.istore @mb.local(variable.name + "__loop")
    start_lbl = @mb.label
    finish_lbl = @mb.label
    inc = start < finish ? 1 : -1
    
    start_lbl.set!
    @mb.iload @mb.local(variable.name + "__loop")
    @mb.ldc_int(finish)
    if inc == 1
      if exclusive
        @mb.if_icmpeq finish_lbl
      else
        @mb.if_icmpgt finish_lbl
      end
    else
      if exclusive
        @mb.if_icmpeq finish_lbl
      else
        @mb.if_icmplt finish_lbl
      end
    end
    
    @mb.iload @mb.local(variable.name + "__loop")
    @mb.i2l
    @mb.invokestatic java.lang.Long, 'valueOf', [java.lang.Long, Java::long]
    @mb.astore @mb.local(variable.name)
    
    compile(body)
    @mb.pop
    
    @mb.iinc @mb.local(variable.name + "__loop"), inc
    @mb.goto start_lbl
    
    finish_lbl.set!
    @mb.aconst_null
  end

  def bootstrap
    @cb.static_init do
      ldc this.name
      invokestatic java.lang.Class, "forName", [java.lang.Class, string]
      invokestatic com.headius.surinx.SimpleJavaBootstrap, "registerBootstrap", [void, java.lang.Class]
      returnvoid
    end
    @cb.bootstrapped = true
  end

  def true
    @mb.getstatic java.lang.Boolean, "TRUE", java.lang.Boolean
  end

  def false
    @mb.getstatic java.lang.Boolean, "FALSE", java.lang.Boolean
  end

  def return(body)
    if body
      compile(body)
    else
      @mb.aconst_null
    end
    @mb.areturn
  end
end
