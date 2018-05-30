

import UIKit

class PageVCForRegisterAndLogin: UIPageViewController {

    var currentPage = UIPageControl()
    
    lazy var subViewsControllers:[UIViewController] = {
       return[
        UIStoryboard(name:"LoginAndRegisterStoryboard",bundle:nil).instantiateViewController(withIdentifier: "LoginViewController") as!
        LoginViewController,
        UIStoryboard(name:"LoginAndRegisterStoryboard",bundle:nil).instantiateViewController(withIdentifier: "RegisterViewController") as!
        RegisterViewController
        ]
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
        setViewControllers([subViewsControllers[0]], direction: .forward, animated: true, completion: nil)
        configurepageControl()
        hideKeyboardWhenTappedAround()
   }
  

}
//MARK: -  UIPageViewControllerDataSource&Delegate
extension PageVCForRegisterAndLogin: UIPageViewControllerDataSource,UIPageViewControllerDelegate{
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentIndex:Int = subViewsControllers.index(of: viewController) ?? 0
        if (currentIndex <= 0) {
            return nil
        }
        return subViewsControllers[currentIndex - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let currentIndex:Int = subViewsControllers.index(of: viewController) ?? 0
        if (currentIndex >= subViewsControllers.count - 1) {
            return nil
        }
        return subViewsControllers[currentIndex + 1]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return subViewsControllers.count
    }
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageCurrentVC = pageViewController.viewControllers![0]
        self.currentPage.currentPage = subViewsControllers.index(of:pageCurrentVC)!
    }
    
    //MARK: Configure page control
    func configurepageControl(){
        currentPage = UIPageControl(frame: CGRect(x: 0, y: UIScreen.main.bounds.maxY - 50, width: UIScreen.main.bounds.width, height: 50))
        self.currentPage.numberOfPages = subViewsControllers.count
        self.currentPage.currentPage = 0
        self.currentPage.tintColor = UIColor.black
        self.currentPage.pageIndicatorTintColor = UIColor.gray
        self.currentPage.currentPageIndicatorTintColor = UIColor.green
        self.view.addSubview(currentPage)
    }
}
