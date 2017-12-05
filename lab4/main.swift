//
//  main.swift
//  lab4
//
//  Created by Sergey Butorin on 05/12/2017.
//  Copyright © 2017 Sergey Butorin. All rights reserved.
//

import Foundation

let pMut = 0.4
let SELF_VALUE = 100000
let aliveProportion = 0.8

class Chromosome {
    var gens = [Int]()
    
    init() {
        
    }

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

func tournamentSelection(oldPopulation: [Chromosome],
                         graph: [[Int]]) -> [Chromosome] {
    var newPopulation = [Chromosome]()
    while newPopulation.count < Int(aliveProportion * Double(oldPopulation.count)) {
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

func rouletteSelection(oldPopulation: [Chromosome],
                       graph: [[Int]]) -> [Chromosome] {
    var oldPopulation = oldPopulation
    var newPopulation = [Chromosome]()
    while newPopulation.count <= Int(aliveProportion * Double(oldPopulation.count)) {
        var sumFit = 0
        for member in oldPopulation {
            sumFit += member.value(forGraph: graph)
        }
        let rouletPos = Int(arc4random_uniform(UInt32(sumFit)))
        var rouletPosForMember = oldPopulation[0].value(forGraph: graph)
        for i in 0..<oldPopulation.count {
            if rouletPos < rouletPosForMember {
//                print("Value: \(rouletPos), \(i)-th member selected")
                newPopulation.append(oldPopulation[i])
                oldPopulation.remove(at: i)
                break
            }
            rouletPosForMember += oldPopulation[i].value(forGraph: graph)
        }
    }
    return newPopulation
}

func cross(firstC: Chromosome, secondC: Chromosome) -> Chromosome {
    let newChromosome = Chromosome()
    for i in 0..<firstC.gens.count {
        let num = arc4random_uniform(1)
        if num > 0 {
            newChromosome.gens.append(secondC.gens[i])
        } else {
            newChromosome.gens.append(firstC.gens[i])
        }
    }
    return newChromosome
}

func createMutations(population: [Chromosome]) {
    for chromosome in population {
        let prob = arc4random_uniform(100)
        if Double(prob/100) < pMut {
            chromosome.mutate()
        }
    }
}

func createInitialPopulation(count: Int,
                             pcInWeb: Int,
                             sender: Int,
                             receiver: Int) -> [Chromosome] {
    var newPopulation = [Chromosome]()
    for _ in 0..<count {
        newPopulation.append(Chromosome(pcInWeb, sender: sender, receiver: receiver))
    }
    return newPopulation
}

func createGraph(dimension: Int) -> [[Int]] {
    var graph = [[Int]](repeating: [Int](repeating: SELF_VALUE,
                             count: dimension),
            count: dimension)
    for i in 0..<dimension {
        for j in 0..<dimension {
            if i != j {
                graph[i][j] = 10 + Int(arc4random_uniform(UInt32(100)))
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

let graph = createGraph(dimension: pcInWeb)

print("\nСетевой граф: ")

for row in 0..<graph.count {
    print(graph[row])
}

for _ in 0..<iterationsCount {
    
    if population.isEmpty {
        population = createInitialPopulation(count: populationCount,
                                             pcInWeb: pcInWeb,
                                             sender: sender,
                                             receiver: receiver)
    } else {
        population = rouletteSelection(oldPopulation: population,
                     graph: graph)
    }
    
    while population.count < populationCount {
        population.append(cross(firstC: population[Int(arc4random_uniform(UInt32(population.count - 1)))], secondC: population[Int(arc4random_uniform(UInt32(population.count - 1)))]))
    }
    
    createMutations(population: population)
    
    print("\nРезультат хромосом: ")
    
    for c in population {
        print(c.value(forGraph: graph))
    }
    
    print("\nЗначения хромосом: ")
    
    for c in population {
        print(c.gens)
    }
}








