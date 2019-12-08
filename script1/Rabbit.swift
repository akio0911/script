//
//  Rabbit.swift
//  script1
//
//  Created by Yoshiki Izumi on 2019/12/05.
//  Copyright © 2019 Yoshiki Izumi. All rights reserved.
//

import Foundation

class Func {
    var function : String
    var argument : [String]
    var argumentValue : [String]
    var script : String
    var returnValue: String
    init() {
        function = ""
        argument = []
        argumentValue = []
        script = ""
        returnValue = ""
    }
}

class Rabbit {
    private var funcArray : [Func] = []

    func run(script: String) {
        guard let path = Bundle.main.path(forResource: script, ofType: "jump") else {return}
        do {
            let script = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
            
            searchFunc(script: script)

            for i in 0..<funcArray.count {
                if funcArray[i].function == "main" {
                    funcParse(script: funcArray[i].script)
                }
            }
            
        } catch let error as NSError {
            print("エラー: \(error)")
            return
        }
    }
    func onTouchDown(x: Float, y: Float) {
        for i in 0..<funcArray.count {
            if funcArray[i].function == "onTouchDown" {
                let func0: Func = funcArray[i]
                if func0.argumentValue.count > 0 {
                    func0.argumentValue[0] = x.description
                    func0.argumentValue[1] = y.description
                } else {
                    func0.argumentValue.append(x.description)
                    func0.argumentValue.append(y.description)
                }
                routine(func0: func0)
            }
        }
    }
    func falls() {
        for i in 0..<funcArray.count {
            if funcArray[i].function == "jumpToHostLanguage" {
                print(funcArray[i].script)
            }
        }
    }
    
    // ================================
    // 関数の宣言を検索
    // ================================
    func searchFunc(script: String) {
        var nextRange0 = script.startIndex..<script.endIndex
        // scriptの中からfuncを検索
        while let begin0 = script.range(of: "func", options: .caseInsensitive, range: nextRange0) {
            nextRange0 = begin0.upperBound..<script.endIndex
            // funcの後ろに "(" があるか検索
            guard let end0 = script.range(of: "(", options: .caseInsensitive, range: nextRange0) else {break}
            // funcと(の間にある文字列が関数名になる
            let funcRange = begin0.upperBound..<end0.lowerBound
            var function = script[funcRange]

            while let range = function.range(of: " ") {
                function.replaceSubrange(range, with: "")
            }

            let func0: Func = Func()
            func0.function = function.description

            nextRange0 = end0.upperBound..<script.endIndex
            // "(" の後ろに ")" があるか検索
            guard let closeBracket = script.range(of: ")", options: .caseInsensitive, range: nextRange0) else {break}
            // "(" と ")" の間にある文字列が引数になる
            let argumentRange = end0.upperBound..<closeBracket.lowerBound
            let argument = script[argumentRange]
            var argumnetBegin = argument.startIndex
            var flag: Bool = true
            // 引数の中で "," があるか検索
            while let argumentEnd = argument.range(of: ",", options: .caseInsensitive, range: argumnetBegin..<argument.endIndex) {
                // "," があれば引数の１つとしてFuncクラスの引数配列に登録
                let argument0 = argumnetBegin..<argumentEnd.lowerBound
                var argument00 = argument[argument0]
                while let range = argument00.range(of: " ") {
                    argument00.replaceSubrange(range, with: "")
                }
                func0.argument.append(argument00.description)
                argumnetBegin = argumentEnd.upperBound
                flag = false
            }
            if flag == true {
                func0.argument.append(argument.description)
            } else {
                var arg = argument[argumnetBegin..<argument.endIndex]
                while let range = arg.range(of: " ") {
                   arg.replaceSubrange(range, with: "")
                }
                func0.argument.append(arg.description)
            }
            // 関数の中身を取得
            guard let bracket0 = script.range(of: "{", options: .caseInsensitive, range: nextRange0) else {break}
            guard let bracket1 = script.range(of: "}", options: .caseInsensitive, range: nextRange0) else {break}
            let bracketRange = bracket0.upperBound..<bracket1.lowerBound

            func0.script = script[bracketRange].description
            
            funcArray.append(func0)
        }

    }

    // ================================
    // 関数の中身を解析
    // ================================
    func funcParse(script:String) {
        var nextRange1 = script.startIndex..<script.endIndex
        for i in 0..<funcArray.count {
            // 関数のスクリプトの中身に 関数名と"(" があるか検索
            while let end1 = script.range(of: funcArray[i].function + "(", options: .caseInsensitive, range: nextRange1 ) {
                // 関数名と"("があった場合、 ")"を検索
                guard let closeBracket = script.range(of: ")", options: .caseInsensitive, range: end1.upperBound..<script.endIndex) else {break}
                // "("と")"の間にあった文字列が引数になる
                let argumentRange = end1.upperBound..<closeBracket.lowerBound
                var argument = script[argumentRange]
                var argumnetBegin = argument.startIndex
                var flag: Bool = true
                // 引数の文字列の中に","があるか検索
                while let argumentEnd = argument.range(of: ",", options: .caseInsensitive, range: argumnetBegin..<argument.endIndex) {
                    // ","があれば引数の１つとしてFuncクラスの引数の値の配列に登録
                    let argument0 = argumnetBegin..<argumentEnd.lowerBound
                    var argument00 = argument[argument0]
                    while let range = argument00.range(of: " ") {
                        argument00.replaceSubrange(range, with: "")
                    }
                    funcArray[i].argumentValue.append(argument00.description)
                    argumnetBegin = argumentEnd.upperBound
                    flag = false
                }
                while let range = argument.range(of: "\"") {
                    argument.replaceSubrange(range, with: "")
                }
                if flag == true {
                    funcArray[i].argumentValue.append(argument.description)
                } else {
                    var arg = argument[argumnetBegin..<argument.endIndex]
                    while let range = arg.range(of: " ") {
                       arg.replaceSubrange(range, with: "")
                    }
                    funcArray[i].argumentValue.append(arg.description)
                }
                // 関数を実行
                routine(func0: funcArray[i])
                nextRange1 = argumentRange.upperBound..<script.endIndex
            }
            
            var nextRange2 = script.startIndex..<script.endIndex
            while let end2 = script.range(of: "return", options: .caseInsensitive, range: nextRange2) {
                guard let closeNL = script.range(of: "\n", options: .caseInsensitive, range: end2.upperBound..<script.endIndex) else {break}
                let returnRange = end2.upperBound..<closeNL.lowerBound
                var returnValue = script[returnRange]
                while let range = returnValue.range(of: " ") {
                   returnValue.replaceSubrange(range, with: "")
                }
                while let range = returnValue.range(of: "\"") {
                   returnValue.replaceSubrange(range, with: "")
                }
                funcArray[i].returnValue = returnValue.description
                nextRange2 = closeNL.upperBound..<script.endIndex
            }
        }
    }
    
    // ================================
    // 関数を実行
    // ================================
    func routine(func0: Func) {
        let script = func0.script
        funcParse(script: script)

        var varArray: [Substring] = []
        var valArray: [Substring] = []

        var begin010 = script.startIndex
        while let begin01 = script.range(of: "var", options: .caseInsensitive, range: begin010..<script.endIndex) {
            guard let end1 = script.range(of: "=", options: .caseInsensitive, range: begin01.upperBound..<script.endIndex) else {return}
            let varRange = begin01.upperBound..<end1.lowerBound
            var variable = script[varRange]

            while let range = variable.range(of: " ") {
                variable.replaceSubrange(range, with: "")
            }
            varArray.append(variable)

            guard let nl1 = script.range(of: "\n", options: .caseInsensitive, range: end1.upperBound..<script.endIndex) else {return}
            let valRange = end1.upperBound..<nl1.lowerBound
            var value = script[valRange]
            while let range = value.range(of: " ") {
                value.replaceSubrange(range, with: "")
            }
            while let range = value.range(of: "\"") {
                value.replaceSubrange(range, with: "")
            }
            valArray.append(value)
            begin010 = nl1.upperBound
        }

        var begin020 = script.startIndex
        while let begin = script.range(of: "print(\"", options: .caseInsensitive, range: begin020..<script.endIndex) {
            let nextRange = begin.upperBound..<script.endIndex
            guard let end = script.range(of: "\"", options: .caseInsensitive, range: nextRange) else {return}
            let wordRange = begin.upperBound..<end.lowerBound
            begin020 = end.upperBound
            print(script[wordRange])
        }

        var begin030 = script.startIndex
        while let begin3 = script.range(of: "print(", options: .caseInsensitive, range: begin030..<script.endIndex) {
            let nextRange3 = begin3.upperBound..<script.endIndex
            guard let end3 = script.range(of: ")", options: .caseInsensitive, range: nextRange3) else {return}
            let printRange = begin3.upperBound..<end3.lowerBound
            let print1 = script[printRange]

            for i in 0..<varArray.count {
                if print1 == varArray[i] {
                    print(valArray[i])
                }
            }
            for i in 0..<func0.argument.count {
                if print1 == func0.argument[i] && func0.argument[i] != "" {
                    print(func0.argumentValue[i])
                }
            }
            for i in 0..<funcArray.count {
                if print1 == (funcArray[i].function + "(") {
                    print(funcArray[i].returnValue)
                }
            }

            begin030 = end3.upperBound
        }
    }
}
