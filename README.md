# react-native-animated-props

  
![](https://cultofthepartyparrot.com/parrots/hd/parrot.gif)

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
```javascript
connect(this.ref.current, this.val, "width")
connect(this.ref.current, this.val, "height")
```
in order to omit JS trip

![](https://cultofthepartyparrot.com/parrots/hd/fastparrot.gif)
