#### 准备工作
请联系客服来修改'OBFaceConfig.h'文件中对应的配置

‘’‘
/**
 *调用人脸识别接口的地址
 */
#define OBFace_url      @"your url"

/**
 *调用接口时需要指定appid
 */
#define OBFace_appid    @"your appid"

/**
 *在指定appid下的人脸库的groupid
 */
#define OBFace_groupid  @"your group id"
’‘’


#### app 使用说明

在首页点击登录或注册按钮，会在‘ViewController.m’中调用‘startAction:’方法，弹出人脸活体检测页面‘OBFaceLivenessViewController’。
在活体检测页面中进行人脸的识别，并在‘OBFaceCameraView.m’中调用‘faceLiveness’方法进行活体检测。
活体检测通过后，会关闭人脸活体检测页面，并通过block返回检测成功之后的人脸图片。
demo中把此人脸图片传入‘OBFaceSuccessViewController’中来进行模拟登录或者注册的流程。如有特殊逻辑可自行更改补充。


##### 用户注册
在‘OBFaceSuccessViewController’中会调用‘faceIdentify:’方法在人脸库中进行人脸搜索。
如果人脸库存在此用户，会返回此用户的userId，则表示此用户已注册。如有下一步操作，请自行更改补充。
如果人脸库不存在此用户，会返回特定error code，则表示此用户未注册。demo中模拟在开发者自有服务端进行用户注册后，生成用户的userId，之后调用'addFace:userId:'方法并使用此userId在人脸库中进行人脸注册。用户注册流程至此完成。如有特殊处理可自行更改补充。

##### 用户登录

在‘OBFaceSuccessViewController’中会调用‘faceIdentify:’方法在人脸库中进行人脸搜索。
如果人脸库存在此用户，会返回此用户的userId，则表示此用户已存在。通过此userId可在开发者自有服务端查询用户信息。如有下一步操作，请自行更改补充。
如果人脸库不存在此用户，会返回特定error code，则表示没有此用户。之后操作可在此自行补充。

