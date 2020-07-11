//
//  ContentView.swift
//  UIViewRepresentableWithModifier
//
//  Created by Zhengqian Kuang on 2020-07-10.
//  Copyright © 2020 Kuang. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var searchText: String = ""
    let shakespeareMostFamousQuotes: [String] = [
        "‘To be, or not to be: that is the question’",
        "‘All the world‘s a stage, and all the men and women merely players. They have their exits and their entrances; And one man in his time plays many parts.’",
        "‘Romeo, Romeo! wherefore art thou Romeo?’",
        "‘Now is the winter of our discontent’",
        "‘Is this a dagger which I see before me, the handle toward my hand?’",
        "‘Some are born great, some achieve greatness, and some have greatness thrust upon them.’",
        "‘Cowards die many times before their deaths; the valiant never taste of death but once.’",
        "‘Full fathom five thy father lies, of his bones are coral made. Those are pearls that were his eyes. Nothing of him that doth fade, but doth suffer a sea-change into something rich and strange.’",
        "‘A man can die but once.’",
        "‘How sharper than a serpent’s tooth it is to have a thankless child!’"
    ]
    @State var asyncSearchResult: String = ""
    
    var body: some View {
        VStack {
            // a UISearchBar wrapped by UIViewRepresentable
            SearchBarUIViewRepresentable(binding: $searchText)
                .placeholder("Keywords separated by space") // a custom modifier adding placeholder text
                .onSearchTextChanged(delegate: { (searchText) in // a custom modifier for an action delegate block
                    self.asyncSearchResult = ""
                })
                .onSearchButtonClicked { (searchText) in // a custom modifier for an action delegate block
                    self.asyncCount(source: self.shakespeareMostFamousQuotes, searchText: searchText) { (count) in
                        self.asyncSearchResult = "\(count) verse\((count > 1) ? "s" : "") found!"
                    }
                }
            
            // a Text displaying the asynchronous search result
            statisticsView
            
            // a list displaying the instant filtered result by search text
            List(shakespeareMostFamousQuotes.filter({ (item) -> Bool in
                var satisfied = true
                _ = searchText.components(separatedBy: .whitespaces).first(where: { (term) -> Bool in
                    if (term.count > 0) && !(item.lowercased().contains(term.lowercased())) {
                        satisfied = false
                        return true
                    }
                    return false
                })
                return satisfied
            }), id: \.self) { item in
                Text(item)
            }
        }
    }
    
    var statisticsView: AnyView? {
        if searchText.trimmingCharacters(in: .whitespaces).count == 0 {
            DispatchQueue.main.async {
                self.asyncSearchResult = ""
            }
            return nil
        }
        else {
            return AnyView(
                HStack {
                    Spacer().frame(width: 20)
                    Text(asyncSearchResult)
                        .background(Color.init(.systemGray5))
                    Spacer()
                }
            )
        }
    }
    
    func asyncCount(source: [String],searchText: String, completionHandler: @escaping (Int) -> ()) {
        // mocking an asynchronous search by simply dispatching with 1 second's delay
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            var counter: Int = 0
            _ = source.compactMap { (item) -> String? in
                _ = searchText.components(separatedBy: .whitespaces).first(where: { (term) -> Bool in
                    if (term.count > 0) && item.lowercased().contains(term.lowercased()) {
                        counter += 1
                    }
                    return false
                })
                return nil
            }
            completionHandler(counter)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
