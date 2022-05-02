//
//  ProjectsOverviewView.swift
//  MoonCascadeTest
//
//  Created by Rinat Gabdullin on 02.05.2022.
//

import SwiftUI
import Combine

struct ProjectDetails: View {
    
    @State var model: ProjectDetailsViewModel
    
    var body: some View {
        HStack {
            Image(systemName: model.imageName)
                .frame(width: 24, height: 16, alignment: .center)
                .foregroundColor(.secondary)
            Text(model.position)
                .font(.subheadline)
            Text(String(model.count))
                .foregroundColor(.gray)
                .font(.caption2)
                .fontWeight(.bold)
        }
        .frame(height: 20, alignment: .center)
    }
}

struct ProjectsOverviewView: View {
    
    typealias Models = [ProjectViewModel]
    
    let updatesPublisher: AnyPublisher<Models, Never>
    @State private var models = Models()
    
    init(models: [ProjectViewModel] = [],
         updatesPublisher: AnyPublisher<Models, Never>? = nil) {
        
        self.models = models
        
        if let updatesPublisher = updatesPublisher {
            self.updatesPublisher = updatesPublisher
        } else {
            self.updatesPublisher = Empty<Models, Never>().eraseToAnyPublisher()
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(models) { model in
                    HStack {
                        Image(systemName: "camera.macro.circle.fill")
                            .font(.title)
                            .foregroundColor(.accentColor)
                            .frame(width: 24, height: 16, alignment: .center)
                        Text(model.title)
                            .font(.title)
                    }
                    
                    Divider()
                        .padding(.leading, 32)
                    
                    ForEach(model.details) { item in
                        ProjectDetails(model: item)
                    }
                    
                    Spacer().frame(height: 24)
                }
                
            }
            .padding()
        }
        .onReceive(updatesPublisher, perform: { output in
            models = output
        })
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

struct ProjectOverviewView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProjectsOverviewView(models: [.init(id: "1", title: "Title", details: [.random()])])
        }
    }
}
