#### 准备工作
请联系客服来修改为对应的服务器地址
```
 <meta-data android:value="$HOST" android:name="server_host"/>
```

#### app 使用说明

##### 用户注册
在 `HomeActivity` 中调用 `registerUser` 方法，并且传入需要绑定人脸的用户id， 就会自动打开人脸识别页面进行人脸的识别和注册，成功后会与传入的 `userId` 绑定，以供以后的登录接口使用。
在完成注册流程后会调用该类下的 `onRegistrationSuccess` 方法，如有下一步的操作可以在这里进行补充

##### 用户登录
在 `HomeActivity` 中调用 `loginUser` 方法，就会开启面部识别的界面，在用户成功完成面部识别并且找到对应的 `userId` 后会
在完成注册流程后会调用该类下的 `onRegistrationSuccess` 方法，如有下一步的操作可以在这里进行补充该方法内