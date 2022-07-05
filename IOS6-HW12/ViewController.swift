//
//  ViewController.swift
//  IOS6-HW12
//
//  Created by MAC on 05.07.2022.
//

import UIKit

class ViewController: UIViewController {
    private lazy var timer = Timer()
    private lazy var isStarted = false
    private lazy var isWorkTime = true
    private lazy var firstStart = true
    private lazy var shapeLayer = CAShapeLayer()
    private lazy var trackLayer = CAShapeLayer()
    private lazy var durationTimer = constants.workCount * constants.valueForConvert
    private lazy var currentTrackLayerColor = constants.workTrackLayerColor
    private lazy var currentShapeLayerColor = constants.restShapeLayerColor
    
    private lazy var workTimeLabel: UILabel = {
        let label = UILabel()
        
        label.text = timerLabelText(time: durationTimer)
        label.font = .systemFont(ofSize: 25, weight: .regular)
        label.textColor = .systemPink
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var workButton: UIButton = {
        
        let button = UIButton()
        
        button.setTitleColor(UIColor.systemPink, for: .normal)
        button.setImage(UIImage(systemName: "play"), for: .normal)
        button.tintColor = .systemPink
        button.addTarget(self, action: #selector(workButtonAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1 / constants.valueForConvert, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
           
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        
        return stackView
    }()
    
    // MARK: -Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupHierarchy()
        setupLayout()
    }
    
    // MARK: -Settings
    
    private func setupHierarchy() {
        view.addSubview(stackView)
        view.layer.addSublayer(trackLayer)
        view.layer.addSublayer(shapeLayer)
        
        stackView.addArrangedSubview(workTimeLabel)
        stackView.addArrangedSubview(workButton)
    }
    
    private func setupLayout() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        stackView.widthAnchor.constraint(equalToConstant: 70).isActive = true
    }
    
    override func viewDidLayoutSubviews() {
        createCircleWithAnimation()
    }
    
    private func createCircleWithAnimation() {
        let radius = min(view.frame.width, view.frame.height) / 4
        let startAngle = 3 / 2 * CGFloat.pi
        
        let endAngle = startAngle - (2 * CGFloat.pi)
        
        let circularPath = UIBezierPath(arcCenter: view.center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = isWorkTime ? constants.workTrackLayerColor : constants.restTrackLayerColor
        trackLayer.lineWidth = 5
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = CAShapeLayerLineCap.round
        
        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = isWorkTime ? constants.workShapeLayerColor : constants.restShapeLayerColor
        shapeLayer.lineWidth = 5
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        shapeLayer.strokeEnd = 1
    }
    
    private func timerLabelText(time: Double) -> String {
        let convertTime = Int(time / constants.valueForConvert)
        firstStart = false
        let minutes = convertTime / 60 % 60
        let seconds = convertTime % 60
        
        return String(format: "%02i:%02i", minutes, seconds)
    }
    
    private func setButtonImage() {
        let currentColor = isWorkTime ? UIColor.systemPink : UIColor.systemGreen
        let name = isStarted ? "pause" : "play"
        
        let image = UIImage(systemName: name)
        if image != nil {
            workButton.setImage(image?.withTintColor(currentColor, renderingMode: .alwaysOriginal), for: .normal)
        }
    }
    
    private func setupColor() {
        currentTrackLayerColor = isWorkTime ? constants.workTrackLayerColor : constants.restTrackLayerColor
        currentShapeLayerColor = isWorkTime ? constants.workShapeLayerColor : constants.restShapeLayerColor
        let currentOtherColor = isWorkTime ? UIColor.systemPink : UIColor.systemGreen
        
        trackLayer.strokeColor = currentTrackLayerColor
        shapeLayer.strokeColor = currentShapeLayerColor
        workTimeLabel.textColor = currentOtherColor
    }
    
    private func startAnimationAndTimer() {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.speed = 1.0
        basicAnimation.toValue = 0
        basicAnimation.duration = CFTimeInterval(durationTimer / constants.valueForConvert)
        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
        basicAnimation.isRemovedOnCompletion = true
        
        shapeLayer.add(basicAnimation, forKey: "basicAnimation")
        startTimer()
    }
    
    private func pauseAnimationAndTimer() {
        let pauseTime = shapeLayer.convertTime(CACurrentMediaTime(), from: nil)
        shapeLayer.speed = 0.0
        shapeLayer.timeOffset = pauseTime
        timer.invalidate()
    }
    
    private func resumeAnimationAndTimer() {
        startTimer()
        let pausedTime = shapeLayer.timeOffset
        shapeLayer.speed = 1.0
        shapeLayer.timeOffset = 0.0
        shapeLayer.beginTime = 0.0
        let timeSincePaused = shapeLayer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        shapeLayer.beginTime = timeSincePaused
    }
    
    private func getDuration() -> Double {
        return (isWorkTime ? constants.workCount : constants.restCount) * constants.valueForConvert
    }
    
    // MARK: -Actions
    
    @objc private func workButtonAction() {
        isStarted = !isStarted
        setButtonImage()
        
        if isStarted && durationTimer == (constants.workCount * constants.valueForConvert) || durationTimer == (constants.restCount * constants.valueForConvert) {
            startAnimationAndTimer()
        } else if !isStarted {
            pauseAnimationAndTimer()
        } else if workTimeLabel.text == timerLabelText(time: durationTimer) {
            resumeAnimationAndTimer()
        }
    }
    
    @objc private func timerAction() {
        if durationTimer == 0 {
            timer.invalidate()
            isWorkTime.toggle()
            isStarted = false
            setButtonImage()
            setupColor()
            durationTimer = getDuration()
            workTimeLabel.text = timerLabelText(time: durationTimer)
        } else {
        durationTimer -= 1
        workTimeLabel.text = timerLabelText(time: durationTimer)
        }
    }

        enum constants {
            static let workTrackLayerColor = UIColor.systemGray6.cgColor
            static let workShapeLayerColor = UIColor.systemPink.cgColor
            static let restTrackLayerColor = UIColor.systemGray6.cgColor
            static let restShapeLayerColor = UIColor.systemGreen.cgColor
            
            static let workCount = 10.0
            static let restCount = 5.0
            static let valueForConvert = 1000.0
        }
}

