

import UIKit

class RegisterViewController: UIViewController ,UITextFieldDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var signUpLabelButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtDelegate()
        setUpButton()
        registerKeyboardNotifications()
    }
    
    
    //MARK: Settings of button
    func setUpButton(){
        signUpLabelButton.layer.cornerRadius = 5
        
    }
    
    //MARK: Touches and return
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.loginTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        self.confirmPasswordTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.loginTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        self.confirmPasswordTextField.resignFirstResponder()
        return true
    }
    func txtDelegate (){
        self.loginTextField.delegate = self
        self.passwordTextField.delegate = self
        self.confirmPasswordTextField.delegate = self
    }
    
    
    //MARK:Check fields
    @IBAction func signUpActionButton(_ sender: Any) {
        checkCorrectInput()
        checkPasswordMatch()
        signUpNewUser()
        checkCorrectValidationLoginSize()
        checkCorrectValidationPasswordSize()
        checkCorrectValidationConfirmPasswordSize()
        checkLoginAndPasswordSize()
    }
    
    func signUpNewUser() {
        ServerManager.shared.signUp(login: loginTextField.text!, password: passwordTextField.text!) { (success, response, error) in
            if success {
                let alert = UIAlertController(title: "Register success", message: "Welcome", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                    
                    token = response["data"]["token"].stringValue
                    username = response["data"]["login"].stringValue
                    userID = response["data"]["userId"].stringValue
                    
                    let storyboard = UIStoryboard.init(name: "Reveal", bundle: nil)
                    if let vc = storyboard.instantiateInitialViewController() {
                        DispatchQueue.main.async {
                            self.present(vc, animated: true, completion: nil)
                        }
                    }
                }))
                
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
                
            } else {
                print(error)
            }
        }
    }
    //MARK:Notification keyboard
    
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notifictation:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func deregisterKeyboardNotificatios() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    deinit {
        deregisterKeyboardNotificatios()
    }
    
    @objc  func keyboardWillShow(notifictation: NSNotification) {
        let userInfo = notifictation.userInfo
        let keyboardSize = (userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        scrollView.contentOffset = CGPoint(x:0,y:keyboardSize.height-80)
        
    }
    @objc func keyboardWillHide(){
        scrollView.contentOffset = CGPoint.zero
    }
    //MARK: - Check password match
    private func checkPasswordMatch() {
        if (passwordTextField.text != confirmPasswordTextField.text){
            let alert = UIAlertController(title: "Warning! Passwords are not match", message: "Please check and try again", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    //MARK: - Correct input
    private func checkCorrectInput() {
        if (loginTextField.text?.isEmpty)! && (passwordTextField.text?.isEmpty)! && (confirmPasswordTextField.text?.isEmpty)! {
            let alert = UIAlertController(title: "Warning! Fields are empty!", message: "Please fill in all fields.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
            
            
        }else if (loginTextField.text?.isEmpty)!{
            let alert = UIAlertController(title: "Warning! Login field is empty!", message: "Please fill in login field ", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
            
        }else if (passwordTextField.text?.isEmpty)!{
            let alert = UIAlertController(title: "Warning! Password field is empty!", message: "Please fill in  password field ", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
        else if (confirmPasswordTextField.text?.isEmpty)!{
            let alert = UIAlertController(title: "Warning! Confirm field is empty!", message: "Please confirm password", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    //MARK: - Check login and password size
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
        
        if (passwordTextField.text?.count)! < 8 {
            let alertPasswordSize = UIAlertController(title: "Error", message: "Password field: size must be between 8 and 500 symbols.", preferredStyle: .alert)
            let actionPassword = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertPasswordSize.addAction(actionPassword)
            DispatchQueue.main.async {
                self.present(alertPasswordSize, animated: true, completion: nil)
            }
        }
        
        
    }
    private func checkCorrectValidationConfirmPasswordSize(){
        
        if (confirmPasswordTextField.text?.count)! < 8 {
            let alertPasswordSize = UIAlertController(title: "Error", message: "Confirm password field: size must be between 8 and 500 symbols.", preferredStyle: .alert)
            let actionPassword = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertPasswordSize.addAction(actionPassword)
            DispatchQueue.main.async {
                self.present(alertPasswordSize, animated: true, completion: nil)
            }
        }
        
        
    }
    
    private func checkLoginAndPasswordSize(){
        if (loginTextField.text?.count)! < 4 && (passwordTextField.text?.count)! < 8 &&  (confirmPasswordTextField.text?.count)! < 8 {
            let alertPasswordSize = UIAlertController(title: "Error", message: "Login field size must be between 4 and 32 symbols, for password and confirm password field size must be between 8 and 500 symbols.", preferredStyle: .actionSheet)
            let actionPassword = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertPasswordSize.addAction(actionPassword)
            DispatchQueue.main.async {
                self.present(alertPasswordSize, animated: true, completion: nil)
            }
        }
    }
}
