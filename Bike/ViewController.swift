

import UIKit
import SWRevealViewController

class ViewController: UIViewController,MAMapViewDelegate,AMapSearchDelegate {
    
    var mapView: MAMapView!              //声明全局地图 有值的！
    var search: AMapSearchAPI!           //祝搜索API
    var pin: MyPinAnnotation!            //当前屏幕中心点坐标 全局
    var pinView: MAAnnotationView!       //保存大头针视图
    var nearBySearch = true              //用户周围的搜索 变量  一开始就在周围搜索

    @IBOutlet weak var PanelView: UIView!
    @IBAction func locationBtnTab(_ sender: UIButton) {
        searchBikeNearby()   //用户当前坐标       按钮出发该事件
    }
    
    //搜索周边的小黄车
    func searchBikeNearby()  {
        searchCustomLocation(mapView.userLocation.coordinate)      //
    }
    
    func searchCustomLocation(_ center: CLLocationCoordinate2D)  {   //周边查询的我请求     _ 与center应该分开的
        let request = AMapPOIAroundSearchRequest()
        request.location = AMapGeoPoint.location(withLatitude: CGFloat(center.latitude), longitude: CGFloat(center.longitude))
        request.keywords = "餐馆"   //搜索的关键词
        request.radius = 500   //500米范围之内
        request.requireExtension =  true //返回扩展信息
        
        search.aMapPOIAroundSearch(request)   //搜索周边的
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //初始化一个高德地图
        mapView = MAMapView(frame:view.bounds)
        view.addSubview(mapView)
        view.bringSubview(toFront: PanelView)    //把面板带到钱面，防止被覆盖
        mapView.delegate = self    //实现代理？ 必须使控制器遵循这个代理
        
        mapView.zoomLevel = 17        //初始定位点的缩放大小级别 3 到19   先缩放在定位
        mapView.showsUserLocation = true       //展示定位蓝点.然后去info.plist中进行配置，询问用户是否。。。
        mapView.userTrackingMode = .follow    //定位追踪
        
        search = AMapSearchAPI()     //初始化
        search.delegate = self       //实现搜索代理
        
        
        //为何失败了呢？中间logo图标self.navigationItem.titleView = UIImageView(image:yellowBikeLogo)
        self.title = "Share"
        
        self.navigationItem.leftBarButtonItem?.image =  #imageLiteral(resourceName: "user").withRenderingMode(.alwaysOriginal)
        self.navigationItem.rightBarButtonItem?.image = #imageLiteral(resourceName: "search_icon").withRenderingMode(.alwaysOriginal)
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"",style:.plain,target:nil,action:nil)
        
        if let revealVC = revealViewController() {
            revealVC.rearViewRevealWidth = 280
            navigationItem.leftBarButtonItem?.target = revealVC
            navigationItem.leftBarButtonItem?.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(revealVC.panGestureRecognizer())
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //MARK: - 大头针动画     //20
    func pinAnimation() {
        //最落效果，y轴加位移
        let endFrame = pinView.frame
        
        pinView.frame = endFrame.offsetBy(dx: 0, dy: -15)     //左右与上下的值变化
        //  ????
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping:0.2, initialSpringVelocity:0, options:[], animations: {
            self.pinView.frame = endFrame
        }, completion: nil)
        
    }
    
    
    //MARK: - MapView Delegate         //判断大头针

    
    
    /// 用户移动地图后的交互
    ///
    /// - Parameters:
    ///   - mapView: mapview
    ///   - wasUserAction: 用户是否移动
    func mapView(_ mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool) {
        if wasUserAction {
            
            pin.isLockedToScreen = true         //锁定不移动
            
            pinAnimation()                      //
            searchCustomLocation(mapView.centerCoordinate)      //搜索周边的
        }
    }
    
    
    /// 地图初始化完成后，添加中心坐标点，固定不动
    ///
    /// - Parameter mapView: <#mapView description#>
    func mapInitComplete(_ mapView: MAMapView!) {
        pin = MyPinAnnotation()                       //初始化一个点坐标对象
        pin.coordinate = mapView.centerCoordinate     //定位在中心坐标
        pin.lockedScreenPoint = CGPoint(x:view.bounds.width/2,y:view.bounds.height/2)    //屏幕中心坐标
        pin.isLockedToScreen = true
        
        mapView.addAnnotation(pin)        //只有一个点
        mapView.showAnnotations([pin], animated: true)   //使其显示在屏幕上
        
    }
    
    
    /// 自定义大头针
    ///
    /// - Parameters:
    ///   - mapView: mapView
    ///   - annotation: 标注
    /// - Returns: 大头针视图
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {       //定义大头针
        //用户定义的位置，不需要自定义
        if  annotation is MAUserLocation {
             return nil
        }
        
        //屏幕中心的点 ，不需判断   特殊点
        if annotation is MyPinAnnotation {
            let reuseid = "anchor"        //图表名称
            var av = mapView.dequeueReusableAnnotationView(withIdentifier: reuseid)
            if av == nil {
                av = MAPinAnnotationView(annotation:annotation,reuseIdentifier:reuseid) //初始化一个
            }
            
            av?.image = #imageLiteral(resourceName: "start_annotation")        //更换图片图标
            av?.canShowCallout = false            //没有弹出的气泡
            
            pinView = av                          //屏幕移动时进行操作
            return av
        }
        
        //排除用户ID外的要定义
        let reuseid = "myid"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseid) as? MAPinAnnotationView  //若重用不成功，即第一次新建时
        
        if annotationView == nil {
            annotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: reuseid)    //重用
        }
        
        if annotation.title == "正常可用" {
            annotationView?.image = #imageLiteral(resourceName: "HomePage_nearbyBike")
        }else{
            annotationView?.image = #imageLiteral(resourceName: "HomePage_nearbyBikeRedPacket")
        }
        
        annotationView!.canShowCallout = true     //显示气泡
        annotationView!.animatesDrop = true       //水滴效果
        
        return annotationView
    }
    
    
    //MARK: - Map Search Delegate         //mark方便查看方法列表
    //搜索周边完成后的处理
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        guard response.count > 0 else {       //保证作用，相当于if判断语句
            print("周边没有小黄车")
            return
        }
        var annotations : [MAPointAnnotation] = []      //声明一个数组
        
        annotations = response.pois.map{
            let annotation = MAPointAnnotation()
            
            annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees($0.location.latitude),longitude: CLLocationDegrees($0.location.longitude))    //坐标。类型是cllocationcoordinate2d
            
            if $0.distance < 400 {           //对不同距离的车使用不同的显示，不同的奖励机制 ，激活附近的车   //也是一个限制或者区分
                annotation.title = "红包区域内开锁任意小黄车"
                annotation.subtitle = "骑行10分钟可以获得现金红包"
                
            } else{
                annotation.title = "正常可用"
            }
            return annotation
        }
        
        //21 附近搜索与用户移动的区别
        mapView.addAnnotations(annotations)                        //加载到地图视图上
        
        if nearBySearch {                                          //如果用户在附近搜索
            mapView.showAnnotations(annotations,animated:true)     //自动一次性缩放到一个图中可以看到更大试图里面的所有标注点
            nearBySearch = !nearBySearch                           //转换取反
        }
        
        
        
        //for poi in response.pois{
        //    print(poi.name)
        //}
        
    }
    


}

