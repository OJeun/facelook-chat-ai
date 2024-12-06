//
//  GroupView.swift
//  iOS-Project
//
//  Created by Fiona Wong on 2024-12-05.
//

import SwiftUI

struct GroupView: View {
    var group: UserGroup
    var onGroupSelected: () -> Void
    
    var body: some View {
        Button(action: onGroupSelected) {
            Text(group.name)
                .font(.headline)
                .padding(.vertical, 10)
        }
    }
}

#Preview {
    GroupView(group: UserGroup(id: 12, name: "Testing Group"), onGroupSelected: {})
}
