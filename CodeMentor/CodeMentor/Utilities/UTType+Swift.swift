//
//  UTType+Swift.swift
//  CodeMentor
//
//  Copyright © 2026 Code Mentor Swift. All rights reserved.
//  Licensed under the Apache License, Version 2.0

import UniformTypeIdentifiers

extension UTType {
    static var swiftSource: UTType {
        UTType(exportedAs: "public.swift-source", conformingTo: .sourceCode)
    }
}
