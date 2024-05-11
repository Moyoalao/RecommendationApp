//
//  HeaderView.swift
//  RecommendationApp
//


import SwiftUI

struct HeaderView: View {
    
    let title: String
    let subtitle: String
    let background: Color
    
    var body: some View {
        ZStack {
            
            background
                .edgesIgnoringSafeArea(.all)

            VStack {
                Text(title)
                    .font(.system(size: 50))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 30))
                    .foregroundColor(.white)
            }
            .padding(.top, 30)
        }
        
        .frame(height: 300)
        .cornerRadius(0)
        .offset(y: -100)
    }
}


struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView(title: "Title", subtitle: "Subtitle", background: .red)
    }
}
