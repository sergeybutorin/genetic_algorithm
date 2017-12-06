//
//  main.swift
//  lab4
//
//  Created by Sergey Butorin on 05/12/2017.
//  Copyright © 2017 Sergey Butorin. All rights reserved.
//

import Foundation

let pMut = 0.1
let SELF_VALUE = 100000
let aliveProportion = 0.5
let pBest = 0.2

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

func readInt(minValue: Int = 1, maxValue: Int = Int.max) -> Int {
    while (true) {
        guard let value = Int(readLine()!),
            value >= minValue,
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
    let bestCount = Int(pBest * Double(oldPopulation.count))
    var newPopulation = Array(oldPopulation.sorted(by: {$0.value(forGraph: graph) > $1.value(forGraph: graph) }).prefix(bestCount))
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

func reproduction(population: [Chromosome], populationCount: Int) -> [Chromosome] {
    print("Репродукция")
    var newPopulation = population
    while newPopulation.count < populationCount {
        newPopulation.append(cross(
            firstC: newPopulation[Int(arc4random_uniform(UInt32(newPopulation.count - 1)))],
            secondC: newPopulation[Int(arc4random_uniform(UInt32(newPopulation.count - 1)))]))
    }
    return newPopulation
}

func createMutations(population: [Chromosome]) {
    print("Мутации")
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

func printPopulation(population: [Chromosome]) {
    print("\nЗначения хромосом: ")
    
    for c in population {
        print(c.gens)
    }
}

func genIteration(populationCount: Int,
                  graph: [[Int]],
                  sender: Int,
                  receiver: Int) {
    
        if population.isEmpty {
            population = createInitialPopulation(count: populationCount,
                                                 pcInWeb: graph.count,
                                                 sender: sender,
                                                 receiver: receiver)
        } else {
//            population = tournamentSelection(oldPopulation: population,
//                                             graph: graph)
            population = rouletteSelection(oldPopulation: population,
                                           graph: graph)
        }
    
        printPopulation(population: population)
        
        population = reproduction(population: population,
                                  populationCount: populationCount)
    
        printPopulation(population: population)
    
        createMutations(population: population)
    
        printPopulation(population: population)
    
        print("\nПропускная способность для популяции: ")
    
        var best = 0
        
        for c in population {
            let value = c.value(forGraph: graph)
            
            best = max(best, value)
            print(value)
        }
        
        print("Лучший результат: ", best)
}

func genAlgorythm(iterations: Int,
                  populationCount: Int,
                  graph: [[Int]],
                  sender: Int,
                  receiver: Int) {
    for _ in 0..<iterations {
        genIteration(populationCount: populationCount,
                     graph: graph,
                     sender: sender,
                     receiver: receiver)
    }
}

func runUserInput() {
    print("Введите количество компьютеров:")
    let pcInWeb = readInt()
    
    print("Введите номер отправителя (от 1 до \(pcInWeb))")
    let sender = readInt(maxValue: pcInWeb)
    
    print("Введите номер получателя (от 1 до \(pcInWeb))")
    let receiver = readInt(maxValue: pcInWeb)
    
    print("Введите размер популяции:")
    let populationCount = readInt()
    
    print("Введите количество итераций (-1 для пошагового выполнения):")
    let iterationsCount = readInt(minValue: -1)
    
    let graph = createGraph(dimension: pcInWeb)
    
    print("\nСетевой граф: ")
    
    for row in 0..<graph.count {
        print(graph[row])
    }
    if iterationsCount > 0 {
        genAlgorythm(iterations: iterationsCount,
                     populationCount: populationCount,
                     graph: graph,
                     sender: sender,
                     receiver: receiver)
    } else {
        while true {
            genIteration(populationCount: populationCount,
                         graph: graph,
                         sender: sender,
                         receiver: receiver)
            print("Продолжить выполнение? (y/n):")
            let res = readLine()
            if (res != "y") {
                break
            }
        }
    }
    
}

func test() {
    let graph = [
        [100000, 90, 44, 81, 32, 16, 56, 27, 61, 63, 89, 16, 104, 109, 69, 43, 31, 68, 36, 86],
        [27, 100000, 90, 20, 12, 51, 63, 51, 43, 10, 20, 33, 12, 62, 27, 101, 105, 82, 21, 31],
        [19, 83, 100000, 30, 39, 94, 56, 104, 23, 53, 107, 37, 77, 76, 21, 42, 15, 68, 108, 23],
        [55, 108, 15, 100000, 60, 33, 32, 61, 37, 89, 41, 79, 91, 109, 65, 73, 89, 73, 107, 39],
        [81, 84, 72, 93, 100000, 65, 50, 104, 17, 28, 13, 108, 40, 34, 42, 46, 42, 92, 100, 75],
        [73, 73, 26, 54, 67, 100000, 54, 107, 99, 17, 52, 45, 87, 18, 49, 52, 49, 83, 26, 73],
        [20, 13, 44, 27, 83, 34, 100000, 82, 30, 65, 97, 89, 70, 95, 79, 21, 37, 36, 89, 105],
        [63, 81, 73, 81, 93, 77, 88, 100000, 29, 39, 61, 75, 55, 101, 90, 71, 35, 54, 71, 30],
        [24, 62, 77, 78, 97, 56, 90, 86, 100000, 11, 69, 69, 32, 70, 24, 78, 47, 89, 14, 90],
        [89, 68, 46, 55, 108, 38, 74, 106, 25, 100000, 42, 26, 60, 95, 56, 11, 77, 77, 86, 31],
        [104, 43, 52, 13, 73, 78, 107, 25, 109, 90, 100000, 10, 69, 99, 18, 69, 82, 84, 95, 40],
        [30, 29, 15, 48, 26, 23, 77, 101, 106, 74, 73, 100000, 56, 103, 84, 97, 34, 64, 88, 59],
        [45, 80, 79, 99, 53, 101, 79, 73, 16, 87, 106, 76, 100000, 58, 18, 43, 86, 40, 73, 95],
        [106, 87, 52, 74, 38, 66, 102, 105, 49, 14, 38, 10, 35, 100000, 28, 49, 27, 14, 36, 100],
        [80, 101, 105, 94, 61, 90, 63, 38, 20, 67, 15, 49, 99, 71, 100000, 49, 49, 99, 65, 26],
        [68, 55, 76, 99, 102, 103, 58, 29, 10, 104, 17, 22, 17, 80, 109, 100000, 27, 90, 77, 85],
        [31, 38, 23, 69, 67, 48, 108, 101, 90, 20, 43, 81, 81, 76, 69, 70, 100000, 22, 88, 34],
        [102, 48, 89, 49, 36, 29, 79, 15, 53, 12, 73, 41, 89, 98, 17, 74, 12, 100000, 86, 24],
        [36, 17, 70, 54, 97, 14, 32, 97, 70, 39, 86, 27, 44, 20, 20, 75, 20, 66, 100000, 82],
        [73, 61, 108, 22, 99, 57, 84, 14, 92, 87, 90, 66, 61, 61, 14, 32, 101, 98, 47, 100000],
    ]
    
    genAlgorythm(iterations: 400,
                 populationCount: 50,
                 graph: graph,
                 sender: 2,
                 receiver: 18)
}

runUserInput()
//test()


