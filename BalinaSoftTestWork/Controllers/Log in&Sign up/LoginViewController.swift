

import UIKit



class LoginViewController: UIViewController , UITextFieldDelegate  {
  
    
   
    
  
    
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTexField: UITextField!
    @IBOutlet weak var signInLabelButton: UIButton!
    @IBOutlet weak var scrollViewOutlet: UIScrollView!
    
    var keyboardHeightLayoutConstraint: NSLayoutConstraint?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Login"
       
        txtDelegate()
        setUpButton()
        registerKeyboardNotifications()
        
    }
    @IBAction func signInActionButton(_ sender: Any) {
        checkLoginAndPasswordSize()
        checkCorrectValidationLoginSize()
        checkCorrectValidationPasswordSize()
        correctInput()
        guard let login = loginTextField.text, let pass = passwordTexField.text else {
           return
        }
        
        
        ServerManager.shared.signIn(login: login, password: pass) { (success, response, errorString) in
            if success {
                
                token = response["data"]["token"].stringValue
                username = response["data"]["login"].stringValue
                userID = response["data"]["userId"].stringValue
                
                let storyboard = UIStoryboard.init(name: "Reveal", bundle: nil)
                print(username ?? "Error")
                print(token ?? "Error")
                print(userID ?? "Error")
                if let vc = storyboard.instantiateInitialViewController() {
                    DispatchQueue.main.async {
                        self.present(vc, animated: true, completion: nil)
                    }
                }
            } else {
                let alert = UIAlertController(title: "Error!", message: "Please check your data", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        
      
        correctInput()
    }
  
    //MARK: Settings of button
    func setUpButton(){
        signInLabelButton.layer.cornerRadius = 5
    }
    
    //MARK: Touches and return
    func txtDelegate(){
        self.loginTextField.delegate = self
        self.passwordTexField.delegate = self
    }
    
   
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.loginTextField.resignFirstResponder()
        self.passwordTexField.resignFirstResponder()
        view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.loginTextField?.resignFirstResponder()
        self.passwordTexField?.resignFirstResponder()
        return true
    }
    
    //MARK:Notification keyboard
    
    func registerKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notifictation:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func deregisterKeyboardNotificatios(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    deinit {
        deregisterKeyboardNotificatios()
    }
    
    @objc  func keyboardWillShow(notifictation: NSNotification){
        let userInfo = notifictation.userInfo
        let keyboardSize = (userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        scrollViewOutlet.contentOffset = CGPoint(x:0,y:keyboardSize.height-80)
        
    }
    
    @objc func keyboardWillHide(){
        scrollViewOutlet.contentOffset = CGPoint.zero
    }
    

    //MARK:Check input. Login and password lenght
   private func correctInput(){
    
         if (loginTextField.text?.isEmpty)! && (passwordTexField.text?.isEmpty)! {
         let alert = UIAlertController(title: "Warning! Fields are empty!", message: "Please fill in all fields.", preferredStyle: .alert)
         let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        
         alert.addAction(action)
         self.present(alert, animated: true, completion: nil)

         }else if (loginTextField.text?.isEmpty)!{
         let alert = UIAlertController(title: "Warning! Login field is empty!", message: "Please fill in login field.", preferredStyle: .alert)
         let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        
         alert.addAction(action)
         self.present(alert, animated: true, completion: nil)

         }else if (passwordTexField.text?.isEmpty)!{
         let alert = UIAlertController(title: "Warning! Password field is empty!", message: "Please fill in  password field.", preferredStyle: .alert)
         let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        
         alert.addAction(action)
         self.present(alert, animated: true, completion: nil)
         }
    
    }
    private func checkCorrectValidationLoginSize(){
        
        if (loginTextField.text?.count)! < 4 {
            let alertLoginSise = UIAlertController(title: "Error", message: "Field login: size must be between 4 and 32 symbols.", preferredStyle: .alert)
            let actionLogin = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertLoginSise.addAction(actionLogin)
            DispatchQueue.main.async {
                self.present(alertLoginSise, animated: true, completion: nil)
            }
            
        }
        
    }
    private func checkCorrectValidationPasswordSize(){
        
        if (passwordTexField.text?.count)! < 8 {
            let alertPasswordSize = UIAlertController(title: "Error", message: "Password field: size must be between 8 and 500 symbols.", preferredStyle: .alert)
            let actionPassword = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertPasswordSize.addAction(actionPassword)
            DispatchQueue.main.async {
                self.present(alertPasswordSize, animated: true, completion: nil)
            }
        }
        

    }
    
    private func checkLoginAndPasswordSize(){
        if (loginTextField.text?.count)! < 4 && (passwordTexField.text?.count)! < 8 {
            let alertPasswordSize = UIAlertController(title: "Error", message: "Login field size must be between 4 and 32 symbols, for password field size must be between 8 and 500 symbols.", preferredStyle: .actionSheet)
            let actionPassword = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertPasswordSize.addAction(actionPassword)
            DispatchQueue.main.async {
                self.present(alertPasswordSize, animated: true, completion: nil)
            }
        }
    }
    
    
}

