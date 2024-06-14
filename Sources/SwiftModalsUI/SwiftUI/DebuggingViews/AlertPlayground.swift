//
//  AlertPlayground.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 23/5/24.
//

import SwiftUI

struct AlertPlayground: View {
    
    @State
    private var showAlert = false
    
    var body: some View {
        VStack {
            if !showAlert {
                Spacer()
            }
            
            Text("Alert Presenter")
                .font(.largeTitle)
                .foregroundColor(.primary)
            
            if showAlert {
                Spacer()
            }
                        
            Button("Show Alert") {
                showAlert.toggle()
            }
            .foregroundColor(.white)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(
                Capsule()
                    .fill(Color.accentColor)
            )
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .animation(.bouncy, value: showAlert)
        .alertModal(
            "Title",
            isPresented: $showAlert
        ) {
            Text("Message 2")
                .modalContentBackground(Color.gray)
            
        } actions: {
            
            CustomAlertButton("Action") {
                print("Perform 'Action'.")
            }
            
            CustomAlertButton("Cancel", role: .cancel) {
                print("Perform 'Cancel'.")
            }
        }
    }
}

#Preview {
    AlertPlayground()
}
