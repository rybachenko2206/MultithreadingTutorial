//
//  ViewController.swift
//  MultithreadingTutorial
//
//  Created by Roman Rybachenko on 4/11/17.
//  Copyright © 2017 Roman Rybachenko. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    // MARK: Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    
    // MARK: Properties
    let operationQueue = OperationQueue()
    var currOperation: BlockOperation?
    let imageUrls = ["https://www.nasa.gov/sites/default/files/thumbnails/image/pia03883-nohuygens.jpg",
                     "https://www.nasa.gov/sites/default/files/thumbnails/image/pia14636-1041.jpg",
                     "https://www.nasa.gov/sites/default/files/thumbnails/image/187_1003705_americas_dxm.png"]
    
    
    // MARK: Overriden funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        
        operationQueue.maxConcurrentOperationCount = 1
//        firstTestOperationQueue()
        
        showImage(segmentedControl)
    }
    
    
    // MARK: Action funcs
    @IBAction func showImage(_ sender: UISegmentedControl) {
        imageView.image = nil
        operationQueue.cancelAllOperations()
        
        let urlStr = imageUrls[sender.selectedSegmentIndex]
        guard let imgUrl = URL.init(string: urlStr) else {
            return
        }
        spinner.startAnimating()
        currOperation = BlockOperation(block: { [weak self] in
            if let imgData = NSData.init(contentsOf: imgUrl) {
                OperationQueue.main.addOperation { [weak self] in
                    self?.imageView.image = UIImage(data: imgData as Data)
                    self?.spinner.stopAnimating()
                }
                
            } else {
                
            }
        })
//        currOperation?.completionBlock = { [weak self] in
//            self?.spinner.stopAnimating()
//            self?.spinner.isHidden = true
//        }
        if let last = operationQueue.operations.last {
            if last.isExecuting {
                last.cancel()
            }
        }
        operationQueue.addOperation(currOperation!)
    }
    
    
    // MARK: Private funcs
    private func firstTestOperationQueue() {
        operationQueue.maxConcurrentOperationCount = 1
        // можна задавати dependency для кожної новоствореної operation,
        // а можна задати operationQueue.maxConcurrentOperationCount = 1 для послідовного виконання.
        
        operationQueue.addOperation({
            print("\n~~operation 1 from operationBlock")
            print("is main thread = \(Thread.isMainThread)")
            for j in 0..<1_000 {
                print("j = \(j)")
            }
        })
        
        
        let operation2 = BlockOperation(block: {
            for i in 0..<10_000 {
                print("i = \(i)")
            }
        })
        operation2.completionBlock = {
            print("\n~~operation 2 completed \n\n")
            print("is main thread = \(Thread.isMainThread)")
        }
        
        //        if let lastOp = operationQueue.operations.last {
        //            operation2.addDependency(lastOp)
        //        }
        operationQueue.addOperation(operation2)
        
        let operationBlock = BlockOperation(block: {
            print("\n~~operation 3 in BlockOperation")
            print("is main thread = \(Thread.isMainThread)")
        })
        //        if let lastOp = operationQueue.operations.last {
        //            operationBlock.addDependency(lastOp)
        //        }
        operationBlock.addExecutionBlock {
            print("operationBlock.addExecutionBlock 1")
            print("is main thread = \(Thread.isMainThread)")
            for k in 0..<1_000 {
                print("k = \(k)")
            }
        }
        //   тут можна заплутатись, з executionBlocks якщо захотіти -
        //   можна одночасно додати 3 (три) !!! блоки коду в 1 (одну) операцію
        operationBlock.addExecutionBlock({
            
            print("operationBlock.addExecutionBlock 2")
            print("is main thread = \(Thread.isMainThread)")
            for n in 0..<1_000 {
                print("n = \(n)")
            }
        })
        operationBlock.completionBlock = {
            OperationQueue.main.addOperation({ [weak self] in
                print("is main thread = \(Thread.isMainThread)")
                self?.showAlertCompletedAll()
            })
        }
        operationQueue.addOperation(operationBlock)
    }


    private func showAlertCompletedAll() {
        let ac = UIAlertController(title: "Success",
                                   message: "All operation are comleted",
                                   preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK",
                                     style: .default,
                                     handler: { action in })
        ac.addAction(okAction)
        present(ac, animated: true, completion: nil)
    }
}

