//
//  File.swift
//
//
//  Created by Archibbald on 27.01.2024.
//

import SwiftUI

public struct BooleanSheetActivationViewModifier<SheetContent: View>: ViewModifier {
    
    @Binding var sheetActive: Bool
    @ViewBuilder var content: () -> SheetContent
    
    @EnvironmentObject var sheetModel: SheetViewModel
    @Environment(\.sheetController) var controller
    @Environment(\.self) var environments
    
    public func body(content: Content) -> some View {
        content
            .background {
                Color.clear
                    .onAppear(perform: onCreate)
                    .onChange(of: sheetActive) { active in
                        guard active != sheetModel.sheetActive else { return }
                        
                        if active {
                            sheetModel.present(configuration: configuration, environments: environments, content: self.content)
                        } else {
                            sheetModel.dismiss(configuration: configuration)
                        }
                    }
                    .onReceive(
                        sheetModel.$sheetActive
                            .dropFirst()
                            .receive(on: RunLoop.main)
                            .removeDuplicates()
                    ) { active in
                        guard active != sheetActive else { return }
                        
                        sheetActive = active
                    }
            }
    }
    
    // MARK: - Sheet settings
    private var isRootView: Bool {
        controller.presentationControllersStack.isEmpty
    }
    
    private var configuration: SheetControllersViewModel {
        isRootView ? .init() : controller
    }
    
    private func onCreate() {
        guard sheetActive else { return }
        
        sheetModel.present(configuration: configuration, environments: environments, content: content)
    }
}