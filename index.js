import { findNodeHandle, NativeModules } from 'react-native';

const { RNAnimatedProps } = NativeModules;

export function connect(view, node, on) {
  const vieTag = findNodeHandle(view);
  const nativeNodeTag = node.__getNativeTag()
  RNAnimatedProps.connect(vieTag, nativeNodeTag, on)

}

