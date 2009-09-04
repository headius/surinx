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
  def compile(compiler)
    if lightweight?
      child_nodes.each {|node| compiler.compile(node)}
    else
      raise "non-lightweight array not supported"
    end
  end
end

class org::jruby::ast::BlockNode
  def build(body)
    child_nodes.each{|n| n.build(body)}
  end
  def compile(compiler)
    compiler.body(child_nodes)
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

  def compile(compiler)
    compiler.compile(receiver_node)
    compiler.compile(args_node)
    compiler.call name, args_node.size + 1
  end
end

class org::jruby::ast::ConstDeclNode
  def compile(compiler)
    compiler.set_constant name, value_node
    compiler.compile value_node
  end
end

class org::jruby::ast::ConstNode
  def compile(compiler)
    compiler.get_constant name
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

  def compile(compiler)
    if name == "puts"
      compiler.compile(args_node)
      compiler.puts
    else
      compiler.this
      compiler.compile(args_node)
      compiler.call name, args_node.size + 1
    end
  end
end

class org::jruby::ast::DefnNode
  def compile(compiler)
    if args_node.pre
      compiler.defn name, args_node.pre.child_nodes, body_node
    else
      compiler.defn name, nil, body_node
    end
  end
end

class org::jruby::ast::FalseNode
  def compile(compiler)
    compiler.false
  end
end

class org::jruby::ast::FixnumNode
  def compile(compiler)
    compiler.fixnum value
  end
end

class org::jruby::ast::FloatNode
  def compile(compiler)
    compiler.float value
  end
end

class org::jruby::ast::IfNode
  def compile(compiler)
    compiler.branch condition, then_body, else_body
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

class org::jruby::ast::ReturnNode
  def compile(compiler)
    compiler.return(value_node)
  end
end

class org::jruby::ast::RootNode
  def compile(compiler)
    compiler.root(self)
  end
end

class org::jruby::ast::StrNode
  def compile(compiler)
    compiler.string(value)
  end
end

class org::jruby::ast::TrueNode
  def compile(compiler)
    compiler.true
  end
end

class org::jruby::ast::VCallNode
  def compile(compiler)
    compiler.this
    compiler.call name, 1
  end
end

class org::jruby::ast::WhileNode
  def compile(compiler)
    compiler.loop(condition_node, body_node)
  end
end
