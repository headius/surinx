==Preparing to run Surinx==

You will need MLVM/Da Vinci machine with current patches.

Compile the bootstrap class:

  javac src/com/headius/surinx/SimpleJavaBootstrap.java

==Compiling Surinx source==

jruby -J-cp src -J-XX:+EnableInvokeDynamic bin/surinxc <src.jb>

or

jruby -J-cp src -J-XX:+EnableInvokeDynamic bin/surinxc -e "surinx script here"

The latter will produce a "dash_e.class"

==Running the compiled result==

java -XX:+EnableInvokeDynamic -cp src:. <classname>

==Notes==


