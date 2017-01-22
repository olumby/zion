//
//  RoomViewController.swift
//  MatrixApp
//
//  Created by Oliver Lumby on 22/01/2017.
//  Copyright © 2017 Oliver Lumby. All rights reserved.
//

import UIKit
import MatrixSDK

class RoomViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var room: MatrixRoom!
    
    var events: [MatrixEvent] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.room.displayName()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 140
        
        self.room.room.liveTimeline.listen { (event, direction, state) in
            if event != nil {
             
                if (event?.eventType == MXEventTypeRoomMessage) ||
                    (event?.eventType == MXEventTypeRoomMember) {
                    self.events.append(MatrixEvent(event: event!, room: self.room))
                    self.tableView.beginUpdates()
                    self.tableView.insertRows(at: [IndexPath(row: self.events.count-1, section: 0)], with: .automatic)
                    self.tableView.endUpdates()
                    self.tableView.scrollToRow(at: IndexPath(row: self.events.count-1, section: 0), at: UITableViewScrollPosition.top, animated: true)
                }
                
                
            }
        }
        
        self.room.room.liveTimeline.resetPagination()
        self.room.room.liveTimeline.paginate(10, direction: MXTimelineDirectionBackwards, onlyFromStore: false, complete: {
            self.events = self.events.sorted(by: { (a, b) -> Bool in
                return a.event.age > b.event.age
            })
            
            self.tableView.reloadData()
        }) { (error) in
            print("Could not load history: \(error)")
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


extension RoomViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let event = self.events[indexPath.row]
        
        if (indexPath.row - 1) >= 0 {
            let previousEvent = self.events[indexPath.row - 1]
            
            if (event.event.sender == previousEvent.event.sender) && (event.event.eventType == MXEventTypeRoomMessage) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "messageTableViewCell", for: indexPath) as! MessageTableViewCell
                cell.messageLabel.text = event.asString
                
                return cell
            }
        }
        
        if event.event.eventType == MXEventTypeRoomMember {
            let cell = tableView.dequeueReusableCell(withIdentifier: "noticeMessageTableViewCell", for: indexPath) as! NoticeMessageTableViewCell
                        
            cell.noticeLabel.text = event.asString
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "firstMessageTableViewCell", for: indexPath) as! FirstMessageTableViewCell
        
        cell.messageLabel.text = event.asString
        cell.authorLabel.text = event.event.sender
        if event.senderAvatarLink != nil {
            cell.avatarImageView.downloadedFrom(link: event.senderAvatarLink!)
        }
        
        return cell
    }

}
