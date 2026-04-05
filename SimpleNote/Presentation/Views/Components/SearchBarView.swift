//
//  SearchBarView.swift
//  SimpleNote
//
//  Created by user on 4/3/26.
//

import SwiftUI

/// Search bar with sort options
struct SearchBarView: View {
    @Binding var searchQuery: String
    @Binding var sortOption: SortOption
    let onSearch: () -> Void
    let onSortChange: (SortOption) -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search notes...", text: $searchQuery)
                    .textFieldStyle(.plain)
                    .onSubmit {
                        onSearch()
                    }
                
                if !searchQuery.isEmpty {
                    Button(action: {
                        searchQuery = ""
                        onSearch()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .background(AppTheme.searchBarBackground)
            .cornerRadius(10)

            Menu {
                ForEach(SortOption.allCases) { option in
                    Button {
                        onSortChange(option)
                    } label: {
                        Label(
                            option.rawValue,
                            systemImage: sortOption == option ? "checkmark" : option.systemImage
                        )
                    }
                }
            } label: {
                Image(systemName: "arrow.up.arrow.down")
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(8)
                    .background(AppTheme.searchBarBackground)
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    SearchBarView(
        searchQuery: .constant(""),
        sortOption: .constant(.newestFirst),
        onSearch: {},
        onSortChange: { _ in }
    )
}
