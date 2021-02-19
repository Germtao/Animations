#  交互动画 UIViewPropertyAnimator

![UIViewPropertyAnimator的状态图](https://github.com/Germtao/Animations/blob/master/UIViewPropertyAnimator-demo/State%20diagram%20for%20UIViewPropertyAnimator.png)

一个`Animator`可以处于三种可能的状态：

- `inactive`： 不活动
- `active`：活动
- `stopped`：停止

动画器初始化为非活动状态，但在启动或暂停时会移动到活动状态。动画完成后，它将返回到非活动状态。如果动画已开始且已暂停，则动画将保持活动状态，并且不会进行状态转换。

让我们看看如何结合使用`UIPanGestureRecognizer`和`UIViewPropertyAnimator`来创建上面的动画。

```
class ViewController: UIViewController {
    
    @IBOutlet weak var showView: UIView! {
        didSet {
            let pan = UIPanGestureRecognizer(target: self, action: #selector(handle(_:)))
            showView.addGestureRecognizer(pan)
        }
    }
    
    var animator = UIViewPropertyAnimator()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @objc private func handle(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            animator = UIViewPropertyAnimator(duration: 3, curve: .easeOut, animations: {
                self.showView.transform = CGAffineTransform(translationX: 200, y: 0)
                self.showView.alpha = 0.0
            })
            animator.startAnimation()
            animator.pauseAnimation()
        case .changed:
            // 将视图与用户的触摸一起移动
            animator.fractionComplete = gesture.translation(in: showView).x / 200
        case .ended:
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        default:
            break
        }
    }
}
```

注意，在`startAnimation()`之后立即调用`pauseAnimation()`。

因为我们的动画是从平移手势开始的，所以用户最有可能先松开动画，然后再释放其点击。动画暂停后，设置`fractionComplete`属性可将视图与用户的触摸一起移动。

如果我们尝试使用标准的`UIView`动画来执行此操作，则将需要比上例中列出的逻辑更多的逻辑。`UIView`动画无法提供直接控制动画完成百分比的简便方法，也无法让我们轻松地暂停并继续动画直到完成。


# 让我们建立一个弹出菜单！

我们将分十步构建一个完全交互式，可中断，可擦除和可逆的弹出菜单。


### 1、点击打开和关闭。

首先，让我们的弹出视图在打开状态和关闭状态之间进行动画处理。这里没有花哨的技巧，只是我们先前学习的`UIViewPropertyAnimator`的基础。

`PropertyAnimatorState.swift`：

```
enum PropertyAnimatorState {
    case closed
    case open
}

extension PropertyAnimatorState {
    var opposite: PropertyAnimatorState {
        switch self {
        case .closed: return .open
        case .open:   return .closed
        }
    }
}
```

`ViewController.swift`：

```
private lazy var popupView: UIView = {
    let view = UIView()
    view.backgroundColor = .blue
    return view
}()

private lazy var tapGesture = UITapGestureRecognizer(target: self, action: #selector(popupViewTapped(_:)))

private var bottomConstraint = NSLayoutConstraint()

private var currentState: PropertyAnimatorState = .closed

override func viewDidLoad() {
    super.viewDidLoad()
    
    layout()
    popupView.addGestureRecognizer(tapGesture)
}

private func layout() {
    popupView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(popupView)
    
    popupView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    popupView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    popupView.heightAnchor.constraint(equalToConstant: 500).isActive = true
    bottomConstraint = popupView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 440)
    bottomConstraint.isActive = true
}

@objc private func popupViewTapped(_ gesture: UITapGestureRecognizer) {
    let state = currentState.opposite
    let transitionAnimator = UIViewPropertyAnimator(duration: 1, dampingRatio: 1) {
        switch state {
        case .open:
            self.bottomConstraint.constant = 0
        case .closed:
            self.bottomConstraint.constant = 440
        }
        self.view.layoutIfNeeded()
    }
    transitionAnimator.addCompletion { position in
        switch position {
        case .start:
            self.currentState = state.opposite
        case .end:
            self.currentState = state
        default:
            break
        }
        
        switch self.currentState {
        case .open:
            self.bottomConstraint.constant = 0
        case .closed:
            self.bottomConstraint.constant = 440
        }
    }
    transitionAnimator.startAnimation()
}
```

相关的动画代码在`popupViewTapped`函数中，单击该视图时将调用该动画。我们只需创建一个动画器，设置其动画以修改约束的值，然后启动动画器。

我们引入一个`State`枚举来指示弹出窗口是打开的还是关闭的。它还具有计算的相反属性，该属性返回与当前状态相反的状态。我们本来可以用布尔标志来实现，但这更容易推论，尤其是当我们的动画代码变得更加复杂时。

需要指出的一件事-当动画完成时，我们正在手动更新约束的值。这应该由动画器自动处理，但是显式设置它们可以修复一些边缘错误。

### 2、添加 UIPanGestureRecognizer

为了使动画具有交互性，我们将引入第二个手势识别器，即`UIPanGestureRecognizer`。这将允许用户通过在弹出视图上滑动来开始和中断动画。这将允许用户通过在弹出视图上滑动来开始和中断动画。

```
@objc private func popupViewPanned(_ gesture: UIPanGestureRecognizer) {
    switch gesture.state {
    case .began:
        // 开始动画
        animateTransitionIfNeeded(to: currentState.opposite, duration: 1.5)
        
        // 暂停所有动画，因为下一个事件可能是平移
        runningAnimator.pauseAnimation()
        
    case .changed:
        // 变量设置
        let transition = gesture.translation(in: popupView)
        var fraction = -transition.y / popupOffset
        
        // 调整当前状态和反转状态的分数
        if currentState == .open { fraction *= -1 }
        animator.fractionComplete = fraction
        
    case .ended:
        runningAnimator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        
    default:
        break
    }
}
```

该代码与前面的示例非常相似，不同之处在于可以中断动画。我们已经将动画代码重构为一个名为`animateTransitionIfNeeded`的函数，该函数运行先前在`popupViewTapped`函数内部的所有代码。

### 3、记录动画进度以修复中断偏移

> 一个问题：当动画被中断时，它会偏离用户的触摸。

这是由于平移处理程序未考虑动画的当前进度。要解决此问题，我们需要记录动画器的`fractionComplete`，并在计算平移偏移时将其用作基线。

我们将需要一个属性来存储动画的当前进度：

```
private var animationProgress: CGFloat = 0
```

当平移手势处于开始状态时，我们记录动画的当前进度：

```
animationProgress = runningAnimator.fractionComplete
```

在平移手势的`.changed`状态下，我们将动画进度添加到计算出的`fraction`中：

```
runningAnimator.fractionComplete = fraction + animationProgress
```

现在，平移手势可以按预期工作，并且可以更自然地跟踪用户的手指。

### 4、引入自定义即时平移手势

中断行为有效，但很尴尬。为了识别平移手势，用户必须在屏幕上点击，然后向任何方向移动手指。我们希望这种行为像滚动视图一样，它允许用户仅需按下即可“捕获”视图。当前，仅在触摸和移动触摸时才触发轻击手势和平移手势。为了触发触地事件，我们可以创建自己的自定义手势识别器。

```
class InstantPanGestureRecognizer: UIPanGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if self.state == .began { return }
        super.touchesBegan(touches, with: event)
        self.state = .began
    }
}
```

该平移手势子类在触地时进入开始状态。它允许我们替换以前的两个手势识别器。现在，**点击**是一个**即时平移**，在开始后立即结束。通过使用此自定义手势识别器，我们可以改善以前的**点击/平移**解决方案的行为，并简化逻辑。

注意：为了对`UIGestureRecognizer`进行子类化，您需要在文件顶部包括此导入：

```
import UIKit.UIGestureRecognizerSubclass
```

### 5、使用平移速度反转动画

> 剩下的一个问题是：弹出窗口不考虑以哪种方式“抛出”视图。

如果我们点击关闭的弹出窗口，在动画中期捕获它，然后向下滑动，它将继续对打开的动画进行动画处理。为了解决这个问题，我们可以有条件地反转动画器。这将基于以下几个因素：

- 弹出窗口的当前状态
- 动画器当前是否反转
- 平移手势的速度

现在，平移手势处理程序的`.ended`情况如下所示：

```
let yVelocity = gesture.velocity(in: popupView).y
let shouldClose = yVelocity > 0

// 如果没有动作，请继续所有动画并尽早退出
if yVelocity == 0 {
    runningAnimator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
    break
}

// 根据动画的当前状态和平移动画来反转动画
switch currentState {
case .open:
    if !shouldClose && !runningAnimator.isReversed {
        runningAnimator.isReversed = !runningAnimator.isReversed
    }
    if shouldClose && runningAnimator.isReversed {
        runningAnimator.isReversed = !runningAnimator.isReversed
    }
case .closed:
    if shouldClose && !runningAnimator.isReversed {
        runningAnimator.isReversed = !runningAnimator.isReversed
    }
    if !shouldClose && runningAnimator.isReversed {
        runningAnimator.isReversed = !runningAnimator.isReversed
    }
}

// 继续所有动画并尽早退出
runningAnimator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
```

这种逻辑乍一看似乎很复杂，但是可以通过考虑所有可能的情况来得出。在平移手势处理程序`.changed`的情况下，我们需要尊重动画设计器的`isReversed`属性：

```
let transition = gesture.translation(in: popupView)
var fraction = -transition.y / popupOffset

// 调整当前状态和反转状态的 fraction
if currentState == .open { fraction *= -1 }
if runningAnimator.isReversed { fraction *= -1 }
runningAnimator.fractionComplete = fraction + animationProgress
```

现在我们的动画可以反转了！如果用户想关闭弹出式动画，可以轻松直观地进行操作。

### 6、设置拐角半径的动画

在`iOS 11`中，可以设置`CALayer`的角半径，而无需`CABasicAnimation`。这意味着我们可以在动画块中更新视图的拐角半径，这样就可以了！

```
self.popupView.layer.cornerRadius = 20
```

我们还可以指定圆角。在这种情况下，我们只希望对左上角和右上角进行圆角处理。

```
view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
```

现在，顶部的两个角与我们的原始动画一起被动画化。

### 7、让它更漂亮！

我们的蓝色弹出视图效果很好，但可以进行一些视觉上的改进。让我们添加背景图片、叠加视图、标题标签、细微阴影和一些示例评论。
