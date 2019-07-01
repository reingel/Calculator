//
//  ContentView.swift
//  Calculator
//
//  Created by Soonkyu Jeong on 2019/06/30.
//  Copyright © 2019 Soonkyu Jeong. All rights reserved.
//

import SwiftUI

struct ContentView : View {
	var calculator = Calculator()
	
    var body: some View {
		VStack {
			Spacer()
			Text("Ans")
			Spacer()
			HStack {
				TextField(.constant("Enter an expression"))
					.frame(width: 200, height: 50, alignment: .center)
			}
			Spacer()
			Spacer()
		}
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
