//
//  GCDViewController.swift
//  MultithreadingTutorial
//
//  Created by Roman Rybachenko on 4/13/17.
//  Copyright © 2017 Roman Rybachenko. All rights reserved.
//

import UIKit

class GCDViewController: UIViewController, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let serialQueue = DispatchQueue(label: "serialQueue")
    let myQueue = DispatchQueue(label: "myQueue", qos: .background, attributes: .concurrent)
    
    let imageURLs = ["http://www.planetware.com/photos-large/F/france-paris-eiffel-tower.jpg",
                     "http://adriatic-lines.com/wp-content/uploads/2015/04/canal-of-Venice.jpg",
                     "https://www.nasa.gov/sites/default/files/thumbnails/image/187_1003705_americas_dxm.png",
                     "https://www.nasa.gov/sites/default/files/thumbnails/image/pia14636-1041.jpg"]
    var images: [UIImage?] = [nil, nil, nil, nil]
    

    // MARK: Overriden funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "GCD"

        collectionView.dataSource = self
        
        downloadImages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        simpleQueues()
        
//        print("myQueue priority = \(myQueue.qos)")
        
//        concurrentQueues()
        
//        delayingQueue()
        
//        useWorkItem()
    }
    
    
    // MARK: Delegate funcs:
    // MARK: —UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell",
                                                      for: indexPath) as! ImageCell
        cell.image = self.images[indexPath.item]
        
        return cell
    }
    

    
    // MARK: Private funcs
    
    private func downloadImages() {
        for i in 0..<imageURLs.count {
            let imgUrl = URL(string: imageURLs[i])!
            downloadImage(at: imgUrl,  completion: { [weak self] (image, error) in
                self?.images[i] = image
                let indexPath = IndexPath(item: i, section: 0)
                self?.reloadCell(at: indexPath)
            })
        }
    }
    
    private func downloadImage(at url: URL, completion: @escaping (UIImage?, Error?) -> () ) {
        myQueue.async { //serialQueue.async {    // якщо викокистовуємо DispatchQueue concurrent, то
            do {                                 // буде качатись одразу 4 фото в різних потоках
                let imgData = try Data.init(contentsOf: url)   // якщо ж serial queue - будуть качатись всі послідовно
                let image = UIImage(data: imgData)
                completion(image, nil)
            } catch let error as NSError {
                print("download image error -> \n ", error.localizedDescription)
                completion(nil, error as Error)
            }
        }
    }
    
    private func reloadCell(at indexPath: IndexPath) {
        let indexPathsForVisibleCells = collectionView.indexPathsForVisibleItems
        if indexPathsForVisibleCells.contains(indexPath) == false {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadItems(at: [indexPath])
        }
    }
    
    
    
    private func simpleQueues() {
        // use sync
//        myQueue.sync {
//            printIsMainThread()
//            printSmilesFun()
//        }
        
        // use async
        myQueue.async { [weak self] in
            self?.printIsMainThread()
            self?.printSmilesFun()
        }
        
        printSmilesCool()
    }
    
    private func concurrentQueues() {
        
        var anotherQueue = DispatchQueue(label: "myAnotherQueue",
                                         qos: .utility,
                                         attributes: .concurrent)
        let thirdQueue = DispatchQueue(label: "thirdQueue",
                                       qos: .userInteractive,
                                       attributes: .concurrent)

        
        anotherQueue.async { [unowned self] in
            self.printEmoji(emoji: "🍎")
        }
        
        myQueue.async { [unowned self] in
            self.printSmilesCool()
        }
        
        thirdQueue.async { [unowned self] in
            self.printEmoji(emoji: "🚲")
        }
//        anotherQueue.async { [unowned self] in
//            self.printEmoji(emoji: "🍊")
//        }
//        
//        anotherQueue.async { [unowned self] in
//            self.printEmoji(emoji: "🍒")
//        }
    }
    
    
    private func delayingQueue() {
        let delayQueue = DispatchQueue(label: "myDeleayQueue", qos: .userInitiated, attributes: .concurrent)
        
        print(Date())
        let additionalTime: DispatchTimeInterval = .seconds(3)
        
        delayQueue.asyncAfter(deadline: DispatchTime.now() + additionalTime,
                              execute: { [unowned self] in
                                
                                print(Date())
                                self.printIsMainThread()
                                self.printEmoji(emoji: "⚽️")
        })
    }
    
    
    private func useWorkItem() {
        var value = 10
        print("value = \(value)")
        
        let workItem = DispatchWorkItem {
            value += 5
        }
        
//        workItem.perform()
        
        let queue = DispatchQueue.global(qos: .background)
        queue.async(execute: workItem)
        

        workItem.notify(queue: DispatchQueue.main,
                        execute: { [unowned self] in
                            self.printIsMainThread()
                            print("value = ", value)
        })
    }
    
    
    private func printSmilesFun() {
        for i in 0..<10 {
            print("\(i) 😀")
        }
    }
    
    private func printSmilesCool() {
        for i in 0..<10 {
            print("😎", i)
        }
    }
    
    private func printEmoji(emoji: String) {
        for i in 0..<10 {
            print("\(emoji)", i)
        }
    }
    
    private func printIsMainThread() {
        if Thread.isMainThread == true {
            print("~~ It's main thread")
        } else {
            print("~~ It's background thread")
        }
    }

}
