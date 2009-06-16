require 'java'

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
    compiler.body(child_nodes)
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
      compiler.call name, args_node.size + 1
    end
  end
end

class org::jruby::ast::DefnNode
  def compile(compiler)
    compiler.defn name, args_node.pre.child_nodes, body_node
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
