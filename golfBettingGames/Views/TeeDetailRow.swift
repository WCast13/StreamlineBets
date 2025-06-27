//
//  TeeDetailRow.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/26/25.
//

import SwiftUI
import SwiftData

   // MARK: - TeeDetailRow
   struct TeeDetailRow: View {
       let tee: Tee
       
       var body: some View {
           VStack(alignment: .leading, spacing: 8) {
               Text(tee.name)
                   .font(.headline)
               
               HStack(spacing: 30) {
                   VStack(alignment: .leading) {
                       Text("Men")
                           .font(.caption)
                           .foregroundColor(.secondary)
                       Text("\(tee.menRating, specifier: "%.1f") / \(tee.menSlope)")
                           .font(.subheadline)
                   }
                   
                   VStack(alignment: .leading) {
                       Text("Women")
                           .font(.caption)
                           .foregroundColor(.secondary)
                       Text("\(tee.womenRating, specifier: "%.1f") / \(tee.womenSlope)")
                           .font(.subheadline)
                   }
               }
           }
           .padding(.vertical, 4)
       }
   }
