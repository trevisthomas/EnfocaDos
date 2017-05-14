//
//  MonitoredBaseOperation.swift
//  Enfoca
//
//  Created by Trevis Thomas on 3/11/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation

class MonitoredBaseOperation : BaseOperation {
    private(set) var progressObserver : ProgressObserver
    init(progressObserver: ProgressObserver, errorDelegate: ErrorDelegate) {
        self.progressObserver = progressObserver
        super.init(errorDelegate: errorDelegate)
    }
}
