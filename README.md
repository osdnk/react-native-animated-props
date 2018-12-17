# react-native-animated-props

  
![](https://cultofthepartyparrot.com/parrots/hd/rightparrot.gif)

What if I tell you could replace:

```javascript
this.val.addListener(({ value }) => {
  this.ref.current.setNativeProps({
    style: {
      width: value,
      height: value
    } 
  })
})
 ```
with
 ```
connect(this.ref2.current, this.val2, "width")
connect(this.ref2.current, this.val2, "height")
```
