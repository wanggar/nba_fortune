//
//  ViewController.swift
//  Scroll
//
//  Created by Amie Deng on 11/18/18.
//  Copyright © 2018 Amie Deng. All rights reserved.
//

import UIKit

class PlayerCollectionViewController: UIViewController, UIScrollViewDelegate, PlayerDetailViewControllerDelegate {
    var gradientLayer: CAGradientLayer!

    @IBOutlet var scrollView: UIScrollView! {
        didSet{
            scrollView.delegate = self
        }
    }
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var sellButton: UIButton!
    
    var slides:[Slide] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.bringSubview(toFront: pageControl)
        createGradientLayer()
    }
    
    func createGradientLayer() {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: self.view.frame.height )
        
        gradientLayer.colors = [UIColor(red: 0.149, green: 0.2353, blue: 0.4431, alpha: 1.0).cgColor, UIColor(red: 0.0745, green: 0.1176, blue: 0.2235, alpha: 1.0).cgColor]
        gradientLayer.locations = [0.25, 0.75]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateSlides()
        if slides.isEmpty {
            sellButton.isEnabled = false
        } else {
            sellButton.isEnabled = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        clearSlides()
    }
    
    func updateSlides() {
        
        if let newSlides = createSlides() as? [Slide] {
            slides = newSlides
        }
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
        view.bringSubview(toFront: pageControl)
        setupSlideScrollView(slides: slides)
        
        if let emptySlide = createSlides()[0] as? EmptySlide {
            emptySlide.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
            scrollView.addSubview(emptySlide)
        }
    }
    
    func clearSlides() {
        slides = []
//        for subview in scrollView.subviews {
//            if let _ = subview as? Slide {
//                scrollView.willRemoveSubview(subview)
//            }
//            if let _ = subview as? EmptySlide {
//                scrollView.willRemoveSubview(subview)
//            }
//        }
        for subview in scrollView.subviews {
            subview.removeFromSuperview()
        }
    }

    //
    func createSlides() -> [Any] {
//        let slide1:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
//        slide1.imageView.image = UIImage(named: "9158")
//        slide1.labelTitle.text = "Lebron James"
//
//        let slide2:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
//        slide2.imageView.image = UIImage(named: "9232")
//        slide2.labelTitle.text = "James Harden"
//
//        let slide3:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
//        slide3.imageView.image = UIImage(named: "9386")
//        slide3.labelTitle.text = "Kevin Durant"
//
//        let slide4:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
//        slide4.imageView.image = UIImage(named: "9354")
//        slide4.labelTitle.text = "Anthony Davis"
//
//        let slide5:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
//        slide5.imageView.image = UIImage(named: "9418")
//        slide5.labelTitle.text = "Joel Embiid"
//
//        return [slide1, slide2, slide3, slide4, slide5]
        
        if !PlayerCollectionManager.playerCollections.isEmpty {
            var slides: [Slide] = []
            for playerCollection in PlayerCollectionManager.playerCollections {
                let newSlide: Slide = Bundle.main.loadNibNamed("Slide", owner: self)?.first as! Slide
                newSlide.imageView.image = playerCollection.image
                newSlide.labelTitle.text = playerCollection.name
                slides.append(newSlide)
            }
            
            return slides
        } else {
            let emptySlide = Bundle.main.loadNibNamed("EmptySlide", owner: self)?.first as! UIView
            return [emptySlide]
        }
    }
    
    // for view controllers in other tabs
    func addPlayerCollections(id: Int, name: String) {
         PlayerCollectionManager.addToPlayerCollections(id: id, name: name)
    }
    
    func deletePlayerCollection(forId id: Int) {
        PlayerCollectionManager.deletePlayerCollection(forId: id)
    }
    
    // function to set up scroll view
    func setupSlideScrollView(slides : [Slide]) {
        scrollView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        scrollView.contentSize = CGSize(width: scrollView.bounds.width * CGFloat(slides.count), height: 1.0)
        scrollView.isPagingEnabled = true
        
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: scrollView.bounds.width * CGFloat(i), y: 0, width: scrollView.bounds.width, height: 1.0)
            scrollView.addSubview(slides[i])
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier{
            if identifier == "toSearchPage"{
                guard let playerSearchViewController = segue.destination as? playerSearchViewController else {return}
                playerSearchViewController.delegateBaton = self
            }
            if identifier == "toSellPage" {
                guard let sellViewController = segue.destination as? SellViewController else {return}
                let currentPlayerData = PlayerCollectionManager.playerCollections[pageControl.currentPage]
                let id = currentPlayerData.id
                let name = currentPlayerData.name
                sellViewController.transactedPlayerId = id
                sellViewController.transactedPlayerName = name
                sellViewController.delegate = self
            }
        }
    }
    
    //add func
    func buyPlayer(id: Int, name: String) {
        addPlayerCollections(id: id, name: name)
    }
    
    func sellPlayer(id: Int) {
        deletePlayerCollection(forId: id)
    }
}

