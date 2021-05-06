//
//  QuizResultViewController.swift
//  QuizApp
//
//  Created by five on 07/05/2021.
//  Copyright © 2021 five. All rights reserved.
//

import Foundation
import UIKit

class QuizResultViewController: UIViewController {
    
    private var container: UIView!
    private var gradientLayer: CAGradientLayer!
    private var correct: Int!
    private var total: Int!
    private var resultLabel: UILabel!
    private var finishButton: UIButton!
    
    private let colorBackgroundLight = UIColor(red: 0.45, green: 0.31, blue: 0.64, alpha: 1.00)
    private let colorBackgroundDark = UIColor(red: 0.15, green: 0.18, blue: 0.46, alpha: 1.00)
    private let colorButtonText = UIColor(red: 0.39, green: 0.16, blue: 0.87, alpha: 1.00)
    private let buttonFont = UIFont(name: "SourceSansPro-Bold", size: 16.0)
    
    init(correct: Int, total: Int) {
        self.correct = correct
        self.total = total
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [colorBackgroundLight.cgColor, colorBackgroundDark.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.6, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.4, y: 1.0)
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        
        container = UIView()
        view.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        container.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        container.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        container.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        resultLabel = UILabel()
        container.addSubview(resultLabel)
        resultLabel.text = String(correct) + "/" + String(total)
        resultLabel.font = UIFont(name: "SourceSansPro-Bold", size: 88.0)
        resultLabel.textColor = .white
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        resultLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        resultLabel.bottomAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        
        let attrFinishLabel = NSAttributedString(string: "Finish Quiz", attributes: [.foregroundColor: colorButtonText, .font: buttonFont!])
        finishButton = UIButton()
        container.addSubview(finishButton)
        finishButton.setAttributedTitle(attrFinishLabel, for: .normal)
        finishButton.backgroundColor = .white
        finishButton.layer.cornerRadius = 22
        finishButton.addTarget(self, action: #selector(self.finished(_:)), for: .touchUpInside)
        finishButton.translatesAutoresizingMaskIntoConstraints = false
        finishButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 40).isActive = true
        finishButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -40).isActive = true
        finishButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -44).isActive = true
        finishButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        gradientLayer.frame = view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func finished(_: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}