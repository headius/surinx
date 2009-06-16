/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package com.headius.juby;

import java.dyn.CallSite;
import java.dyn.Linkage;
import java.dyn.MethodHandle;
import java.dyn.MethodHandles;
import java.dyn.MethodType;
import java.lang.reflect.Method;

/**
 *
 * @author headius
 */
public class SimpleJavaBootstrap {
    public static CallSite bootstrap(Class caller, String name, MethodType type) {
        CallSite site = new CallSite(caller, name, type);
        site.setTarget(MethodHandles.collectArguments(MethodHandles.insertArguments(FALLBACK, 0, site), type));
        return site;
    }

    public static void registerBootstrap(Class cls) {
        Linkage.registerBootstrapMethod(cls, BOOTSTRAP);
    }

    public static final MethodHandle BOOTSTRAP = MethodHandles.lookup().findStatic(SimpleJavaBootstrap.class, "bootstrap", Linkage.BOOTSTRAP_METHOD_TYPE);

    public static Object fallback(CallSite site, Object receiver, Object[] args) throws Throwable {
        Method rMethod;
        MethodHandle target = null;
        if (site.name().equals("+")) {
            // primitive math
            Class[] argTypes = new Class[args.length + 1];
            argTypes[0] = receiver.getClass();
            for (int i = 0; i < args.length; i++) {
                argTypes[i + 1] = args[i].getClass();
            }
            rMethod = SimpleJavaBootstrap.class.getMethod("plus", argTypes);
            target = MethodHandles.lookup().unreflect(rMethod);
            target = MethodHandles.convertArguments(target, site.type());
        } else if (site.name().equals("-")) {
            // primitive math
            Class[] argTypes = new Class[args.length + 1];
            argTypes[0] = receiver.getClass();
            for (int i = 0; i < args.length; i++) {
                argTypes[i + 1] = args[i].getClass();
            }
            rMethod = SimpleJavaBootstrap.class.getMethod("minus", argTypes);
            target = MethodHandles.lookup().unreflect(rMethod);
            target = MethodHandles.convertArguments(target, site.type());
        } else if (site.name().equals("==")) {
            // booleans return non-null on truth
            Class[] argTypes = new Class[args.length + 1];
            argTypes[0] = receiver.getClass();
            for (int i = 0; i < args.length; i++) {
                argTypes[i + 1] = args[i].getClass();
            }
            rMethod = SimpleJavaBootstrap.class.getMethod("equals", argTypes);
            target = MethodHandles.lookup().unreflect(rMethod);
            target = MethodHandles.convertArguments(target, site.type());
        } else if (site.name().equals("__lt__")) {
            // booleans return non-null on truth
            Class[] argTypes = new Class[args.length + 1];
            argTypes[0] = receiver.getClass();
            for (int i = 0; i < args.length; i++) {
                argTypes[i + 1] = args[i].getClass();
            }
            rMethod = SimpleJavaBootstrap.class.getMethod(site.name(), argTypes);
            target = MethodHandles.lookup().unreflect(rMethod);
            target = MethodHandles.convertArguments(target, site.type());
        } else if (site.name().equals("__gt__")) {
            // booleans return non-null on truth
            Class[] argTypes = new Class[args.length + 1];
            argTypes[0] = receiver.getClass();
            for (int i = 0; i < args.length; i++) {
                argTypes[i + 1] = args[i].getClass();
            }
            rMethod = SimpleJavaBootstrap.class.getMethod(site.name(), argTypes);
            target = MethodHandles.lookup().unreflect(rMethod);
            target = MethodHandles.convertArguments(target, site.type());
        } else if (site.name().equals("__le__")) {
            // booleans return non-null on truth
            Class[] argTypes = new Class[args.length + 1];
            argTypes[0] = receiver.getClass();
            for (int i = 0; i < args.length; i++) {
                argTypes[i + 1] = args[i].getClass();
            }
            rMethod = SimpleJavaBootstrap.class.getMethod(site.name(), argTypes);
            target = MethodHandles.lookup().unreflect(rMethod);
            target = MethodHandles.convertArguments(target, site.type());
        } else if (site.name().equals("__ge__")) {
            // booleans return non-null on truth
            Class[] argTypes = new Class[args.length + 1];
            argTypes[0] = receiver.getClass();
            for (int i = 0; i < args.length; i++) {
                argTypes[i + 1] = args[i].getClass();
            }
            rMethod = SimpleJavaBootstrap.class.getMethod(site.name(), argTypes);
            target = MethodHandles.lookup().unreflect(rMethod);
            target = MethodHandles.convertArguments(target, site.type());
        } else {
            // look for exact match for arg types
            Class[] argTypes = new Class[args.length];
            for (int i = 0; i < argTypes.length; i++) {
                argTypes[i] = args[i].getClass();
            }
            
            Class rClass = null;
            if (receiver == null) {
                rClass = site.callerClass();
                try {
                    rMethod = rClass.getMethod(site.name(), argTypes);
                    target = MethodHandles.lookup().findStatic(rClass, site.name(), site.type());
                    target = MethodHandles.convertArguments(target, site.type());
                } catch (NoSuchMethodException nsme) {
                    // hacky...try with all Object
                    for (int i = 0; i < argTypes.length; i++) {
                        argTypes[i] = Object.class;
                    }
                    rMethod = rClass.getMethod(site.name(), argTypes);
                    target = MethodHandles.lookup().unreflect(rMethod);
                    target = MethodHandles.dropArguments(target, 0, Object.class);
                    target = MethodHandles.convertArguments(target, site.type());
                }
            } else {
                rClass = receiver.getClass();
                rMethod = rClass.getMethod(site.name(), argTypes);
                target = MethodHandles.lookup().unreflect(rMethod);
                target = MethodHandles.convertArguments(target, site.type());
            }
        }

        Object result = null;
        switch (args.length) {
        case 0:
            result = MethodHandles.invoke_1(target, receiver);
            break;
        case 1:
            result = MethodHandles.invoke_2(target, receiver, args[0]);
            break;
        case 2:
            result = MethodHandles.invoke_3(target, receiver, args[0], args[1]);
            break;
        case 3:
            result = MethodHandles.invoke_4(target, receiver, args[0], args[1], args[2]);
            break;
        case 4:
            result = MethodHandles.invoke_5(target, receiver, args[0], args[1], args[2], args[3]);
            break;
        case 5:
            result = MethodHandles.invoke_6(target, receiver, args[0], args[1], args[2], args[3], args[4]);
            break;
        case 6:
            result = MethodHandles.invoke_7(target, receiver, args[0], args[1], args[2], args[3], args[4], args[5]);
            break;
        case 7:
            result = MethodHandles.invoke_8(target, receiver, args[0], args[1], args[2], args[3], args[4], args[5], args[6]);
            break;
        case 8:
            result = MethodHandles.invoke_9(target, receiver, args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7]);
            break;
        case 9:
            result = MethodHandles.invoke_10(target, receiver, args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8]);
            break;
        default:
            throw new RuntimeException("unsupported arity: " + args.length);
        }
        site.setTarget(target);
        return result;
    }

    public static final MethodHandle FALLBACK = MethodHandles.lookup().findStatic(SimpleJavaBootstrap.class, "fallback", MethodType.make(Object.class, CallSite.class, Object.class, Object[].class));

    public static final Boolean __lt__(Long a, Long b) {
        return a < b;
    }

    public static final Boolean __gt__(Long a, Long b) {
        return a > b;
    }

    public static final Boolean __le__(Long a, Long b) {
        return a <= b;
    }

    public static final Boolean __ge__(Long a, Long b) {
        return a >= b;
    }

    public static final Long plus(Long a, Long b) {
        return a + b;
    }

    public static final Double plus(Double a, Double b) {
        return a + b;
    }

    public static final Double plus(Double a, Long b) {
        return a + b;
    }

    public static final Double plus(Long a, Double b) {
        return a + b;
    }

    public static final Long minus(Long a, Long b) {
        return a - b;
    }

    public static final Double minus(Double a, Double b) {
        return a - b;
    }

    public static final Double minus(Double a, Long b) {
        return a - b;
    }

    public static final Double minus(Long a, Double b) {
        return a - b;
    }

    public static final Boolean equals(Long a, Long b) {
        return a.equals(b);
    }

    public static final Boolean equals(Double a, Double b) {
        return a.equals(b);
    }

    public static final Boolean equals(Double a, Long b) {
        return ((Double)(double)b).equals(a);
    }

    public static final Boolean equals(Long a, Double b) {
        return ((Double)(double)a).equals(b);
    }

    public static final Boolean equals(Integer a, Integer b) {
        return a.equals(b);
    }

    public static final Boolean equals(Integer a, Long b) {
        // have to upcast or it always returns false
        return ((Long)(long)a).equals(b);
    }

    public static final Boolean equals(Long a, Integer b) {
        // have to upcast or it always returns false
        return ((Long)(long)b).equals(a);
    }

    public static final Boolean equals(Integer a, Double b) {
        // have to upcast or it always returns false
        return ((Double)(double)a).equals(b);
    }

    public static final Boolean equals(Double a, Integer b) {
        // have to upcast or it always returns false
        return ((Double)(double)b).equals(a);
    }
}
