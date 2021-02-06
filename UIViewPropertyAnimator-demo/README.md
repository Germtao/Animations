#  交互动画 UIViewPropertyAnimator

![UIViewPropertyAnimator的状态图]()

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

