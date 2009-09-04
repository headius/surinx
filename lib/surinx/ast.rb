require 'java'

class Operand

end

class Constant < Operand
  def initialize(type, value)
    @type, @value = type, value
  end
end

class Instruction < Operand

end

class LookupName < Instruction
  def initialize(name)
    @name = name
  end
end

class LookupMethod < Instruction
  def initialize(name, recv_type, arg_count)
    @name, @recv_type, @arg_count = name, recv_type, arg_count
  end
end

class ApplyMethod < Instruction
end

class org::jruby::ast::ArrayNode
  def compile(compiler, expr)
    if lightweight?
      child_nodes.each {|node| compiler.compile(node)}
    else
      raise "non-lightweight array not yet supported"
    end
  end
end

class org::jruby::ast::BlockNode
  def build(body)
    child_nodes.each{|n| n.build(body)}
  end
  def compile(compiler, expr)
    compiler.body(child_nodes, expr)
  end
end

class org::jruby::ast::CallNode
  def build(body)
    size = args ? args.child_nodes.size : 0
    body.add(LookupMethod.new(name, JObject, size))
    receiver_node.build(body)
    args_node.each{|n| n.build(body)} if size > 0
    body.add(ApplyMethod.new)
  end

  def compile(compiler, expr)
    compiler.compile(receiver_node)
    
    if args_node
      compiler.compile(args_node)
      compiler.call name, args_node.size + 1, expr
    else
      compiler.call name, 1, expr
    end
  end
end

class org::jruby::ast::ConstDeclNode
  def compile(compiler, expr)
    compiler.set_constant name, value_node
    compiler.compile value_node if expr
  end
end

class org::jruby::ast::ConstNode
  def compile(compiler, expr)
    compiler.get_constant name if expr
  end
end

class org::jruby::ast::FCallNode
  def build(body)
    size = args ? args.child_nodes.size : 0
    body.add(LookupMethod.new(name, JObject, size))
    receiver_node.build(body)
    args_node.each{|n| n.build(body)} if size > 0
    body.add(ApplyMethod.new)
  end

  def compile(compiler, expr)
    if name == "puts"
      compiler.compile(args_node)
      compiler.puts expr
    elsif name == "print"
      compiler.compile(args_node)
      compiler.print expr
    elsif name == "import"
      compiler.import args_node.get(0).value
      compiler.this if expr
    else
      compiler.this
      compiler.compile(args_node)
      compiler.call name, args_node.size + 1, expr
    end
  end
end

class org::jruby::ast::DefnNode
  def compile(compiler, expr)
    if args_node.pre
      compiler.defn name, args_node.pre.child_nodes, body_node
    else
      compiler.defn name, nil, body_node
    end
    compiler.this if expr
  end
end

class org::jruby::ast::FalseNode
  def compile(compiler, expr)
    compiler.false if expr
  end
end

class org::jruby::ast::FixnumNode
  def compile(compiler, expr)
    compiler.fixnum value if expr
  end
end

class org::jruby::ast::FloatNode
  def compile(compiler, expr)
    compiler.float value if expr
  end
end

class org::jruby::ast::ForNode
  def compile(compiler, expr)
    if org::jruby::ast::DotNode === iter_node
      # while loop
      start = iter_node.begin_node.value
      finish = iter_node.end_node.value
      compiler.for_range(start, finish, iter_node.exclusive?, var_node, body_node, expr)
    end
  end
end

class org::jruby::ast::IfNode
  def compile(compiler, expr)
    compiler.branch condition, then_body, else_body, expr
  end
end

class org::jruby::ast::LocalAsgnNode
  def compile(compiler, expr)
    compiler.compile(value_node)
    compiler.assign_local(name, expr)
  end
end

class org::jruby::ast::LocalVarNode
  def compile(compiler, expr)
    compiler.retrieve_local(name) if expr
  end
end

class org::jruby::ast::NewlineNode
  def compile(compiler, expr)
    compiler.line(next_node, expr)
  end
end

class org::jruby::ast::ReturnNode
  def compile(compiler, expr)
    compiler.return(value_node)
    compiler.this if expr
  end
end

class org::jruby::ast::RootNode
  def compile(compiler, expr)
    compiler.root(self, expr)
  end
end

class org::jruby::ast::StrNode
  def compile(compiler, expr)
    compiler.string(value) if expr
  end
end

class org::jruby::ast::TrueNode
  def compile(compiler, expr)
    compiler.true if expr
  end
end

class org::jruby::ast::VCallNode
  def compile(compiler, expr)
    if name == "puts"
      compiler.string("")
      compiler.puts expr
    else
      compiler.this
      compiler.call name, 1, expr
    end
  end
end

class org::jruby::ast::WhileNode
  def compile(compiler, expr)
    compiler.loop(condition_node, body_node)
    compiler.this if expr
  end
end
