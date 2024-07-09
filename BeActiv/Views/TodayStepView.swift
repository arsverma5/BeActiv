//
//  TodayStepView.swift
//  BeActiv
//
//  Created by Arshia Verma on 6/29/24.
//

import SwiftUI

struct TodayStepView: View {
    let step : Step
    
    var body: some View {
        VStack {
            Text("\(step.count)")
                .font(.largeTitle)
        }.frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: 150)
            .background(.orange)
            .clipShape(RoundedRectangle(cornerRadius: 16.0, style: .continuous))
            .overlay(alignment: .topLeading) {
                HStack {
                    Image(systemName: "flame")
                        .foregroundColor(.red)
                    Text("Steps")
                }.padding()
            }
            .overlay(alignment: .bottomTrailing) {
                Text(step.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .padding()
                
        }
    }
}
