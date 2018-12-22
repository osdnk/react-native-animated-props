package com.osdnk;

/**
 * Through me you pass into the city of woe:
 * Through me you pass into eternal pain:
 * Through me among the people lost for aye.
 * Justice the founder of my __fabric__ moved:
 * To rear me was the task of Power divine,
 * Supremest Wisdom, and primeval Love. 1
 * Before me things create were none, save things
 * Eternal, and eternal I endure.
 * All hope abandon, ye who enter here
 */


import android.util.SparseArray;
import com.facebook.react.animated.AnimatedNodeValueListener;
import com.facebook.react.animated.NativeAnimatedModule;
import com.facebook.react.bridge.GuardedRunnable;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.uimanager.ReactShadowNode;
import com.facebook.react.uimanager.UIImplementation;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.uimanager.UIManagerModule;

import java.lang.reflect.Field;
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.util.*;

public class RNAnimatedPropsModule extends ReactContextBaseJavaModule {

  private class PropsConnector {
    final int viewTag;
    final int nodeID;
    final String prop;

    private PropsConnector(int viewTag, int nodeID, String prop) {
      this.viewTag = viewTag;
      this.nodeID = nodeID;
      this.prop = prop;
    }
  }

  private final ReactApplicationContext reactContext;
  private UIManagerModule uiManagerModule;
  private NativeAnimatedModule nativeAnimatedModule;
  private UIImplementation uiImplementation;
  private Object mNodesManages = null;
  private Method startListeningToAnimatedNodeValue = null;
  private Method stopListeningToAnimatedNodeValue = null;
  private Class UIThreadOperation;
  private ArrayList<Object> mOperations;


  private final Set<PropsConnector> connectors = new HashSet<>();
  private final SparseArray<AnimatedNodeValueListener> listeners = new SparseArray<>();

  private AnimatedNodeValueListener getListenerForValue(final int nodeID) {
    final UIImplementation uiImplementation = this.uiImplementation;
    final UIManagerModule uiManagerModule = this.uiManagerModule;
    return new AnimatedNodeValueListener() {
      @Override
      public void onValueUpdate(final double value) {
        reactContext.runOnNativeModulesQueueThread(
          new GuardedRunnable(reactContext) {
            @Override
            public void runGuarded() {
              for (PropsConnector p : connectors) {
                if (p.nodeID == nodeID) {
                  final WritableMap nativeProps = Arguments.createMap();
                  nativeProps.putDouble(p.prop, value);
                  ReactShadowNode shadowNode = uiImplementation.resolveShadowNode(p.viewTag);
                  if (shadowNode != null) {
                    uiManagerModule.updateView(p.viewTag, shadowNode.getViewClass(), nativeProps);
                  }
                }
              }

              uiImplementation.dispatchViewUpdates(-1);
            }
          });
      }
    };
  }

  private void addListenerIfNeeded(final int nodeID) {
    boolean foundRegisteredLister = false;
    for (PropsConnector p : connectors) {
      if (p.nodeID == nodeID) {
        foundRegisteredLister = true;
        break;
      }
    }
    if (!foundRegisteredLister) {
      final AnimatedNodeValueListener listener = getListenerForValue(nodeID);
      listeners.put(nodeID, listener);
      Object instance = Proxy.newProxyInstance(UIThreadOperation.getClassLoader(), new Class<?>[]{UIThreadOperation}, new InvocationHandler() {
        @Override
        public Object invoke(Object o, Method method, Object[] objects) throws Throwable {
          startListeningToAnimatedNodeValue.invoke(mNodesManages, nodeID, listener);
          return null;
        }
      });

      mOperations.add(instance);
    }
  }

  private void removeListenerIfPossible(final int nodeID) {
    boolean foundRegisteredLister = false;
    for (PropsConnector p : connectors) {
      if (p.nodeID == nodeID) {
        foundRegisteredLister = true;
        break;
      }
    }
    if (!foundRegisteredLister) {
      listeners.delete(nodeID);
      Object instance = Proxy.newProxyInstance(UIThreadOperation.getClassLoader(), new Class<?>[]{UIThreadOperation}, new InvocationHandler() {
        @Override
        public Object invoke(Object o, Method method, Object[] objects) throws Throwable {
          stopListeningToAnimatedNodeValue.invoke(mNodesManages, nodeID);
          return null;
        }
      });

      mOperations.add(instance);
    }
  }


  @Override
  public void initialize() {
    // :sadparrot:
    uiManagerModule = reactContext.getNativeModule(UIManagerModule.class);
    nativeAnimatedModule = reactContext.getNativeModule(NativeAnimatedModule.class);
    uiImplementation = uiManagerModule.getUIImplementation();
    try {
      Method getNodesManager = nativeAnimatedModule.getClass().getDeclaredMethod("getNodesManager");
      getNodesManager.setAccessible(true);
      getNodesManager.invoke(nativeAnimatedModule);
      mNodesManages = getNodesManager.invoke(nativeAnimatedModule);
    } catch (IllegalAccessException e) {
      e.printStackTrace();
    } catch (NoSuchMethodException e) {
      e.printStackTrace();
    } catch (InvocationTargetException e) {
      e.printStackTrace();
    }
    try {
      startListeningToAnimatedNodeValue = mNodesManages.getClass()
        .getDeclaredMethod("startListeningToAnimatedNodeValue",
          int.class, AnimatedNodeValueListener.class);
      stopListeningToAnimatedNodeValue = mNodesManages.getClass()
        .getDeclaredMethod("stopListeningToAnimatedNodeValue",
          int.class);
    } catch (NoSuchMethodException e) {
      e.printStackTrace();
    }
    startListeningToAnimatedNodeValue.setAccessible(true);
    stopListeningToAnimatedNodeValue.setAccessible(true);

    UIThreadOperation = nativeAnimatedModule.getClass().getDeclaredClasses()[0];
    Field operations = null;
    try {
      operations = nativeAnimatedModule.getClass().getDeclaredField("mOperations");
    } catch (NoSuchFieldException e) {
      e.printStackTrace();
    }
    operations.setAccessible(true);
    try {
      mOperations = (ArrayList<Object>) operations.get(nativeAnimatedModule);
    } catch (IllegalAccessException e) {
      e.printStackTrace();
    }
  }


  public RNAnimatedPropsModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;

  }

  @Override
  public String getName() {
    return "RNAnimatedProps";
  }


  @ReactMethod
  public void connect(final int viewTag, final int nodeID, final String prop) {
    addListenerIfNeeded(nodeID);
    connectors.add(new PropsConnector(viewTag, nodeID, prop));
  }

  @ReactMethod
  public void disconnect(final int viewTag, final int nodeID, final String prop) {
    PropsConnector c;
    for (PropsConnector p : connectors) {
      if (p.nodeID == nodeID && p.viewTag == viewTag && p.prop == prop) {
        connectors.remove(p);
      }
    }
    removeListenerIfPossible(nodeID);

  }


}
