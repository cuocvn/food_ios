//
//  MealListController.swift
//  FoodManagement2027
//
//  Created by User on 04.11.2026.
//

import UIKit

class MealListController: UIViewController {
    // MARK: - Properties
    // Datasource cho Table View
    private var mealList = [Meal]()
    private let reuseCell = "myTableCell"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    // Doi tuong CSDL
    private let dao = FoodDatabase()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Them du lieu gia cho datasource
        /*if let meal = Meal(name: "Ca ran", image: UIImage(named: "default"), rating: 4) {
            mealList.append(meal)
        }*/
        
        // 2. Dang ky myCell (xib) cho doi tuong table view
        let cellNib = UINib(nibName: "myCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: reuseCell)
        
        // 3. Thuc hien uy quyen cho doi tuong table view
        tableView.delegate = self
        tableView.dataSource = self
        
        // 4. Thiet lap chieu cao cho moi dong
        tableView.rowHeight = 90
        
        // Them button edit bang code cho navigation bar
        // Lay navigationItem trong navigationbar
        if let navigationItem = navigationBar?.topItem {
            // Dua editButtonItem vao navigationItem ben trai
            navigationItem.leftBarButtonItem = editButtonItem
        }
    }
}

// MARK: - Cac ham uy quyen cua Table View (UITableViewDelegate, UITableViewDataSource)
extension MealListController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mealList.count
    }
    
    // Ham do du lieu cho tung phan tu cua TableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseCell = "myTableCell"
        if let cell = tableView.dequeueReusableCell(withIdentifier: reuseCell) as? MyCell {
            // Lay du lieu can do vao tableView tu datasource
            let meal = mealList[indexPath.row]
            // Do du lieu vao cell
            cell.mealImage.image = meal.image
            cell.mealName.text = meal.name
            cell.mealRating.rating = meal.rating
            
            return cell
        }
        else {
            // Tra ve cell rong
            return UITableViewCell()
        }
    }
    
    // Dinh nghia lai ham setEditing
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        // Chuyen chuc nang cho tableView
        tableView.setEditing(editing, animated: animated)
    }
    
    // Dinh nghia lai ham xoa phan tu cua tableView
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Xoa du lieu trong datasource
            mealList.remove(at: indexPath.row)
            // Xoa phan tu tu tableView
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
                
    // MARK: Quay ve tu man hinh DetailController
    @IBAction func unwindFromDetailController(segue: UIStoryboardSegue) {
    //print("Quay ve tu DetailController")
    //3. cap nhat mon an tu man hinh meal detail ve
    //lay toan bo man hinh mealdetail va lay gia tri vua tao
    if let mealDetailController = segue.source as? MealDetailController, let meal = mealDetailController.meal {
                        
        //cap nhat tableView
        //3.1 tim vi tri de chen man an moi trong tableview
        let newIndexPath = IndexPath(row: mealList.count, section: 0)
        //3.2 dua mon an moi vao mealList
        mealList.append(meal)
        //3.3 capnhat len tableView
        tableView.insertRows(at: [newIndexPath], with: .fade)
        }
    }
    
    // Xy li truoc khi chuyen man hinh
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Xu li callBack tu man hinh b
        if let detailController = segue.destination as? MealDetailController {
            detailController.getBackData = { (meal:Meal) in
                //cap nhat tableView
                //3.1 tim vi tri de chen mon an moi trong tableview
                let newIndexPath = IndexPath(row: self.mealList.count, section: 0)
                //3.2 dua mon an moi vao mealList
                self.mealList.append(meal)
                //3.3 capnhat len tableView
                self.tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        }
    }
    
    
    
    // Xu li chuyen man hinh khi edit mon an
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //bo chon moi khi select row
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 1. lay bien meal trong duoc chon
        let meal = mealList[indexPath.row]
        
        // 2.1 Tao man hinh detail bang cong cu storyboard (ho tro cac dinh danh MealDetailController / MealDetailID)
        let identifier = "MealDetailController"
        if let mealDetail = (self.storyboard?.instantiateViewController(withIdentifier: identifier)
            ?? self.storyboard?.instantiateViewController(withIdentifier: "MealDetailID")
            ?? self.storyboard?.instantiateViewController(withIdentifier: "MealDetailiD")) as? MealDetailController {
            //2.2 Truyen tham so cho man hinh detail
            mealDetail.meal = meal
            
            // 2.3 lay du lieu ve tu detail
            mealDetail.getBackData = { (newMeal:Meal) in
                // dua meal moi vao data source
                self.mealList[indexPath.row] = newMeal
                // cap nhat lai tren tableView
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
            
            // 3. Chuyen man hinh sang mealDetail Controller
            mealDetail.modalPresentationStyle = .fullScreen
            present(mealDetail, animated: true)
        }
    }
}
