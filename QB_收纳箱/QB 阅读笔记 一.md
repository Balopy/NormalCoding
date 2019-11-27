#QB App 代码阅读笔记
##一、viewDidLoad（）方法
项目中使用了全局的`viewDidLoad()`方法调用，目的是为了使用Socket监听及其他配置。

下面以`MyAssetsController `类为例

###1. MyAssetsController 类

```
import UIKit

class MyAssetsController: BaseViewController,IBaseView {
    
    private var _myAssetsValuationView: MyAssetsValuationView =  MyAssetsValuationView()
    
    private var _tableView: UITableView = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - TAB_BAR_HEIGHT-NAVIGATION_BAR_HHEIGHT), style: UITableViewStyle.plain)
    
    private lazy var vm = MyAssetsVM(view: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vm.viewDidLoad()

        UserDefaults.standard[PreferenceNames.hiddenAssets] = HiddenAssetsAmountType.show.rawValue
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        vm.viewWillAppear()
    }
    
    func reloadData() {
        _tableView.reloadData()
    }
}
```
以上代码，引入了`MyAssetsVM`类，起到 `ViewModel` 作用，把相关的方法调用放到此类，但是写法不对，只放了一此方法的声明及调用，具体实现还是在 `MyAssetsController`控制器中，写法错误，维护困难，理解费劲，另外数据处理放在`MyAssetsVM-->Extension`中是可以的，但相对合适的位置，应该在本类，方法较多时，可以按业务、功能进行拆分。

* 建议：
	1. 此处`viewModel`完全可以使用`MyAssetsController + extension`把相关数据处理放到扩展类里
	2. `viewModel` 的使用，是处理`View`与`Model`的业务关系及相关逻辑，使用时，只需要把`view`相关的数据处理放在此类即可，切勿将`Controller`杂揉到这里，极易造成循环引用。
	3. `vm.viewDidLoad()` 作用是`socket`监听及View视图创建，不需要单独引入一个中间类（`viewModel`），可把此处相关代码删除，直接放到`MyAssetsController`类中的`viewDidLoad()`方法中。

###2. MyAssetsVM -->  viewModel

```
// 资产
class MyAssetsVM : IBaseVM,ITableViewRelated, ReconnectReloadData {
    
    ///网络状态监听
    var reachability = Reachability()!
    
    var view: MyAssetsController
    var myAssetsModel: MyAssetsModel?
    private var _assetsRequest: MyAssetsRequest = MyAssetsRequest.shared
    var coins = [CurrencyModel]()
    
    /// 初始化方法
    ///
    /// - Parameter view: MyAssetsController 控制器
    ///
    /// 把 view 声明为控制器，这简直神操作
    init(view: MyAssetsController) {
        self.view = view
    }
    
    func setRequest(request: MyAssetsRequest) {
        _assetsRequest = request
    }
    
    func viewDidLoad() {
        view.setupView()
        observeSocketReconnect()
    }
    
    func viewWillAppear() {
        loadData()
        monitorNetwork()
    }
    
    deinit {
        // 关闭网络状态消息监听
        reachability.stopNotifier()
        // 移除网络状态消息通知
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.reachabilityChanged, object: reachability)
        BLLog("移除网络监听")
    }

    //MARK:顶部眼睛点击事件
    func handlEeyeClick(_ isHidden:Bool) {
        view.reloadData()
        showAssets()
    }
}
```
在这个`viewModel`中声明了` var view: MyAssetsController `，并使用 `init `初始化 View 对象，把`MyAssetsController ` 直接拿来用，定义成view，极易误导程序员认为是一个UIView对象，经*Leak*工具检测，这种写法造成其他地方多处循环引用问题。

```
  var view: MyAssetsController

  init(view: MyAssetsController) {
        self.view = view
    }
  这里着重分析一下：
  1. 此处；var view: MyAssetsController 声明默认是 strong强引用，并且是属性，全局的，当 MyAssetsVM 释放时，才会跟着释放；
  2. MyAssetsController 类中，同关声明了 private lazy var vm = MyAssetsVM(view: self)，默认是 strong强引用，并且是属性，全局的，当 MyAssetsController 释放时，才会跟着释放；
  3. 这里造成了循环引用，两个对象都在等对方释放，但都释放不了，内存泄漏是必然的。
    
```

* `viewModel` 代码说明：
	1. 定义了`viewDidLoad()`方法，用于创建View(视图)，及添加Socket监听。
	2. 定义`viewWillAppear()`用于加载数据，及网络监听。
	3. 定义`Target`事件

`viewModel`做了一些本份的数据处理操作，但是各种业务杂揉到一起，显得面目全非。

###3. 注意 View 视图的处理
	
`viewModel`中处理了`TableView`相关的数据
	
```
//MARK: - 修改我的资产页面数据源
extension MyAssetsVM {
    
    /// 此处这种写法，怎么想的？？ 尽管看不太懂
    func dataElement(of indexPath: IndexPath) -> CurrencyModel? {
        if coins.count > 0 {
            return coins[indexPath.row]
        }
        return nil
    }
    /// 为什么要这么写，有何意义？？
    var numberOfSections: Int {
        return 1
    }
    
    func numberOfRows(in section: Int) -> Int {
        return coins.count
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        let model = coins[indexPath.row]
        view.jumpToDetailVC(model)
    }
    
    func heightForRow(at indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func getFooterHidden() -> Bool {
        if coins.count > 0 {
            return true
        }
        return !DefaultsValueTool.getAssetsLimitIsHidden()
    }
}

```

而`MyAssetsController `中实现`TableView`相关的代理。

```
// MARK: - TableView数据源
extension MyAssetsController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return vm.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.numberOfRows(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = AssetNewCell.cellWithTableView(tableView)
        
        //更新数据
        let model = vm.dataElement(of: indexPath)!
        var totalAccountStr = ""
        if DefaultsValueTool.getAssetsAmountIsHidden() {
            totalAccountStr = KeyString.s.cipher
        } else {
            totalAccountStr = model.totalCountFormat
        }
        cell.updateCell(model.cn, model.fullname, totalAccountStr)
        return cell
    }
}

// MARK: - TableViewDelegate
extension MyAssetsController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let dealAssetsView = DealAssetsView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 100))
        dealAssetsView.dealCallback.delegate(on: self) { (self, currencyType) in
            self.vm.handleDealCurrencyType(currencyType: currencyType)
        }
        return dealAssetsView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        vm.didSelectRow(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return vm.heightForRow(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if vm.getFooterHidden() {
            return 0
        }
        //SCREEN_HEIGHT - TAB_BAR_HEIGHT - NAVIGATION_BAR_HHEIGHT - 132 - 210 - 90
        return 100
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footView = UIView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 100))
        let image = UIImageView(image: Asset.MyAssets.iconZcYc.image)
        image.frame = CGRect(x: SCREEN_WIDTH / 2 - 25, y: 30, width: 50, height: 38)
        footView.addSubview(image)
        
        let label = UILabel.init(frame: CGRect(0, image.maxY + 10, SCREEN_WIDTH, 23))
        label.text = KeyString.s.hiddenSmallAssets
        label.textColor = UIColor.Common.gray828
        label.font = UIFont.fitMediumFont(size: 14.0)
        label.textAlignment = .center
        footView.addSubview(label)
        return footView
    }
}

```
从代码来看，`ViewModel`中的处理，没有什么特别之处，完全可以删除相关的代码，只是不知道为何这么写。

* 建议
	1. `TableView` 这部分代码，完全可以抽离到相应的`view`中，如自定义一个`TableView`用于列表展示；
	2. `viewModel`中处理列表数据，把结果返回；
	3. `viewModel`中不要写与`view`创建相关的代码，（前期可以放到Controller中，以便后期拆分、封装）；
	4. `viewModel`中不应该声明函数、方法，哪里用在哪里定义及调用。


###4. 对于 MyAssetsController 和 MyAssetsDetailViewController 
已经解决这两个控制器出现循环引用问题，并把代码按照 `MVVM`或`MVC` 简单重构，具体可查看这两个控制器。


##二、代码规范
代码规范，好处不用多说，对于多人开发，通俗易懂的代码，能极大提高开发效率，减少沟通成本。
针对**QB交易所**项目的代码，可参考以下代码规范[点击查看](https://blog.csdn.net/liushuo19920327/article/details/79121384)、
	[官方代码规范](https://www.bookstack.cn/read/apple-developer-documentation-chinese/develop-guides-cocoa-coding-guidelines-code-naming-basics.md).


* 要点：
	1. 项目中文件的结构，按照`MVC`	或 `MVVM`的规则分类，以下是`MVC`的范例。
	![文件结构](https://upload-images.jianshu.io/upload_images/4873556-e024d5ca3eb66676.png?imageMogr2/auto-orient/strip|imageView2/2/w/361) 
	2. 声明 `类`要求:见名知义，`类`名使用首字母大写的驼峰标识命, 自定义名在前, 类名在后，特别建议，在类名前加前缀，比如程序员名字简拼`WCL`或`BL`.
	
		```
	import BLVideoDetailViewController.swift
	import BLHomeBannerModel.swift
	import BLMessageDetailWebView.swift
	.
	class BLMessageDetailWebView: class {
   		 	let myImageView: UIImageView
    		let myName: String
	}

		```
	3. *方法名* 首字母小写的驼峰标识命名, 注意空格的使用，参数过多时，可换行保持对齐。**注意添加注释**
	
		```
/// - Parameters:
///   - tableView: <#tableView description#>
///   - section: <#section description#>
/// - Returns: <#return value description#>
func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       		 return 100
    }
    
		```
	4.  *变量名*  变量名以小写字母开头，禁止出现：aa，bb…，arrayIndex —->  arrayInde (两者识别度小的也不要这样写)，这样的变量。仍然要见其名知其义，如：int courseId //课程id
	5. *协议* 协议名通常 类名+Delegate

		```
		protocol BLITopExpandViewDelegate where Self: UIView { }
		```
		或者
		
		```
		protocol BLITopExpandViewDelegate { }
		```
		第一种写法，加了类型限定，表示只有UIView及子类才可以使用该协议。
		第二种写法，所有类均可实现该协议

以上建议，后续有时间会持续补充，希望我们一起把 QB 改造成：改高效、删省力、加便捷的友好型项目 .^_^.

