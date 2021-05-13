//
//  QuizzesViewController.swift
//  QuizApp
//
//  Created by five on 10/04/2021.
//  Copyright © 2021 five. All rights reserved.
//

import Foundation
import UIKit

class QuizzesViewController: UIViewController {
    
    private var container: UIView!
    private var quizlistContainer: UIView!
    private var quizlistCollectionView: UICollectionView!
    private var gradientLayer: CAGradientLayer!
    
    private var ds: DataService!
    
    private var titleLabel: UILabel!
    private var getQuizButton: UIButton!
    private var funFactImageView: UIImageView!
    private var funFactLabel: UILabel!
    private var funFactBody: UILabel!
    
    private var quizlist: [Quiz]!
    private var quizlistByCategory: [Int: [Quiz]]!
    
    // some commonly used values
    private let colorBackgroundLight = UIColor(red: 0.45, green: 0.31, blue: 0.64, alpha: 1.00)
    private let colorBackgroundDark = UIColor(red: 0.15, green: 0.18, blue: 0.46, alpha: 1.00)
    private let inputFieldCornerRadius = CGFloat(22)
    private let inputFieldHeight = CGFloat(44)
    private let inputFieldMaxWidth = CGFloat(400)
    private let inputFieldFontSize = CGFloat(16.0)
    private let inputFieldLeftPadding = CGFloat(21)
    private let inputFieldRightPadding = CGFloat(-21)
    private let fieldSpacing = CGFloat(16.0)
    private let colorInputField = UIColor(white: 1.0, alpha: 0.3)
    private let colorButtonText = UIColor(red: 0.39, green: 0.16, blue: 0.87, alpha: 1.00)
    private let disabledButtonOpacity = CGFloat(0.60)
    
    lazy var collectionViewFlowLayout : CustomCollectionViewFlowLayout = {
        let layout = CustomCollectionViewFlowLayout(display: .list, containerWidth: self.view.bounds.width)
        layout.headerReferenceSize = CGSize(width: 0, height: 56)
        return layout
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [colorBackgroundLight.cgColor, colorBackgroundDark.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.6, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.4, y: 1.0)
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        //set only arrow as back button
        self.parent!.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        //set back button color
        self.parent!.navigationController?.navigationBar.tintColor = .white
        // set light status bar contents
        self.parent!.navigationController?.navigationBar.barStyle = .black

        ds = DataService()
        quizlist = [Quiz]()
        quizlistByCategory = [Int: [Quiz]]()
        buildViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        gradientLayer.frame = view.bounds
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.reloadCollectionViewLayout(self.view.bounds.size.width)
    }
    
    // doesn't work, something to do with presenting views
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.titleView = titleLabel
    }

    private func reloadCollectionViewLayout(_ width: CGFloat) {
        self.collectionViewFlowLayout.containerWidth = width
        self.collectionViewFlowLayout.display = self.view.traitCollection.horizontalSizeClass == .compact && self.view.traitCollection.verticalSizeClass == .regular ? CollectionDisplay.list : CollectionDisplay.grid(columns: 2)

        }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        return .portrait
//    }
    
    private func buildViews() {
        createViews()
        styleViews()
        defineLayoutForViews()
    }
    
    private func createViews() {
        container = UIView()
        view.addSubview(container)
        
        quizlistContainer = UIView()
        quizlistContainer.isHidden = true
        container.addSubview(quizlistContainer)
        
        titleLabel = UILabel()
        titleLabel.text = "QuizApp"
        self.parent!.navigationItem.titleView = titleLabel
        
        getQuizButton = UIButton()
        getQuizButton.setTitle("Get Quiz", for: .normal)
        getQuizButton.isUserInteractionEnabled = true
        getQuizButton.addTarget(self, action: #selector(self.getQuiz(_:)), for: .touchUpInside)
        container.addSubview(getQuizButton)
        
        funFactImageView = UIImageView(image: UIImage(named: "lightbulb"))
        quizlistContainer.addSubview(funFactImageView)
        
        funFactLabel = UILabel()
        funFactLabel.text = "Fun fact"
        quizlistContainer.addSubview(funFactLabel)
        
        funFactBody = UILabel()
        funFactBody.text = ""
        funFactBody.lineBreakMode = .byWordWrapping
        funFactBody.numberOfLines = 0
        quizlistContainer.addSubview(funFactBody)
        
        
        quizlistCollectionView = {
            // sets to smallest needed size, not fixed size per section
            //layout.estimatedItemSize = QuizzesViewFlowLayout.automaticSize
            let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout)
            return collectionView
        }()
        quizlistCollectionView?.alwaysBounceVertical = true
        quizlistCollectionView?.bounces = true
        quizlistCollectionView?.delegate = self
        quizlistCollectionView?.dataSource = nil
        quizlistCollectionView.register(QuizzesViewCell.self, forCellWithReuseIdentifier: "QuizCell")
        quizlistCollectionView.register(QuizHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "\(QuizHeaderView.self)")  // UICollectionReusableView
        quizlistContainer.addSubview(quizlistCollectionView)
    }
    
    private func styleViews() {
        titleLabel.textColor = .white
        titleLabel.font = UIFont(name: "SourceSansPro-Bold", size: 24.0)
        
        getQuizButton.backgroundColor = .white
        getQuizButton.titleLabel?.font = UIFont(name: "SourceSansPro-Bold", size: inputFieldFontSize)
        getQuizButton.setTitleColor(colorButtonText, for: .normal)
        getQuizButton.layer.cornerRadius = inputFieldCornerRadius
        
        quizlistContainer.backgroundColor = .clear
        quizlistCollectionView.backgroundColor = .clear
        
        funFactLabel.textColor = .white
        funFactLabel.font = UIFont(name: "SourceSansPro-Bold", size: 24.0)
        
        funFactBody.textColor = .white
        funFactBody.font = UIFont(name: "SourceSansPro-SemiBold", size: 18.0)
    }
    
    private func defineLayoutForViews() {
        container.translatesAutoresizingMaskIntoConstraints = false
        quizlistContainer.translatesAutoresizingMaskIntoConstraints = false
        getQuizButton.translatesAutoresizingMaskIntoConstraints = false
        funFactImageView.translatesAutoresizingMaskIntoConstraints = false
        funFactLabel.translatesAutoresizingMaskIntoConstraints = false
        funFactBody.translatesAutoresizingMaskIntoConstraints = false
        quizlistCollectionView.translatesAutoresizingMaskIntoConstraints = false

        let getQuizButtonLeading = getQuizButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 30)
        let getQuizButtonTrailing = getQuizButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -30)
        
        getQuizButtonLeading.priority = UILayoutPriority(750)
        getQuizButtonTrailing.priority = UILayoutPriority(750)
        
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            container.topAnchor.constraint(equalTo: view.topAnchor),
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            quizlistContainer.topAnchor.constraint(equalTo: getQuizButton.bottomAnchor, constant: 28),
            quizlistContainer.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            quizlistContainer.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            quizlistContainer.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            
            quizlistCollectionView.topAnchor.constraint(equalTo: funFactBody.bottomAnchor, constant: 10),
            quizlistCollectionView.leadingAnchor.constraint(equalTo: quizlistContainer.leadingAnchor),
            quizlistCollectionView.trailingAnchor.constraint(equalTo: quizlistContainer.trailingAnchor),
            quizlistCollectionView.bottomAnchor.constraint(equalTo: quizlistContainer.bottomAnchor),
            
            getQuizButtonLeading,
            getQuizButtonTrailing,
            getQuizButton.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            getQuizButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 14),
            getQuizButton.widthAnchor.constraint(lessThanOrEqualToConstant: inputFieldMaxWidth),
            getQuizButton.heightAnchor.constraint(equalToConstant: inputFieldHeight),
            
            funFactImageView.topAnchor.constraint(equalTo: quizlistContainer.topAnchor, constant: 4),
            funFactImageView.leadingAnchor.constraint(equalTo: quizlistContainer.leadingAnchor, constant: 24),
            funFactImageView.heightAnchor.constraint(equalToConstant: 28),
            funFactImageView.widthAnchor.constraint(equalToConstant: 28),
            
            funFactLabel.topAnchor.constraint(equalTo: quizlistContainer.topAnchor, constant: 4),
            funFactLabel.leadingAnchor.constraint(equalTo: funFactImageView.trailingAnchor, constant: 10),
            
            funFactBody.topAnchor.constraint(equalTo: funFactLabel.bottomAnchor, constant: 10),
            funFactBody.leadingAnchor.constraint(equalTo: quizlistContainer.leadingAnchor, constant: 24),
            funFactBody.trailingAnchor.constraint(equalTo: quizlistContainer.trailingAnchor, constant: -24)
        ])
    }
    
    // getQuizButton target
    @objc func getQuiz(_: UIButton) {
        quizlistContainer.isHidden = false
        quizlist = ds.fetchQuizes()
        quizlistByCategory = distributeByCategory(list: quizlist)
        quizlistCollectionView?.dataSource = self
        self.quizlistCollectionView.performBatchUpdates({
            // seems slow, maybe consider other options later
            self.quizlistCollectionView.reloadData()
        }, completion: nil)
        
        let occurences = getOccurencesInQuizQuestions(string: "NBA")
        funFactBody.text =
        """
        There are \(String(occurences)) questions that contain the word "NBA".
        """
    }
    
    private func getOccurencesInQuizQuestions(string: String) -> Int {
        if quizlist == nil {
            return 0
        }
        var total = 0
        for quiz in quizlist {
            let inCurrentQuiz = quiz.questions.map{$0.question.contains(string) ? 1 : 0}.filter{$0 == 1}.count
            total = total + inCurrentQuiz
        }
        return total
    }
    
}

extension QuizzesViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return quizlistByCategory.keys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if quizlist == nil {
            return 0
        }
        var items = 0
        let category: QuizCategory!
        switch section {
        case 0:
            category = .sport
        case 1:
            category = .science
        default:
            category = nil
        }
        
        // this could be replaced by a count over quizlistByCategory[section]
        for quiz in quizlist {
            if quiz.category == category {
                items = items + 1
            }
        }
        return items
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QuizCell", for: indexPath) as! QuizzesViewCell
        guard let currentQuiz = quizlistByCategory[indexPath[0]]?[indexPath[1]] else { return cell }
        
        cell.quizTitle.text = currentQuiz.title
        cell.quizDescription.text = currentQuiz.description
        
        //determine which thumbnail to show, a bit crude but temporary
        var image: UIImage!
        image = UIImage(named: "quiz-sport-intermediate")
        let str = cell.quizTitle.text
        if (str?.contains("Basic"))! {
            if (str?.contains("sport"))! {
                image = UIImage(named: "quiz-sport-basic")
            } else if (str?.contains("science"))! {
                image = UIImage(named: "quiz-science-basic")
            }
        } else {
            image = UIImage(named: "quiz-sport-intermediate")
        }
        cell.thumbnail.image = image
        cell.setLevel(level: currentQuiz.level)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "\(QuizHeaderView.self)", for: indexPath) as! QuizHeaderView
            
            var category: String!
            switch indexPath.section {
            case 0:
                category = "Sport"
            case 1:
                category = "Science"
            default:
                category = ""
            }
            headerView.titleLabel.text = category
            return headerView
        default:
            assert(false, "Invalid element type")
        }
    }
    
    /* Creates a dictionary from the original quiz array.
     * This makes it easier to index using indexPath.
     */
    func distributeByCategory(list: [Quiz]) -> [Int: [Quiz]] {
        var byCategory = Dictionary(grouping: list, by: {
            QuizCategory.allCases.firstIndex(of: $0.category) ?? 0
        })
        return byCategory
    }
}


extension QuizzesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedQuiz = quizlistByCategory[indexPath[0]]?[indexPath[1]] else { return }
        let vc = QuizViewController(quiz: selectedQuiz)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


extension QuizzesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 40, height: 143)
    }
}


class CustomCollectionViewFlowLayout: UICollectionViewFlowLayout {
    var display: CollectionDisplay = .list {
        didSet {
            if display != oldValue {
                self.invalidateLayout()
            }
        }
    }
    
    var containerWidth: CGFloat = 0.0 {
        didSet {
            if containerWidth != oldValue {
                self.invalidateLayout()
            }
        }
    }
    
    convenience init(display: CollectionDisplay, containerWidth: CGFloat) {
        self.init()
        
        self.display = display
        self.containerWidth = containerWidth
        self.minimumLineSpacing = 10
        self.minimumInteritemSpacing = 10
        self.configLayout()
    }
    
    func configLayout() {
        switch display {
        case .inline:
            self.scrollDirection = .vertical
            self.itemSize = CGSize(width: containerWidth, height: 143)
        
        case .grid(let column):
            self.scrollDirection = .vertical
            let spacing = CGFloat(column - 1) * minimumLineSpacing
            let optimisedWidth = (containerWidth - spacing) / CGFloat(column)
            self.itemSize = CGSize(width: optimisedWidth , height: 143) // keep as square

        case .list:
            self.scrollDirection = .vertical
            self.itemSize = CGSize(width: containerWidth, height: 143)
        }
    }

    override func invalidateLayout() {
        super.invalidateLayout()
        self.configLayout()
    }
}
