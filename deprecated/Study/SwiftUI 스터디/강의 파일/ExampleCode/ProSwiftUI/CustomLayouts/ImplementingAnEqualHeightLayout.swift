////
////  ImplementingAnEqualHeightLayout.swift
////  ProSwiftUI
////
////  Created by Theo on 2/25/26.
////
//
//import SwiftUI
//
//extension ImplementingAnEqualHeightLayout {
//    struct EqualHeightVStack: Layout {
//        private func maximumSize(across subviews: Subviews) -> CGSize {
//            var maximumSize = CGSize.zero
//            
//            for view in subviews {
//                let size = view.sizeThatFits(.unspecified)
//                
//                if size.width > maximumSize.width {
//                    maximumSize.width = size.width
//                }
//                
//                if size.height > maximumSize.height {
//                    maximumSize.height = size.height
//                }
//            }
//            
//            return maximumSize
//        }
//        
//        func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
//            
//        }
//        
//        func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
//            <#code#>
//        }
//        
//        
//    }
//}
//
//struct ImplementingAnEqualHeightLayout: View {
//    var body: some View {
//        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
//    }
//}
//
//#Preview {
//    ImplementingAnEqualHeightLayout()
//}
