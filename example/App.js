import React, {Component} from 'react';
import { Platform, StyleSheet, Text, View, Animated, findNodeHandle, TextInput } from 'react-native';
import { connect } from 'react-native-animated-props'
/*
setInterval(() => {
  let iters = 1e8, sum = 0;
  while (iters-- > 0) sum += iters;
}, 100);
*/


const instructions = Platform.select({
  ios: 'Press Cmd+R to reload,\n' + 'Cmd+D or shake for dev menu',
  android:
    'Double tap R on your keyboard to reload,\n' +
    'Shake or press menu button for dev menu',
});



//  LOGICAL SET


//const mulitply = (...args) => args.reduce((acc, v) => Animated.multiply(acc, v), 1);

//const add = (...args) => args.reduce((acc, v) => Animated.add(acc, v), 0);

const cond = (_if, _then, _else = 0) => Animated.add(Animated.multiply(_if, _then), Animated.multiply(Animated.subtract(1, _if), _else));


const greaterThan = (val, from) => val.interpolate({ inputRange: [from - 0.0001, from, from, from + 0.0001], outputRange: [0, 0, 1, 1] });
const greaterOrEq = (val, from) => val.interpolate({ inputRange: [from - 0.0001, from - 0.0001, from, from + 0.0001], outputRange: [0, 0, 1, 1] });
const lesserOrEq = (val, from) => val.interpolate({ inputRange: [from - 0.0001, from, from, from + 0.0001], outputRange: [1, 1, 0, 0] });
const lesserThan = (val, from) => val.interpolate({ inputRange: [from - 0.0001, from - 0.0001, from, from + 0.0001], outputRange: [1, 1, 0, 0] });

export default class App extends Component {
  ref = React.createRef()
  ref2 = React.createRef()
  ref3 = React.createRef()
  val = new Animated.Value(149)
  val2 = new Animated.Value(10)
  constructor(props) {
    super(props)
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
    ); // Start the animation*/

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
    this.coni = cond(lesserThan(this.val, 150), this.val, this.val);
    console.log(this.coni)


    //this.val.addListener((e) => console.log(e))



    /*    this.val.addListener(({ value }) => {
          this.ref3.current.setNativeProps({
            text: value.toString(),
            value: value,
            style: {
              width: value
            }
          })
        })*/
    //console.warn(this.val.__getNativeTag())
    //setTimeout(()=>connect(this.ref2.current, this.val2, "width"), 200);

    //connect(this.ref.current, coindVal, "width")
    //connect(this.ref3.current, this.val2, "text", "string")
    //connect(this.ref2.current, this.val2, "height")
    //RNAnimatedProps.connect(findNodeHandle(this.ref.current), this.val.__getNativeTag())
  }
  componentDidMount() {
    connect(this.ref2.current, this.coni, "width")
  }
  render() {
    return (
      <View style={styles.container}>
        <Text style={styles.welcome} children={"sdf"}/>
        <TextInput  style={{height: 40,  borderColor: 'gray', borderWidth: 1}}
                    ref={this.ref3}
                    value="123"/>
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
       <Animated.View
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
