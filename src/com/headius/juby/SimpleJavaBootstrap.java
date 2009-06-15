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

/**
 *
 * @author headius
 */
public class SimpleJavaBootstrap {
    public static CallSite bootstrap(Class caller, String name, MethodType type) {
        CallSite site = new CallSite(caller, name, type);
        site.setTarget(MethodHandles.collectArguments(FALLBACK, type));
        return site;
    }

    public static void registerBootstrap(Class cls) {
        Linkage.registerBootstrapMethod(cls, BOOTSTRAP);
    }

    public static final MethodHandle BOOTSTRAP = MethodHandles.lookup().findStatic(SimpleJavaBootstrap.class, "bootstrap", Linkage.BOOTSTRAP_METHOD_TYPE);

    public static Object fallback(CallSite site, Object receiver, Object[] args) {
        MethodHandle target = MethodHandles.lookup().findVirtual(receiver.getClass(), site.name(), site.type());
        Object result = MethodHandles.invoke(target, receiver, args);
        site.setTarget(target);
        return result;
    }

    public static final MethodHandle FALLBACK = MethodHandles.lookup().findStatic(SimpleJavaBootstrap.class, "fallback", MethodType.make(Object.class, CallSite.class, Object.class, Object[].class));
}
