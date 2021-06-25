//
//  ViewController.swift
//  JSWebp
//
//  Created by Jovins on 06/10/2021.
//  Copyright (c) 2021 Jovins. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let dataSource: [String] = [
        "https://p3.pstatp.com/obj/8fb5001380c325bb9bd0",
        "https://p3.pstatp.com/obj/81c7000699e3bc4bf034",
        "https://p3.pstatp.com/obj/95b6000a7b4d946e7004",
        "https://p3.pstatp.com/obj/94cd000f3023d6e4d9f6",
        "https://p3.pstatp.com/obj/8baf0006831bedf4253e",
        "https://p3.pstatp.com/obj/8fe0000f59ee50e3df5a",
        "https://p1.pstatp.com/obj/8ea1000c5e9ffc5cf373",
        "https://p3.pstatp.com/obj/94b9000913a7dee26742",
        "https://p9.pstatp.com/obj/8bcd000ef2b0ffc1c873",
        "https://p1.pstatp.com/obj/85780007f21bd2b45f38",
        "https://p3.pstatp.com/obj/76d7000944afb892fa94",
        "https://p3.pstatp.com/obj/95ce00070e35156ec896",
        "https://p9.pstatp.com/obj/96a90013e578d61cbb4e",
        "https://p3.pstatp.com/obj/8fa700044f7334be53e6",
        "https://p1.pstatp.com/obj/9454000c7ef1bace65f8",
        "https://p9.pstatp.com/obj/916e00125b85831ed6d8",
        "https://p3.pstatp.com/obj/94940005bf9ba3df7afd",
        "https://p1.pstatp.com/obj/93ec000590b1acba3b5d",
        "https://p1.pstatp.com/obj/808b0010da2d687c1a19",
        "https://p3.pstatp.com/obj/7f3d00088f91ec3e331d",
        "https://p3.pstatp.com/obj/815a000fada3b1582d0a",
        "https://p1.pstatp.com/obj/80590006f008d168d8e0",
        "https://p1.pstatp.com/obj/7d3800080e2d8815cf3a",
        "https://p3.pstatp.com/obj/7d9a000617d5df7e8728",
        "https://p1.pstatp.com/obj/7d340009a36ef7d65353",
        "https://p9.pstatp.com/obj/7fd30011aebe62774989",
        "https://p9.pstatp.com/obj/7d440007f9c21c972594",
        "https://p3.pstatp.com/obj/7dcb000e6ef93c9f6b9b",
        "https://p1.pstatp.com/obj/805400135aff3738be5f",
        "https://p3.pstatp.com/obj/7dcc000223a75def525c",
        "https://p3.pstatp.com/obj/7fcc000d728a72afd86f",
        "https://p1.pstatp.com/obj/800200038c8ed9efc2d7",
        "https://p3.pstatp.com/obj/803d0013497abf56124f",
        "https://p3.pstatp.com/obj/803500035c7277a9e9f1",
        "https://p3.pstatp.com/obj/7ff60009cb676d38383c",
        "https://p3.pstatp.com/obj/77420007e360babcf1ce",
        "https://p9.pstatp.com/obj/8011000b5cc18ee7e4ac",
        "https://p9.pstatp.com/obj/7a0f000007efeae726c6",
        "https://p3.pstatp.com/obj/80280005abd331a7d00e",
        "https://p3.pstatp.com/obj/77ee00053511fd77273c",
        "https://p1.pstatp.com/obj/7a1700151f38bc7f2fde",
        "https://p3.pstatp.com/obj/7ac8000de933897548a6",
        "https://p3.pstatp.com/obj/80280005abd331a7d00e",
        "https://p3.pstatp.com/obj/77ee00053511fd77273c",
        "https://p1.pstatp.com/obj/7a1700151f38bc7f2fde",
        "https://p3.pstatp.com/obj/7ac8000de933897548a6"
    ]
    private lazy var layout: UICollectionViewFlowLayout = {
        let lay = UICollectionViewFlowLayout()
        lay.minimumInteritemSpacing = 1
        lay.minimumLineSpacing = 1
        lay.scrollDirection = .vertical
        let kwidth: CGFloat = (UIScreen.main.bounds.width - 3) / 3 - 0.5
        lay.itemSize = CGSize(width: kwidth, height: kwidth * 1.5)
        lay.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        return lay
    }()
    
    private lazy var collectionView: UICollectionView = {
    
        let collect = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: layout)
        collect.backgroundColor = .white
        collect.dataSource = self
        collect.register(JSWebpCell.self, forCellWithReuseIdentifier: "JSWebpCell")
        return collect
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.collectionView)
    }

}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "JSWebpCell", for: indexPath) as! JSWebpCell
        cell.imageString = self.dataSource[indexPath.item]
        return cell
    }
}
