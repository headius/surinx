==Preparing to run Juby==

You will need MLVM/Da Vinci machine with current patches.

Compile the bootstrap class:

  javac src/com/headius/juby/SimpleJavaBootstrap.java

==Compiling Juby source==

jruby -J-cp src -J-XX:+EnableInvokeDynamic bin/jubyc <src.jb>

or

jruby -J-cp src -J-XX:+EnableInvokeDynamic bin/jubyc -e "juby script here"

The latter will produce a "dash_e.class"

==Running the compiled result==

java -Xint -XX:+EnableInvokeDynamic -cp src:. <classname>

==Notes==

-Xint is only necessary until MLVM/DVM has JIT support for invokedynamic
