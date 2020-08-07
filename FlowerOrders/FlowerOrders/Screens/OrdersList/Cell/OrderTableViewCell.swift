//
//  OrderTableViewCell.swift
//  FlowerOrders
//
//  Created by Paul Tiriteu on 05/08/2020.
//  Copyright © 2020 Paul Tiriteu. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class OrderTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var sentLabel: UILabel!
    @IBOutlet weak var orderImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    func configure(order: Order) {
        nameLabel.text = order.recipient
        descriptionLabel.text = order.description
        
        sentLabel.isHidden = order.sent == false
        
        orderImageView.layer.cornerRadius = orderImageView.bounds.height / 2
        orderImageView.contentMode = .scaleAspectFit
        guard let photoUrl = URL(string: order.photoUrl) else { return }
        orderImageView.af.setImage(withURL: photoUrl)
    }
}
