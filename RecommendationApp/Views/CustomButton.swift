//
//  CustomButton.swift
//  RecommendationApp
//
//  Created by Musibau Alao on 03/04/2024.
//

import SwiftUI

struct CustomButton: View {
    
    let title: String
    let background: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(background)
                Text(title)
                    .foregroundColor(background == .black ? .white : .black)
            }
            .frame(height: 44)
        }
        .padding(.horizontal) 
    }
}


struct CustomButton_Previews: PreviewProvider {
    static var previews: some View {
        CustomButton(title: "Click Me", background: .blue) {
           
        }
    }
}
