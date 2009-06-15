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
        // look for exact match for arg types
        Class rClass = receiver.getClass();
        Class[] argTypes = new Class[args.length];
        for (int i = 0; i < argTypes.length; i++) {
            argTypes[i] = args[i].getClass();
        }
        Method rMethod = rClass.getMethod(site.name(), argTypes);

        MethodHandle target = MethodHandles.lookup().unreflect(rMethod);
        target = MethodHandles.convertArguments(target, site.type());
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
}
