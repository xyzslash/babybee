//
//  ViewController./Users/v.vasilenko/Documents/XcodeProjects/ChildGames/ChildGamesswift
//  ChildGames
//
//  Created by v.vasilenko on 26.08.16.
//  Copyright © 2016 v.vasilenko. All rights reserved.
//

import UIKit

let CGStaticHeight = 44.0;

enum CGMainScreenTableSections : Int {
    case MainSection = 0
}

// MARK: - User Defaults
let CGBabyBirthDateUserDefaults = "babyBirthDate"
let CGBabyBirthCancelUserDefaults = "isBabyBirthCanceled"
let CGBabyBirthCancelValue = "canceled"

// MARK: - Segue names of MainScreen
let CGGamesScreenSegueName = "gamesScreenSegue"

// MARK: - String constants of MainScreen
let CGBirthAlertTitle = "Дата рождения малыша"
let CGBirthDayPrefix = "Вашему ребенку уже\n"
let CGBirthAlertMessage = "Введите дату рождения вашего малыша"
let CGBirthDatePlaceholder = "Например 14.06.2016"
let CGMainScreenTitle = "Игры для развития малыша"
let CGCancelTitle =  "Отмена"
let CGConfirmTitle = "Подтвердить"
let CGBirthdayAltText = "Ваш малыш растет вместе с пчелкой BabyBee"

let CGAnalyticsEventCategorySelect = "Выбрана категория: %@"
let CGAnalyticsCategoryClick = "Нажатие"
let CGAnalyticsEventBirthdayCancel = "Cancel - дата рождения"
let CGAnalyticsEventBirthdayOk = "Ок - дата рождения"

class CGMainScreenViewController: UIViewController, CGAgeAskingDelegate, CGMainScreenDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var mainScreenDDM : CGMainScreenDDM!
    var dataModel : CGDataModelProtocol!
    
    var resultBirthDayStr = ""
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    // MARK: - CGAgeAskingDelegate
    func ageConfirm( birthDate: NSDate ) {
        let now = NSDate()
        let components = birthDate.numberOfMonthsAndDaysToTime(now)
        let pluralBirthDay = String().convertDateComponentsToPluralDate(components)
        
        resultBirthDayStr = CGBirthDayPrefix + " " + pluralBirthDay
        
        userDefaults.setObject(birthDate, forKey: CGBabyBirthDateUserDefaults)
        
        let dateString = birthDate.convertDateToGOSTDateString()
        // Send to Analytics confirm Action
        self.sendAction(CGAnalyticsEventBirthdayOk + " " + dateString,
                        categoryName: CGAnalyticsCategoryClick,
                        label: dateString,
                        value: 0)
        
        tableView.reloadData()
    }
    func ageCancelled() {
        self.resultBirthDayStr = CGBirthdayAltText
        self.sendAction(CGAnalyticsEventBirthdayCancel,
                        categoryName: CGAnalyticsCategoryClick,
                        label: "",
                        value: 0)
        
        self.userDefaults.setObject(NSNumber(bool: true),
                                    forKey: CGBabyBirthCancelUserDefaults)
        tableView.reloadData()
    }
    
    // MARK: - CGMainScreenProtocol used in UITableViewDelegate
    
    func birthdayString() -> String {
        return resultBirthDayStr
    }
    
    func didSelectedGroup(groupName : String, selectedRow: Int) {
        let actionName = String(format: CGAnalyticsEventCategorySelect, NSNumber(integer: selectedRow))
        
        sendAction(actionName,
                   categoryName: CGAnalyticsCategoryClick,
                   label: "\(groupName)",
                   value: selectedRow)
        
        performSegueWithIdentifier(CGGamesScreenSegueName, sender: self);
    }
    
    // MARK: - UIViewController
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = CGMainScreenTitle;
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        sendOpenScreen(CGMainScreenTitle)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataModel = CGDataModelJSONAdapter(mainFileName: "mums")
        self.mainScreenDDM = CGMainScreenDDM(mainScreenDelegate: self, dataModel: self.dataModel)
        
        let nibHeaderView = UINib(nibName: String(CGHeaderView), bundle: nil)
        tableView.registerNib(nibHeaderView, forHeaderFooterViewReuseIdentifier: String(CGHeaderView))
        
        let nibMainScreenCell = UINib(nibName: String(CGMainScreenCell), bundle: nil)
        tableView.registerNib(nibMainScreenCell, forCellReuseIdentifier: String(CGMainScreenCell));
        
        let nibAboutUsCell = UINib(nibName: String(CGAboutUsCell), bundle: nil)
        tableView.registerNib(nibAboutUsCell, forCellReuseIdentifier: String(CGAboutUsCell));
        
        tableView.delegate = self.mainScreenDDM;
        tableView.dataSource = self.mainScreenDDM;
        
        // Show birthday Popup
        self.askAgeIfNeeded()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == CGGamesScreenSegueName {
            if let destinationVC = segue.destinationViewController as? CGGamesScreenViewController {
                destinationVC.selectedGroupId = mainScreenDDM.selectedIndexRow
                destinationVC.dataModel = self.dataModel
            }
        }
    }
    
    // MARK: Helper Methods
    func askAgeIfNeeded() {
        // Show birthday Popup
        if let isCanceledBirthDay = userDefaults.objectForKey(CGBabyBirthCancelUserDefaults) as? NSNumber where isCanceledBirthDay == true {
            resultBirthDayStr = CGBirthdayAltText
        } else {
            if let birthDate = userDefaults.objectForKey(CGBabyBirthDateUserDefaults) as? NSDate {
                self.ageConfirm(birthDate)
            } else {
                let ageAskVC = CGAgeAskingController(title: CGBirthAlertTitle,
                                                     message: CGBirthAlertMessage,
                                                     preferredStyle: .Alert)
                ageAskVC.ageAskingDelegate = self
                self.presentViewController(ageAskVC, animated: true, completion: nil)
            }
        }
    }
}

