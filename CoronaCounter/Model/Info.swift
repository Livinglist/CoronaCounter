//
//  File.swift
//  CoronaCounter
//
//  Created by gaibb on 2020/5/17.
//  Copyright © 2020 Jiaqi Feng. All rights reserved.
//

import Foundation

struct Info{
    let confirms, recovers, deaths :String;
    
    init(confirms:String,recovers:String,deaths: String){
        self.confirms = confirms;
        self.recovers = recovers;
        self.deaths = deaths;
    }
}
