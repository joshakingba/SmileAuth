////
////  ExternalLinks.swift
////  PasswordGenerator
////
////  Created by Josh Kenzo
////
//
//import SwiftUI
//
//struct ExternalLinks: View {
//    
//    @ObservedObject var settingsViewModel: SettingsViewModel
//    
//    var body: some View {
//        Section(header: Text("Liens")) {
//            
//            Button(action: { settingsViewModel.requestAppStoreReview() },
//                   label:
//                    Label(title: { Text("Noter sur l'App Store") },
//                          icon: { Image(systemName: "star.fill") }))
//            
//            Link(destination: URL(string: "https://github.com/il1ane/PasswordGenerator")!) {
//                
//                Label(title: { Text("Code source (GitHub)") },
//                      icon: { Image(systemName: "chevron.left.slash.chevron.right") }) }
//            
//            Link(destination: URL(string: "https://twitter.com/lockd_app")!) {
//                    
//                Label(title: { Text("Suivre @lockd_app sur Twitter") },
//                      icon: { Image(systemName: "heart.fill") }) }
//            
//        }
//    }
//}
//
//struct ExternalLinks_Previews: PreviewProvider {
//    static var previews: some View {
//        ExternalLinks(settingsViewModel: SettingsViewModel())
//    }
//}
