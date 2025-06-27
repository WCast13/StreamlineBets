//
//  HoleDetailRow.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/26/25.
//

import SwiftUI
import SwiftData

   // MARK: - HoleDetailRow
   struct HoleDetailRow: View {
       let hole: Hole
       
       var body: some View {
           HStack {
               Circle()
                   .fill(Color.accentColor.opacity(0.2))
                   .frame(width: 40, height: 40)
                   .overlay(
                       Text("\(hole.number)")
                           .font(.headline)
                           .foregroundColor(.accentColor)
                   )
               
               VStack(alignment: .leading) {
                   Text("Par \(hole.par)")
                       .font(.headline)
                   Text("\(hole.distance) yards")
                       .font(.caption)
                       .foregroundColor(.secondary)
               }
               
               Spacer()
               
               VStack(alignment: .trailing) {
                   Text("Handicap")
                       .font(.caption)
                       .foregroundColor(.secondary)
                   Text("\(hole.handicap)")
                       .font(.headline)
               }
           }
           .padding(.vertical, 4)
       }
   }
