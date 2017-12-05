//
//  main.swift
//  lab4
//
//  Created by Sergey Butorin on 05/12/2017.
//  Copyright © 2017 Sergey Butorin. All rights reserved.
//

import Foundation

let pCros = 0.8
let pMut = 0.4
let SELF_VALUE = 100000

class Chromosome {
    var gens = [Int]()
    
    init(_ gensCount: Int, sender: Int, receiver: Int) {
        gens = Array(0...gensCount - 1)
        if sender > 1 {
            swap(&gens[0], &gens[sender - 1])
        }
        if receiver < gensCount {
            swap(&gens[receiver - 1], &gens[gens.count - 1])
        }
        for i in 1..<gensCount - 1 {
            let swapWith = 1 + Int(arc4random_uniform(UInt32(gens.count - 3)))
            if i != swapWith {
                swap(&gens[i], &gens[swapWith])
            }
        }
    }
    
    func mutate() {
        let genPos = 1 + Int(arc4random_uniform(UInt32(gens.count - 3)))
        let value = Int(arc4random_uniform(UInt32(gens.count - 1)))
        gens[genPos] = value
    }
    
    func value(forGraph graph: [[Int]]) -> Int {
        var value = SELF_VALUE
        for i in 0..<gens.count - 1 {
            let newValue = graph[gens[i]][gens[i + 1]]
            if newValue < value {
                value = newValue
            }
        }
        return value
    }
}

var population = [Chromosome]()

func readInt(maxValue: Int = Int.max) -> Int {
    while (true) {
        guard let value = Int(readLine()!),
            value > 0,
            value <= maxValue else {
            print("Попробуйте еще раз:")
            continue
        }
        return value
    }
}

func selection(graph: [[Int]]) {
    population.sort(by: { $0.value(forGraph: graph) > $1.value(forGraph: graph) })
}

func tournamentSelection(oldPopulation: [Chromosome],
                         count: Int,
                         graph: [[Int]]) -> [Chromosome] {
    var newPopulation = [Chromosome]()
    while newPopulation.count < count {
        let first = oldPopulation[Int(arc4random_uniform(UInt32(oldPopulation.count - 1)))]
        let second = oldPopulation[Int(arc4random_uniform(UInt32(oldPopulation.count - 1)))]
        if first.value(forGraph: graph) > second.value(forGraph: graph) {
            newPopulation.append(first)
        } else {
            newPopulation.append(second)
        }
    }
    return newPopulation
}

func createPopulation() {
    
}

func createGraph(dimension: Int) -> [[Int]] {
    var graph = [[Int]](repeating: [Int](repeating: SELF_VALUE,
                             count: dimension),
            count: dimension)
    for i in 0..<dimension {
        for j in 0..<dimension {
            if i != j {
                graph[i][j] = 10 + Int(arc4random_uniform(UInt32(50)))
            }
        }
    }
    return graph
}

print("Введите количество компьютеров:")
let pcInWeb = readInt()

print("Введите номер отправителя (от 1 до \(pcInWeb))")
let sender = readInt(maxValue: pcInWeb)

print("Введите номер получателя (от 1 до \(pcInWeb))")
let receiver = readInt(maxValue: pcInWeb)

print("Введите размер популяции:")
let populationCount = readInt()

print("Введите количество итераций:")
let iterationsCount = readInt()

for _ in 0..<populationCount {
    population.append(Chromosome(pcInWeb, sender: sender, receiver: receiver))
}

let graph = createGraph(dimension: pcInWeb)

print("\nСетевой граф: ")

for row in 0..<graph.count {
    print(graph[row])
}

for _ in 0..<iterationsCount {
    print("\nРезультат хромосом: ")
    
    for c in population {
        print(c.value(forGraph: graph))
    }
    
    print("\nЗначения хромосом: ")
    
    for c in population {
        print(c.gens)
    }
    population = tournamentSelection(oldPopulation: population,
                                      count: populationCount,
                                      graph: graph)
    selection(graph: graph)
}








