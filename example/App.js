import React, {Component} from 'react';
import {Platform, StyleSheet, Text, View, Animated, findNodeHandle} from 'react-native';
import { connect } from 'react-native-animated-props'
setInterval(() => {
  let iters = 1e8, sum = 0;
  while (iters-- > 0) sum += iters;
}, 100);

const instructions = Platform.select({
  ios: 'Press Cmd+R to reload,\n' + 'Cmd+D or shake for dev menu',
  android:
    'Double tap R on your keyboard to reload,\n' +
    'Shake or press menu button for dev menu',
});

export default class App extends Component {
  ref = React.createRef()
  ref2 = React.createRef()
  val = new Animated.Value(10)
  val2 = new Animated.Value(10)
  componentDidMount() {
    Animated.timing(
      // Animate value over time
      this.val, // The value to drive
      {
        duration: 5000,
        toValue: 200, // Animate to final value of 1
        useNativeDriver: true,
      },
    ).start(() =>  {
        Animated.timing(
          // Animate value over time
          this.val, // The value to drive
          {
            duration: 5000,
            toValue: 100, // Animate to final value of 1
            useNativeDriver: true
          }).start()
      }
    ); // Start the animation

    Animated.timing(
      // Animate value over time
      this.val2, // The value to drive
      {
        duration: 5000,
        toValue: 200, // Animate to final value of 1
        useNativeDriver: true,
      },
    ).start(() =>  {
        Animated.timing(
          // Animate value over time
          this.val2, // The value to drive
          {
            duration: 5000,
            toValue: 100, // Animate to final value of 1
            useNativeDriver: true
          }).start()
      }
    ); // Start the animation


    this.val.addListener(({ value }) => {
      this.ref.current.setNativeProps({
        style: {
          width: value
        }
      })
    })
    //console.warn(this.val.__getNativeTag())
    connect(this.ref2.current, this.val2, "width")
    connect(this.ref2.current, this.val2, "height")
    //RNAnimatedProps.connect(findNodeHandle(this.ref.current), this.val.__getNativeTag())
  }
  render() {
    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>Welcome to React Native!</Text>
        <Text style={styles.instructions}>To get started, edit App.js</Text>
        <Text style={styles.instructions}>{instructions}</Text>
        <View
          ref={this.ref}
          style={{
            width: 100,
            height: 100,
            backgroundColor: 'red'
          }}
        />
        <View
          ref={this.ref2}
          style={{
            width: 100,
            height: 100,
            backgroundColor: 'red'
          }}
        />
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
});
